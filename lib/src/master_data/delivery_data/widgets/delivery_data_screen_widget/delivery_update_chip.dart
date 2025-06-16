import 'package:flutter/material.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/delivery_data/domain/entity/delivery_data_entity.dart';

class DeliveryDataStatusChip extends StatelessWidget {
  final DeliveryDataEntity delivery;

  const DeliveryDataStatusChip({
    super.key,
    required this.delivery,
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    String status;
    IconData icon;
    
    if (delivery.hasTrip == true && delivery.trip != null) {
      // Check if trip is completed
      if (delivery.trip!.isEndTrip == true) {
        color = Colors.green;
        status = 'Delivered';
        icon = Icons.check_circle;
      } else if (delivery.trip!.isAccepted == true) {
        color = Colors.blue;
        status = 'In Transit';
        icon = Icons.local_shipping;
      } else {
        color = Colors.orange;
        status = 'Assigned';
        icon = Icons.assignment;
      }
    } else {
      color = Colors.grey;
      status = 'Pending';
      icon = Icons.pending;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            status,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
