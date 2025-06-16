import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/customer_data/domain/entity/customer_data_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/widgets/app_structure/data_dashboard.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class CustomerDashboardWidget extends StatelessWidget {
  final CustomerDataEntity customer;
  final bool isLoading;

  const CustomerDashboardWidget({
    super.key,
    required this.customer,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildLoadingSkeleton(context);
    }

    return DashboardSummary(
      title: 'Customer Details',
      detailId: customer.name ?? 'N/A',
      items: [
        DashboardInfoItem(
          icon: Icons.person,
          value: customer.name ?? 'N/A',
          label: 'Customer Name',
          iconColor: Colors.orange,
        ),
        DashboardInfoItem(
          icon: Icons.location_on,
          value: _formatAddress(),
          label: 'Address',
          iconColor: Colors.red,
        ),
        DashboardInfoItem(
          icon: Icons.numbers,
          value: customer.refId ?? 'N/A',
          label: 'Reference ID',
          iconColor: Colors.green,
        ),
        DashboardInfoItem(
          icon: Icons.map,
          value: _formatCoordinates(),
          label: 'Coordinates',
          iconColor: Colors.blue,
        ),
        DashboardInfoItem(
          icon: Icons.calendar_today,
          value: _formatDate(customer.created),
          label: 'Created Date',
          iconColor: Colors.purple,
        ),
        DashboardInfoItem(
          icon: Icons.update,
          value: _formatDate(customer.updated),
          label: 'Last Updated',
          iconColor: Colors.teal,
        ),
      ],
    );
  }

  Widget _buildLoadingSkeleton(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and detail ID skeleton
            Row(
              children: [
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    width: 180,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    width: 120,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
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
                6, // Same number as actual items
                (index) => _buildDashboardItemSkeleton(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardItemSkeleton(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
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
      ),
    );
  }

  String _formatAddress() {
    final parts = [
      customer.barangay,
      customer.municipality,
      customer.province,
    ].where((part) => part != null && part.isNotEmpty).toList();

    return parts.isEmpty ? 'No address available' : parts.join(', ');
  }

  String _formatCoordinates() {
    if (customer.latitude != null && customer.longitude != null) {
      return '${customer.latitude!.toStringAsFixed(6)}, ${customer.longitude!.toStringAsFixed(6)}';
    }
    return 'No coordinates available';
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Just now';
        }
        return '${difference.inMinutes} minutes ago';
      }
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      // Format as date
      final day = date.day.toString().padLeft(2, '0');
      final month = date.month.toString().padLeft(2, '0');
      final year = date.year;
      return '$day/$month/$year';
    }
  }
}
