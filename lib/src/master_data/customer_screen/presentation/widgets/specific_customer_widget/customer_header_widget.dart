import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/customer/domain/entity/customer_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/widgets/app_structure/desktop_header.dart';
import 'package:flutter/material.dart';

class CustomerHeaderWidget extends StatelessWidget {
  final CustomerEntity customer;
  final VoidCallback? onEditPressed;
  final VoidCallback? onOptionsPressed;

  const CustomerHeaderWidget({
    super.key,
    required this.customer,
    this.onEditPressed,
    this.onOptionsPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Store Name Header
            DetailedDesktopHeader(
              title: 'Store',
              subtitle: customer.storeName ?? 'N/A',
              leadingIcon: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.store, size: 24, color: Colors.blue),
              ),
              actions: [
                if (onOptionsPressed != null)
                  IconButton(
                    icon: const Icon(Icons.more_vert),
                    tooltip: 'More Options',
                    onPressed: onOptionsPressed,
                  ),
                if (onEditPressed != null)
                  IconButton(
                    icon: const Icon(Icons.edit),
                    tooltip: 'Edit Customer',
                    onPressed: onEditPressed,
                  ),
              ],
              showDivider: false,
            ),
          ],
        ),
      ),
    );
  }
}
