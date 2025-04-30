import 'package:desktop_app/core/common/app/features/Trip_Ticket/customer/domain/entity/customer_entity.dart';
import 'package:desktop_app/src/delivery_monitoring/presentation/widgets/delivery_status_icon.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CustomerInformationTile extends StatelessWidget {
  const CustomerInformationTile({super.key, required this.customer});
  final CustomerEntity customer;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with store name
          Center(
            child: Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            customer.storeName ?? 'Unknown Store',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Delivery #: ${customer.deliveryNumber ?? 'N/A'}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const Divider(height: 32),
          _buildDetailItem(
            context,
            'Trip ID',
            customer.trip!.tripNumberId ?? 'N/A',
            Icons.receipt_long,
          ),
          // _buildDetailItem(
          //   context,
          //   'Team Leader',
          //   customer.trip!.user!.name ?? 'N/A',
          //   Icons.verified_user,
          // ),
          // Customer details
          _buildDetailItem(
            context,
            'Owner',
            customer.ownerName ?? 'N/A',
            Icons.person,
          ),
          _buildDetailItem(
            context,
            'Contact',
            customer.contactNumber?.join(', ') ?? 'N/A',
            Icons.phone,
          ),
          _buildDetailItem(
            context,
            'Address',
            '${customer.address ?? ''}, ${customer.municipality ?? ''}, ${customer.province ?? ''}',
            Icons.location_on,
          ),
          _buildDetailItem(
            context,
            'Payment Mode',
            customer.modeOfPayment ?? 'N/A',
            Icons.payment,
          ),
          _buildDetailItem(
            context,
            'Total Amount',
            '₱${customer.totalAmount}',
            Icons.attach_money,
          ),

          const Divider(height: 32),

          // Delivery status history
          Text(
            'Delivery Status History',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          if (customer.deliveryStatus.isEmpty)
            const Text('No status updates available')
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: customer.deliveryStatus.length,
              itemBuilder: (context, index) {
                final status = customer.deliveryStatus[index];
                final statusData = DeliveryStatusData.fromName(
                  status.title ?? 'Unknown',
                );

                return ListTile(
                  leading: Icon(statusData.icon, color: statusData.color),
                  title: Text(status.title ?? 'Unknown Status'),
                  subtitle: Text(status.subtitle ?? ''),
                  trailing: Text(
                    status.time != null ? _formatDateTime(status.time) : '',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                );
              },
            ),

          const SizedBox(height: 24),

          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  if (customer.trip!.id != null) {
                    context.go('/tripticket/${customer.trip!.id}');
                  }
                },
                icon: const Icon(Icons.visibility),
                label: const Text('View Trip Details'),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  if (customer.id != null) {
                    context.go('/customer/${customer.id}');
                  }
                },
                icon: const Icon(Icons.visibility),
                label: const Text('View Customer Details'),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  // Navigate to update status screen

                  context.pop('/delivery-monitoring');
                },
                icon: const Icon(Icons.close),
                label: const Text('Close'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDateTime(dynamic dateTime) {
    if (dateTime == null) return '';

    try {
      // If it's already a DateTime
      if (dateTime is DateTime) {
        return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
      }

      // If it's a String, try to parse it
      if (dateTime is String) {
        final parsedDate = DateTime.tryParse(dateTime);
        if (parsedDate != null) {
          return '${parsedDate.day}/${parsedDate.month}/${parsedDate.year} ${parsedDate.hour}:${parsedDate.minute.toString().padLeft(2, '0')}';
        }
        return dateTime; // Return the original string if parsing fails
      }

      // For any other type, convert to string
      return dateTime.toString();
    } catch (e) {
      return '';
    }
  }

  Widget _buildDetailItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                ),
                const SizedBox(height: 2),
                Text(value, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
