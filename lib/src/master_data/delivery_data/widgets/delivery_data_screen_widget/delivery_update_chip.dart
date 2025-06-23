import 'package:flutter/material.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/delivery_data/domain/entity/delivery_data_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/widgets/app_structure/status_icons.dart';

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
    
    // Get the latest delivery update status
    if (delivery.deliveryUpdates.isNotEmpty) {
      // Sort delivery updates by time to get the latest one
      final sortedUpdates = List.from(delivery.deliveryUpdates);
      sortedUpdates.sort((a, b) {
        final timeA = a.time ?? a.created ?? DateTime.now();
        final timeB = b.time ?? b.created ?? DateTime.now();
        return timeB.compareTo(timeA); // Latest first
      });
      
      final latestUpdate = sortedUpdates.first;
      final updateTitle = latestUpdate.title?.toLowerCase() ?? '';
      
      // Determine status based on delivery update title
      switch (updateTitle) {
        case 'arrived':
          color = Colors.blue;
          status = 'Arrived';
          icon = StatusIcons.getStatusIcon('arrived');
          break;
        case 'unloading':
          color = Colors.orange;
          status = 'Unloading';
          icon = StatusIcons.getStatusIcon('unloading');
          break;
        case 'mark as undelivered':
          color = Colors.red;
          status = 'Undelivered';
          icon = StatusIcons.getStatusIcon('mark as undelivered');
          break;
        case 'in transit':
          color = Colors.purple;
          status = 'In Transit';
          icon = StatusIcons.getStatusIcon('in transit');
          break;
        case 'pending':
          color = Colors.grey;
          status = 'Pending';
          icon = StatusIcons.getStatusIcon('pending');
          break;
        case 'mark as received':
          color = Colors.green;
          status = 'Received';
          icon = StatusIcons.getStatusIcon('mark as received');
          break;
        case 'end delivery':
          color = Colors.teal;
          status = 'Delivered';
          icon = StatusIcons.getStatusIcon('end delivery');
          break;
        default:
          color = Colors.amber;
          status = latestUpdate.title ?? 'Unknown';
          icon = StatusIcons.getStatusIcon('default');
          break;
      }
    } else {
      // No delivery updates available
      color = Colors.grey;
      status = 'No Updates';
      icon = StatusIcons.getStatusIcon('pending');
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
