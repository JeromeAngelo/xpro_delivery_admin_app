import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/return_product/domain/entity/return_entity.dart';
import 'package:xpro_delivery_admin_app/core/enums/product_return_reason.dart';
import 'package:flutter/material.dart';

class ReturnStatusChip extends StatelessWidget {
  final ReturnEntity returnItem;

  const ReturnStatusChip({
    super.key,
    required this.returnItem,
  });

  @override
  Widget build(BuildContext context) {
    final reason = returnItem.reason;
    
    // Default values
    Color color = Colors.grey;
    String label = 'Unknown';
    
    if (reason != null) {
      switch (reason) {
        case ProductReturnReason.expired:
          color = Colors.red;
          label = 'Expired';
          break;
        case ProductReturnReason.damaged:
          color = Colors.orange;
          label = 'Damaged';
          break;
        case ProductReturnReason.wrongProduct:
          color = Colors.purple;
          label = 'Wrong Product';
          break;
        case ProductReturnReason.wrongQuantity:
          color = Colors.blue;
          label = 'Wrong Quantity';
          break;
        case ProductReturnReason.dented:
          color = Colors.amber;
          label = 'Dented';
          break;
          case ProductReturnReason.rescheduled:
          color = Colors.green;
          label = 'Rescheduled';
        case ProductReturnReason.other:
          color = Colors.teal;
          label = 'Other';
          break;
        case ProductReturnReason.none:
          color = Colors.grey;
          label = 'None';
          break;
      }
    }

    return Chip(
      label: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: color,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      visualDensity: VisualDensity.compact,
    );
  }
}
