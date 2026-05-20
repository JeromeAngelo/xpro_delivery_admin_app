import 'package:flutter/material.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/trip_ticket/collection/domain/entity/collection_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/widgets/app_structure/data_dashboard.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

class CompletedCustomerDashboard extends StatelessWidget {
  final List<CollectionEntity> collections;
  final bool isLoading;
  final DateTime? selectedStartDate;
  final DateTime? selectedEndDate;
  final bool isDateFiltered;
  final VoidCallback? onDateFilterTap;
  final VoidCallback? onClearFilter;

  const CompletedCustomerDashboard({
    super.key,
    required this.collections,
    this.isLoading = false,
    this.selectedStartDate,
    this.selectedEndDate,
    this.isDateFiltered = false,
    this.onDateFilterTap,
    this.onClearFilter,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildLoadingSkeleton(context);
    }

    // Calculate dashboard metrics
    final totalCollections = collections.length;

    final totalAmount = collections.fold<double>(
      0,
      (sum, collection) => sum + (collection.totalAmount ?? 0),
    );

    final uniqueTrips =
        collections
            .where((collection) => collection.trip?.id != null)
            .map((collection) => collection.trip!.id!)
            .toSet()
            .length;

    // Calculate average collection amount
    final averageAmount =
        totalCollections > 0 ? totalAmount / totalCollections : 0.0;

    // Format currency
    final currencyFormatter = NumberFormat.currency(
      symbol: '₱',
      decimalDigits: 2,
    );

    // Build date range label
    String dateRangeLabel = 'All Time';
    if (selectedStartDate != null && selectedEndDate != null) {
      dateRangeLabel =
          '${DateFormat('MMM dd, yyyy').format(selectedStartDate!)} - ${DateFormat('MMM dd, yyyy').format(selectedEndDate!)}';
    }

    return DashboardSummary(
      isLoading: isLoading,
      headerContent: _buildDateFilterHeader(context, dateRangeLabel),
      items: [
        // Total Collections
        DashboardInfoItem(
          icon: Icons.collections_bookmark,
          value: totalCollections.toString(),
          label: 'Total Collections',
          iconColor: Colors.blue,
        ),

        // Total Collection Amount
        DashboardInfoItem(
          icon: Icons.monetization_on,
          value: currencyFormatter.format(totalAmount),
          label: 'Total Collection Amount',
          iconColor: Colors.green,
        ),

        // Unique Trips
        DashboardInfoItem(
          icon: Icons.local_shipping,
          value: uniqueTrips.toString(),
          label: 'Trips Completed',
          iconColor: Colors.purple,
        ),

        // Average Collection Amount
        DashboardInfoItem(
          icon: Icons.trending_up,
          value: currencyFormatter.format(averageAmount),
          label: 'Average Collection',
          iconColor: Colors.indigo,
        ),
      ],
      crossAxisCount: 3,
      childAspectRatio: 3.0,
    );
  }

  Widget _buildDateFilterHeader(BuildContext context, String dateRangeLabel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
      child: Row(
        children: [
          // Date filter button with calendar icon
          InkWell(
            onTap: onDateFilterTap,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color:
                    isDateFiltered
                        ? Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.08)
                        : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color:
                      isDateFiltered
                          ? Theme.of(
                            context,
                          ).colorScheme.primary.withOpacity(0.3)
                          : Colors.grey.shade300,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 18,
                    color:
                        isDateFiltered
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey.shade600,
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isDateFiltered
                            ? 'Filtered Period'
                            : 'Select Date Range',
                        style: TextStyle(
                          fontSize: 11,
                          color:
                              isDateFiltered
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.grey.shade500,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        dateRangeLabel,
                        style: TextStyle(
                          fontSize: 13,
                          color:
                              isDateFiltered
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.grey.shade800,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  if (isDateFiltered) ...[
                    const SizedBox(width: 8),
                    Icon(
                      Icons.filter_alt,
                      size: 14,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ],
                ],
              ),
            ),
          ),
          const Spacer(),
          // Clear filter button
          if (isDateFiltered && onClearFilter != null)
            TextButton.icon(
              onPressed: onClearFilter,
              icon: const Icon(Icons.clear_all, size: 16),
              label: const Text('Show All'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey.shade600,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLoadingSkeleton(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title skeleton
            Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                width: 250,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Grid of skeleton items
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 3.0,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: List.generate(
                6,
                (index) => _buildDashboardSkeletonItem(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardSkeletonItem(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Row(
        children: [
          // Icon placeholder
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(width: 16),

          // Content placeholder
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Value placeholder
                Container(
                  width: double.infinity,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),

                // Label placeholder
                Container(
                  width: 100,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
