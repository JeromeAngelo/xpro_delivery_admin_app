import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/delivery_data/domain/entity/delivery_data_entity.dart';

class CustomerTile extends StatelessWidget {
  final DeliveryDataEntity deliveryData;
  final VoidCallback? onTap;
  final Color? borderColor;

  const CustomerTile({
    super.key,
    required this.deliveryData,
    this.onTap,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: borderColor ?? Colors.transparent, width: 2),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Store name with icon
              Row(
                children: [
                  Icon(
                    Icons.store,
                    size: 18,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      deliveryData.customer?.name ?? 'Unknown Store',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    deliveryData.trip?.tripNumberId ?? 'Unknown Trip',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Delivery number
              Row(
                children: [
                  Icon(
                    Icons.numbers,
                    size: 16,
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.7),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Delivery #: ${deliveryData.deliveryNumber ?? 'N/A'}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),

              const SizedBox(height: 4),

              // Address
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.7),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _formatAddress(deliveryData),
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.timelapse,
                    size: 16,
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.7),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _formatDate(_getLatestDeliveryUpdateTime(deliveryData)),
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 4),

              // Invoice count and total amount
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.receipt,
                        size: 16,
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.7),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Invoice Number: ${deliveryData.invoice?.name ?? 'N/A'}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  Text(
                    '₱${deliveryData.invoice?.totalAmount ?? 0}',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    try {
      // Change the format from "MMM dd, yyyy hh:mm a" to "MM/dd/yyyy hh:mm a"
      return DateFormat('MM/dd/yyyy hh:mm a').format(date);
    } catch (e) {
      debugPrint('❌ Error formatting date: $e');
      return 'Invalid Date';
    }
  }

  String _formatAddress(DeliveryDataEntity deliveryData) {
    final List<String> addressParts = [];

    if (deliveryData.customer?.municipality != null &&
        deliveryData.customer!.municipality!.isNotEmpty) {
      addressParts.add(deliveryData.customer!.municipality!);
    }

    if (deliveryData.customer?.province != null &&
        deliveryData.customer!.province!.isNotEmpty) {
      addressParts.add(deliveryData.customer!.province!);
    }

    return addressParts.join(', ');
  }

  DateTime? _getLatestDeliveryUpdateTime(DeliveryDataEntity deliveryData) {
    if (deliveryData.deliveryUpdates.isEmpty) return null;

    // Get the latest delivery update time
    DateTime? latestTime;
    for (final update in deliveryData.deliveryUpdates) {
      if (update.time != null) {
        if (latestTime == null || update.time!.isAfter(latestTime)) {
          latestTime = update.time;
        }
      }
    }

    return latestTime;
  }
}
