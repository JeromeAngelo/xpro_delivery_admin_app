import 'package:desktop_app/core/common/app/features/Trip_Ticket/completed_customer/domain/entity/completed_customer_entity.dart';
import 'package:desktop_app/core/common/widgets/app_structure/desktop_header.dart';
import 'package:flutter/material.dart';

class CompletedCustomerHeaderWidget extends StatelessWidget {
  final CompletedCustomerEntity customer;
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
      subtitle: customer.storeName ?? 'N/A',
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
      backgroundColor: const Color.fromARGB(255, 37, 36, 36),
      padding: const EdgeInsets.all(20),
    );
  }

  String _buildDescription() {
    final address = [
      customer.address,
      customer.municipality,
      customer.province,
    ].where((element) => element != null && element.isNotEmpty).join(', ');

    return 'Owner: ${customer.ownerName ?? 'N/A'} | $address';
  }
}
