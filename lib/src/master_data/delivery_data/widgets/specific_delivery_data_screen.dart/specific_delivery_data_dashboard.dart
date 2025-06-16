import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/delivery_data/domain/entity/delivery_data_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/widgets/app_structure/data_dashboard.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class DeliveryDataDashboardWidget extends StatelessWidget {
  final DeliveryDataEntity delivery;
  final bool isLoading;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const DeliveryDataDashboardWidget({
    super.key,
    required this.delivery,
    this.isLoading = false,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildLoadingSkeleton(context);
    }

    return DashboardSummary(
      title: 'Delivery Details',
      detailId: delivery.deliveryNumber ?? 'N/A',
      onEdit: onEdit,
      onDelete: onDelete,
      items: [
        DashboardInfoItem(
          icon: Icons.local_shipping,
          value: delivery.deliveryNumber ?? 'N/A',
          label: 'Delivery Number',
          iconColor: Colors.blue,
        ),
        DashboardInfoItem(
          icon: Icons.person,
          value: delivery.customer?.name ?? 'No Customer',
          label: 'Customer Name',
          iconColor: Colors.orange,
        ),
        DashboardInfoItem(
          icon: Icons.receipt_long,
          value: delivery.invoice?.name ?? 'No Invoice',
          label: 'Invoice Number',
          iconColor: Colors.green,
        ),
        DashboardInfoItem(
          icon: Icons.location_on,
          value: _formatAddress(),
          label: 'Delivery Address',
          iconColor: Colors.red,
        ),
        DashboardInfoItem(
          icon: Icons.route,
          value: delivery.trip?.tripNumberId ?? 'No Trip Assigned',
          label: 'Trip Number',
          iconColor: delivery.trip != null ? Colors.blue : Colors.grey,
        ),
        DashboardInfoItem(
          icon: Icons.check_circle,
          value: _getDeliveryStatus(),
          label: 'Delivery Status',
          iconColor: _getStatusColor(),
        ),
        DashboardInfoItem(
          icon: Icons.inventory,
          value: '${delivery.invoiceItems?.length ?? 0}',
          label: 'Total Items',
          iconColor: Colors.purple,
        ),
        DashboardInfoItem(
          icon: Icons.attach_money,
          value:
              delivery.invoice?.totalAmount != null
                  ? '₱${delivery.invoice!.totalAmount}'
                  : 'N/A',
          label: 'Invoice Amount',
          iconColor: Colors.green,
        ),
        DashboardInfoItem(
          icon: Icons.calendar_today,
          value: _formatDate(delivery.created),
          label: 'Created Date',
          iconColor: Colors.teal,
        ),
        DashboardInfoItem(
          icon: Icons.update,
          value: _formatDate(delivery.updated),
          label: 'Last Updated',
          iconColor: Colors.indigo,
        ),
        DashboardInfoItem(
          icon: Icons.map,
          value: _formatCoordinates(),
          label: 'Coordinates',
          iconColor: Colors.cyan,
        ),
        DashboardInfoItem(
          icon: Icons.assignment,
          value: delivery.hasTrip == true ? 'Yes' : 'No',
          label: 'Has Trip Assignment',
          iconColor: delivery.hasTrip == true ? Colors.green : Colors.orange,
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
                12, // Same number as actual items
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
    final parts =
        [
          delivery.customer?.barangay,
          delivery.customer?.municipality,
          delivery.customer?.province,
        ].where((part) => part != null && part.isNotEmpty).toList();

    return parts.isEmpty ? 'No address available' : parts.join(', ');
  }

  String _formatCoordinates() {
    if (delivery.customer?.latitude != null &&
        delivery.customer?.longitude != null) {
      return '${delivery.customer!.latitude!.toStringAsFixed(6)}, ${delivery.customer!.longitude!.toStringAsFixed(6)}';
    }
    return 'No coordinates available';
  }

  String _getDeliveryStatus() {
    if (delivery.hasTrip == true && delivery.trip != null) {
      if (delivery.trip!.isEndTrip == true) {
        return 'Delivered';
      } else if (delivery.trip!.isAccepted == true) {
        return 'In Transit';
      } else {
        return 'Assigned';
      }
    }
    return 'Pending';
  }

  Color _getStatusColor() {
    if (delivery.hasTrip == true && delivery.trip != null) {
      if (delivery.trip!.isEndTrip == true) {
        return Colors.green;
      } else if (delivery.trip!.isAccepted == true) {
        return Colors.blue;
      } else {
        return Colors.orange;
      }
    }
    return Colors.grey;
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
