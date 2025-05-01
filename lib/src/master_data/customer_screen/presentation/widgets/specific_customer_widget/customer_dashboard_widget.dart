import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/customer/domain/entity/customer_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/widgets/app_structure/data_dashboard.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class CustomerDashboardWidget extends StatelessWidget {
  final CustomerEntity customer;
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

    // Get the latest delivery status
    String deliveryStatus = "No Status";
    if (customer.deliveryStatus.isNotEmpty) {
      // Get the last (most recent) status update
      deliveryStatus = customer.deliveryStatus.last.title ?? "No Status";
    }

    return DashboardSummary(
      title: 'Customer Details',
      detailId: customer.storeName ?? 'N/A',
      items: [
        DashboardInfoItem(
          icon: Icons.person,
          value: customer.ownerName ?? 'N/A',
          label: 'Owner Name',
          iconColor: Colors.orange,
        ),
        DashboardInfoItem(
          icon: Icons.location_on,
          value: _formatAddress(),
          label: 'Address',
          iconColor: Colors.red,
        ),
        DashboardInfoItem(
          icon: Icons.receipt,
          value: customer.invoices.length.toString(),
          label: 'Number of Invoices',
          iconColor: Colors.green,
        ),
        DashboardInfoItem(
          icon: Icons.phone,
          value: _formatContacts(),
          label: 'Contact Numbers',
          iconColor: Colors.green,
        ),
        DashboardInfoItem(
          icon: Icons.receipt_long,
          value: customer.deliveryNumber ?? 'N/A',
          label: 'Delivery Number',
          iconColor: Colors.purple,
        ),
        DashboardInfoItem(
          icon: Icons.payment,
          value: customer.modeOfPayment ?? 'N/A',
          label: 'Payment Mode',
          iconColor: Colors.teal,
        ),
        DashboardInfoItem(
          icon: Icons.attach_money,
          value: _formatAmount(customer.totalAmount),
          label: 'Total Amount',
          iconColor: Colors.amber,
        ),
        // Added delivery status item
        DashboardInfoItem(
          icon: Icons.local_shipping,
          value: deliveryStatus,
          label: 'Delivery Status',
          iconColor: _getStatusColor(deliveryStatus),
        ),
        DashboardInfoItem(
          icon: Icons.numbers,
          value: customer.trip?.tripNumberId ?? 'n/a',
          label: 'Trip Number ID',
          iconColor: _getStatusColor(deliveryStatus),
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
                9, // Same number as actual items
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
          customer.address,
          customer.municipality,
          customer.province,
        ].where((part) => part != null && part.isNotEmpty).toList();

    return parts.join(', ');
  }

  String _formatContacts() {
    if (customer.contactNumber == null || customer.contactNumber!.isEmpty) {
      return 'No contacts';
    }
    return customer.contactNumber!.join(', ');
  }

  String _formatAmount(dynamic amount) {
    if (amount == null) return 'N/A';

    if (amount is double) {
      return '₱${amount.toStringAsFixed(2)}';
    } else if (amount is String) {
      try {
        final numAmount = double.parse(amount);
        return '₱${numAmount.toStringAsFixed(2)}';
      } catch (_) {
        return '₱$amount';
      }
    }

    return '₱$amount';
  }

  // Helper method to get appropriate color for status
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'arrived':
        return Colors.blue;
      case 'unloading':
        return Colors.amber;
      case 'undelivered':
      case 'mark as undelivered':
        return Colors.red;
      case 'in transit':
        return Colors.indigo;
      case 'delivered':
        return Colors.green;
      case 'received':
      case 'mark as received':
        return Colors.teal;
      case 'completed':
      case 'end delivery':
        return Colors.green.shade800;
      case 'pending':
      default:
        return Colors.orange;
    }
  }
}
