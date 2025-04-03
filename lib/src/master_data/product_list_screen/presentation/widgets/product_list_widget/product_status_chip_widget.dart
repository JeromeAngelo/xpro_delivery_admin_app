import 'package:flutter/material.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/products/domain/entity/product_entity.dart';
import 'package:desktop_app/core/enums/products_status.dart';

class ProductStatusChip extends StatelessWidget {
  final ProductEntity product;

  const ProductStatusChip({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    String status;

    switch (product.status) {
      case ProductsStatus.truck:
        color = Colors.blue;
        status = 'In Truck';
        break;
      case ProductsStatus.unloading:
        color = Colors.orange;
        status = 'Unloading';
        break;
      case ProductsStatus.unloaded:
        color = Colors.amber;
        status = 'Unloaded';
        break;
      case ProductsStatus.completed:
        color = Colors.green;
        status = 'Completed';
        break;
      default:
        color = Colors.grey;
        status = 'Unknown';
    }

    return Chip(
      label: Text(
        status,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: color,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      visualDensity: VisualDensity.compact,
    );
  }
}
