
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/customer_data/domain/entity/customer_data_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/delivery_data/presentation/bloc/delivery_data_bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/delivery_data/presentation/bloc/delivery_data_event.dart';

void showCustomerOptionsDialog(
  BuildContext context,
  CustomerDataEntity customer,
) {
  showDialog(
    context: context,
    builder:
        (context) => AlertDialog(
          title: Text('Options for ${customer.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildOptionTile(
                context,
                icon: Icons.edit,
                title: 'Edit Customer',
                subtitle: 'Modify customer details',
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to edit customer screen
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Edit customer feature coming soon'),
                    ),
                  );
                },
              ),
              _buildOptionTile(
                context,
                icon: Icons.delete,
                title: 'Delete Customer',
                subtitle: 'Remove this customer',
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteConfirmationDialog(context, customer);
                },
              ),
              _buildOptionTile(
                context,
                icon: Icons.print,
                title: 'Print Details',
                subtitle: 'Print customer information',
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Print feature coming soon')),
                  );
                },
              ),
              _buildOptionTile(
                context,
                icon: Icons.share,
                title: 'Share Details',
                subtitle: 'Share customer information',
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Share feature coming soon')),
                  );
                },
              ),
              _buildOptionTile(
                context,
                icon: Icons.history,
                title: 'View History',
                subtitle: 'See customer transaction history',
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('History feature coming soon'),
                    ),
                  );
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        ),
  );
}

Widget _buildOptionTile(
  BuildContext context, {
  required IconData icon,
  required String title,
  required String subtitle,
  required VoidCallback onTap,
  Color? iconColor,
}) {
  return ListTile(
    leading: Icon(icon, color: iconColor ?? Theme.of(context).primaryColor),
    title: Text(title),
    subtitle: Text(subtitle),
    onTap: onTap,
    contentPadding: EdgeInsets.zero,
  );
}

void _showDeleteConfirmationDialog(
  BuildContext context,
  CustomerDataEntity customer,
) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: const Text('Confirm Delete'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text('Are you sure you want to delete ${customer.name}?'),
              const SizedBox(height: 10),
              const Text(
                'This action cannot be undone and will remove all associated data.',
                style: TextStyle(color: Colors.red),
              ),
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
              if (customer.id != null) {
                context.read<DeliveryDataBloc>().add(
                  DeleteDeliveryDataEvent(customer.id!),
                );

                // Navigate back to customer list
                context.go('/customers');

                // Show success message
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${customer.name} has been deleted'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
        ],
      );
    },
  );
}
