import 'package:flutter/material.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/delivery_data/domain/entity/delivery_data_entity.dart';
import 'package:xpro_delivery_admin_app/src/delivery_monitoring/presentation/widgets/customer_tile.dart';

class StatusContainer extends StatelessWidget {
  final String statusName;
  final String subtitle;
  final IconData statusIcon;
  final Color statusColor;
  final List<DeliveryDataEntity> deliveryDataList;
  final Function(DeliveryDataEntity) onDeliveryDataTap;

  const StatusContainer({
    super.key,
    required this.statusName,
    required this.statusIcon,
    required this.statusColor,
    required this.deliveryDataList,
    required this.onDeliveryDataTap,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                border: Border(
                  bottom: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Icon(statusIcon, color: statusColor, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          statusName,
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.surface,
                          ),
                        ),
                        Text(
                          subtitle,
                          style: Theme.of(
                            context,
                          ).textTheme.titleSmall?.copyWith(
                            //fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.surface,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${deliveryDataList.length}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.surface,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Delivery data list
            if (deliveryDataList.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      SizedBox(height: 250),
                      Icon(Icons.inbox, size: 48, color: Colors.grey[400]),
                      const SizedBox(height: 8),
                      Text(
                        'No deliveries in this status',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: deliveryDataList.length,
                  itemBuilder: (context, index) {
                    return CustomerTile(
                      deliveryData: deliveryDataList[index],
                      borderColor: statusColor.withOpacity(0.5),
                      onTap: () => onDeliveryDataTap(deliveryDataList[index]),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
