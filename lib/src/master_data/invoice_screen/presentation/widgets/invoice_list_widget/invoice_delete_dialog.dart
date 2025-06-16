
import 'package:flutter/material.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/invoice_data/domain/entity/invoice_data_entity.dart';

Future<void> showInvoiceDeleteDialog(
  BuildContext context,
  InvoiceDataEntity invoice,
) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: const Text('Confirm Delete'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text('Are you sure you want to delete Invoice ${invoice.name}?'),
              const SizedBox(height: 10),
              const Text('This action cannot be undone.'),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(dialogContext).pop();
            },
          ),
          TextButton(
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
            onPressed: () {
              Navigator.of(dialogContext).pop();
              if (invoice.id != null) {
           //     context.read<InvoiceDataBloc>().add(DeleteInvoi(invoice.id!));
              }
            },
          ),
        ],
      );
    },
  );
}
