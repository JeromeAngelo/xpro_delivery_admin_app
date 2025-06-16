import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/collection/domain/entity/collection_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/widgets/app_structure/desktop_header.dart';
import 'package:flutter/material.dart';

class CompletedCustomerHeaderWidget extends StatelessWidget {
  final CollectionEntity customer;
  final VoidCallback? onPrintReceipt;

  const CompletedCustomerHeaderWidget({
    super.key,
    required this.customer,
    this.onPrintReceipt,
  });

  @override
  Widget build(BuildContext context) {
    return DetailedDesktopHeader(
      title: 'Customer',
      subtitle: customer.customer!.name ?? 'N/A',
      description: _buildDescription(),
      leadingIcon: const Icon(Icons.store, size: 32, color: Colors.green),
      actions: [
        if (onPrintReceipt != null)
          IconButton(
            icon: const Icon(Icons.print),
            tooltip: 'Print Receipt',
            onPressed: onPrintReceipt,
          ),
      ],
      //backgroundColor: const Color.fromARGB(255, 37, 36, 36),
      padding: const EdgeInsets.all(20),
    );
  }

  String _buildDescription() {
    final address = [
      customer.customer!.municipality,
      customer.customer!.province,
    ].where((element) => element != null && element.isNotEmpty).join(', ');

    return 'Owner: ${customer.customer!.name ?? 'N/A'} | $address';
  }
}
