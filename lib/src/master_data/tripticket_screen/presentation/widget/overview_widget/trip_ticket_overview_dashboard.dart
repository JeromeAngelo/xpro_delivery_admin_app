import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/trip_ticket/trip/domain/entity/trip_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/widgets/app_structure/data_dashboard.dart';
import 'package:shimmer/shimmer.dart';

class TripTicketOverviewDashboard extends StatelessWidget {
  final List<TripEntity> trips;
  final bool isLoading;
  final DateTime? selectedStartDate;
  final DateTime? selectedEndDate;
  final bool isDateFiltered;
  final VoidCallback? onDateFilterTap;
  final VoidCallback? onClearFilter;

  const TripTicketOverviewDashboard({
    super.key,
    required this.trips,
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
    final totalTrips = trips.length;
    final activeTrips =
        trips
            .where((trip) => trip.isAccepted == true && trip.isEndTrip != true)
            .length;
    final completedTrips = trips.where((trip) => trip.isEndTrip == true).length;
    final pendingTrips = trips.where((trip) => trip.isAccepted != true).length;

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
        DashboardInfoItem(
          icon: Icons.receipt_long,
          value: totalTrips.toString(),
          label: 'Total Trips',
          iconColor: Colors.blue,
        ),
        DashboardInfoItem(
          icon: Icons.directions_car,
          value: activeTrips.toString(),
          label: 'Active Trips',
          iconColor: Colors.orange,
        ),
        DashboardInfoItem(
          icon: Icons.check_circle,
          value: completedTrips.toString(),
          label: 'Completed Trips',
          iconColor: Colors.green,
        ),
        DashboardInfoItem(
          icon: Icons.pending_actions,
          value: pendingTrips.toString(),
          label: 'Pending Trips',
          iconColor: Colors.purple,
        ),
      ],
      crossAxisCount: 4,
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
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 3.0,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: List.generate(
                4,
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
