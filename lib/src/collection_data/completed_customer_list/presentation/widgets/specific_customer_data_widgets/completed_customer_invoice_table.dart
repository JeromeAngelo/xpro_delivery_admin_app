import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/collection/domain/entity/collection_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/invoice_data/presentation/bloc/invoice_data_bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/invoice_data/presentation/bloc/invoice_data_event.dart';

import 'package:xpro_delivery_admin_app/core/common/widgets/app_structure/data_table_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class CompletedCustomerInvoiceTable extends StatelessWidget {
  final List<CollectionEntity> collections;
  final bool isLoading;
  final int currentPage;
  final int totalPages;
  final Function(int) onPageChanged;
  final String? completedCustomerId;
  final String? errorMessage;
  final VoidCallback? onRetry;

  const CompletedCustomerInvoiceTable({
    super.key,
    required this.collections,
    required this.isLoading,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
    this.completedCustomerId,
    this.errorMessage,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return DataTableLayout(
      title: 'Collection Invoices',
      columns: const [
        DataColumn(label: Text('Collection Name')),
        DataColumn(label: Text('Invoice Number')),
        DataColumn(label: Text('Delivery Number')),
        DataColumn(label: Text('Date')),
        DataColumn(label: Text('Total Amount')),
        DataColumn(label: Text('Confirmed Total Amount')),
        DataColumn(label: Text('Status')),
        DataColumn(label: Text('Actions')),
      ],
      rows:
          collections.map((collection) {
            return DataRow(
              cells: [
                DataCell(
                  Text(collection.collectionName ?? 'N/A'),
                  onTap: () => _navigateToCollectionDetails(context, collection),
                ),
                DataCell(
                  Text(collection.invoice?.refId ?? 'N/A'),
                  onTap: () => _navigateToInvoiceDetails(context, collection),
                ),
                DataCell(
                  Text(collection.deliveryData?.deliveryNumber ?? 'N/A'),
                  onTap: () => _navigateToCollectionDetails(context, collection),
                ),
                DataCell(
                  Text(_formatDate(collection.created)),
                  onTap: () => _navigateToCollectionDetails(context, collection),
                ),
                DataCell(
                  Text(_formatAmount(collection.totalAmount)),
                  onTap: () => _navigateToCollectionDetails(context, collection),
                ),
                DataCell(
                  Text(_formatAmount(collection.invoice?.totalAmount)),
                  onTap: () => _navigateToCollectionDetails(context, collection),
                ),
                
                DataCell(
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.visibility, color: Colors.blue),
                        tooltip: 'View Collection Details',
                        onPressed:
                            () => _navigateToCollectionDetails(context, collection),
                      ),
                      if (collection.invoice != null)
                        IconButton(
                          icon: const Icon(Icons.receipt, color: Colors.green),
                          tooltip: 'View Invoice',
                          onPressed: () => _navigateToInvoiceDetails(context, collection),
                        ),
                      IconButton(
                        icon: const Icon(
                          Icons.picture_as_pdf,
                          color: Colors.red,
                        ),
                        tooltip: 'View PDF',
                        onPressed: () {
                          // View PDF functionality
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'PDF viewer for ${collection.collectionName ?? 'collection'} coming soon',
                              ),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.print, color: Colors.purple),
                        tooltip: 'Print Collection Receipt',
                        onPressed: () {
                          // Print functionality
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Printing receipt for ${collection.collectionName ?? 'collection'}...',
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
      currentPage: currentPage,
      totalPages: totalPages,
      onPageChanged: onPageChanged,
      isLoading: isLoading,
      errorMessage: errorMessage,
      onRetry: onRetry,
      onFiltered: () {
        // Show filter dialog for collections
        _showFilterDialog(context);
      }, 
      dataLength: '${collections.length}', 
      onDeleted: () {  },
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('MMM dd, yyyy').format(date);
  }

  String _formatAmount(double? amount) {
    if (amount == null) return 'N/A';
    final formatter = NumberFormat.currency(symbol: '₱', decimalDigits: 2);
    return formatter.format(amount);
  }

  void _navigateToCollectionDetails(BuildContext context, CollectionEntity collection) {
    if (collection.id != null) {
      // Navigate to collection details screen
      context.go('/collections/${collection.id}');
    }
  }

  void _navigateToInvoiceDetails(BuildContext context, CollectionEntity collection) {
    if (collection.invoice?.id != null) {
      // First, dispatch the event to load the invoice data
      context.read<InvoiceDataBloc>().add(GetInvoiceDataByIdEvent(collection.invoice!.id!));

      // Then navigate to the specific invoice screen
      context.go('/invoice/${collection.invoice!.id}');
    }
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Filter Collections'),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Collection Name Filter
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Collection Name',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    // Handle collection name filter
                  },
                ),
                const SizedBox(height: 16),

                // Date Range Filter
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          labelText: 'From Date',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        readOnly: true,
                        onTap: () async {
                          // Show date picker
                          // Handle selected date
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          labelText: 'To Date',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        readOnly: true,
                        onTap: () async {
                          // Show date picker
                          // Handle selected date
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Amount Range Filter
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          labelText: 'Min Amount',
                          border: OutlineInputBorder(),
                          prefixText: '₱ ',
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          // Handle min amount filter
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          labelText: 'Max Amount',
                          border: OutlineInputBorder(),
                          prefixText: '₱ ',
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          // Handle max amount filter
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Clear'),
              onPressed: () {
                // Clear all filters
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text('Apply'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                // Apply filters
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Filters applied')),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
