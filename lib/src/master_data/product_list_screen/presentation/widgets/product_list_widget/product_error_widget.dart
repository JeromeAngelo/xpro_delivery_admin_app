import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/invoice_items/presentation/bloc/invoice_items_bloc.dart';

import '../../../../../../core/common/app/features/Trip_Ticket/invoice_items/presentation/bloc/invoice_items_event.dart';

class ProductErrorWidget extends StatelessWidget {
  final String errorMessage;

  const ProductErrorWidget({
    super.key,
    required this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(
            'Error: $errorMessage',
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              context.read<InvoiceItemsBloc>().add(const GetAllInvoiceItemsEvent());
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
