import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/invoice/domain/entity/invoice_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/widgets/app_structure/desktop_header.dart';
import 'package:flutter/material.dart';

class InvoiceHeaderWidget extends StatelessWidget {
  final InvoiceEntity invoice;
  final VoidCallback? onEditPressed;
  final VoidCallback? onOptionsPressed;

  const InvoiceHeaderWidget({
    super.key,
    required this.invoice,
    this.onEditPressed,
    this.onOptionsPressed,
  });

  @override
  Widget build(BuildContext context) {
    return DetailedDesktopHeader(
      title: 'Invoice',
      subtitle: invoice.invoiceNumber ?? 'N/A',
      description: 'Customer: ${invoice.customer?.storeName ?? 'N/A'} | Trip: ${invoice.trip?.tripNumberId ?? 'N/A'}',
      leadingIcon: const Icon(Icons.receipt_long, size: 32),
      actions: [
        if (onEditPressed != null)
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit Invoice',
            onPressed: onEditPressed,
          ),
        if (onOptionsPressed != null)
          IconButton(
            icon: const Icon(Icons.more_vert),
            tooltip: 'More Options',
            onPressed: onOptionsPressed,
          ),
      ],
      backgroundColor: Theme.of(context).cardColor,
      padding: const EdgeInsets.all(16.0),
    );
  }
}
