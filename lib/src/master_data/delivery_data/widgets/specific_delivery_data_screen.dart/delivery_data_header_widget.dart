import 'package:flutter/material.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/delivery_data/domain/entity/delivery_data_entity.dart';

class DeliveryDataHeaderWidget extends StatelessWidget {
  final DeliveryDataEntity delivery;
  final VoidCallback? onEditPressed;
  final VoidCallback? onOptionsPressed;
  final VoidCallback? onBackPressed;

  const DeliveryDataHeaderWidget({
    super.key,
    required this.delivery,
    this.onEditPressed,
    this.onOptionsPressed,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).primaryColor.withOpacity(0.1),
            Theme.of(context).primaryColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row with back button and actions
          Row(
            children: [
              if (onBackPressed != null)
                IconButton(
                  onPressed: onBackPressed,
                  icon: const Icon(Icons.arrow_back),
                  tooltip: 'Back to Delivery List',
                ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Delivery Details',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      delivery.deliveryNumber ?? 'No Delivery Number',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              // Action buttons
              Row(
                children: [
                  if (onEditPressed != null)
                    ElevatedButton.icon(
                      onPressed: onEditPressed,
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text('Edit'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                    ),
                  const SizedBox(width: 12),
                  if (onOptionsPressed != null)
                    ElevatedButton.icon(
                      onPressed: onOptionsPressed,
                      icon: const Icon(Icons.more_vert, size: 18),
                      label: const Text('Options'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Quick info cards
          Row(
            children: [
              Expanded(
                child: _buildQuickInfoCard(
                  context,
                  icon: Icons.person,
                  title: 'Customer',
                  value: delivery.customer?.name ?? 'No Customer',
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildQuickInfoCard(
                  context,
                  icon: Icons.receipt_long,
                  title: 'Invoice',
                  value: delivery.invoice?.name ?? 'No Invoice',
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildQuickInfoCard(
                  context,
                  icon: Icons.route,
                  title: 'Trip',
                  value: delivery.trip?.tripNumberId ?? 'No Trip',
                  color: delivery.trip != null ? Colors.purple : Colors.grey,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildQuickInfoCard(
                  context,
                  icon: Icons.check_circle,
                  title: 'Status',
                  value: _getDeliveryStatus(),
                  color: _getStatusColor(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickInfoCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
           decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
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
}

