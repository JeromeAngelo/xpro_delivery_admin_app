import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/cancelled_invoices/domain/entity/cancelled_invoice_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/cancelled_invoices/presentation/bloc/cancelled_invoice_bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/cancelled_invoices/presentation/bloc/cancelled_invoice_event.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/cancelled_invoices/presentation/bloc/cancelled_invoice_state.dart';

class CancelledInvoiceHeaderWidget extends StatelessWidget {
  final CancelledInvoiceEntity cancelledInvoice;
  final VoidCallback? onEditPressed;
  final VoidCallback? onDeletePressed;
  final VoidCallback? onViewImagePressed;

  const CancelledInvoiceHeaderWidget({
    super.key,
    required this.cancelledInvoice,
    this.onEditPressed,
    this.onDeletePressed,
    this.onViewImagePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cancelled Invoice',
                        style: Theme.of(
                          context,
                        ).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.red[700],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        cancelledInvoice.invoice?.name ?? 'N/A',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                // Action Buttons
                Row(
                  children: [
                    // Re-assign to Trip Button
                    BlocConsumer<CancelledInvoiceBloc, CancelledInvoiceState>(
                      listener: (context, state) {
                        if (state is CancelledInvoiceTripReassigned) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Successfully reassigned to trip for delivery: ${state.deliveryDataId}',
                              ),
                              backgroundColor: Colors.green,
                            ),
                          );
                          context.go('/tripticket-create');
                        } else if (state is CancelledInvoiceError) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error: ${state.message}'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      builder: (context, state) {
                        final isLoading = state is CancelledInvoiceLoading;

                        return ElevatedButton.icon(
                          onPressed:
                              isLoading
                                  ? null
                                  : () => _showReassignDialog(context),
                          icon:
                              isLoading
                                  ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : const Icon(Icons.assignment_return),
                          label: const Text('Re-assign to Trip'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 8),

                    // View Image Button
                    if (cancelledInvoice.image != null &&
                        cancelledInvoice.image!.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.image),
                        tooltip: 'View Image',
                        onPressed: onViewImagePressed,
                        style: IconButton.styleFrom(
                          foregroundColor:
                              Theme.of(context).colorScheme.primary,
                        ),
                      ),

                    // Edit Button
                    if (onEditPressed != null)
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        tooltip: 'Edit',
                        onPressed: onEditPressed,
                        style: IconButton.styleFrom(
                          foregroundColor:
                              Theme.of(context).colorScheme.primary,
                        ),
                      ),

                    // Delete Button
                    if (onDeletePressed != null)
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        tooltip: 'Delete',
                        onPressed: onDeletePressed,
                        style: IconButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                      ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Status and Info Row
            Row(
              children: [
                // Cancellation Reason Chip
                Chip(
                  label: Text(
                    cancelledInvoice.reason?.name ?? 'No Reason',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  backgroundColor: Colors.red[600],
                ),

                const SizedBox(width: 16),

                // Customer Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Customer: ${cancelledInvoice.customer?.name ?? 'Unknown'}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'Store: ${cancelledInvoice.customer?.ownerName ?? 'N/A'}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),

                // Amount Info
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Amount',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    Text(
                      '₱${cancelledInvoice.invoice?.totalAmount?.toStringAsFixed(2) ?? '0.00'}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.red[700],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showReassignDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Re-assign to Trip'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Are you sure you want to re-assign this cancelled invoice back to the trip?',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Invoice: ${cancelledInvoice.invoice?.name ?? 'N/A'}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Customer: ${cancelledInvoice.customer?.name ?? 'N/A'}',
                    ),
                    Text(
                      'Trip: ${cancelledInvoice.trip?.tripNumberId ?? 'N/A'}',
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _reassignToTrip(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text('Re-assign'),
            ),
          ],
        );
      },
    );
  }

  void _reassignToTrip(BuildContext context) {
    if (cancelledInvoice.deliveryData?.id != null) {
      context.read<CancelledInvoiceBloc>().add(
        ReassignTripForCancelledInvoiceEvent(
          cancelledInvoice.deliveryData!.id!,
        ),
      );

      context.go('/tripticket-create');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: No delivery data ID found'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
