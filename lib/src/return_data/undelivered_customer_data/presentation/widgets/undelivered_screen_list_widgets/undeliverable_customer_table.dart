import 'package:xpro_delivery_admin_app/src/return_data/undelivered_customer_data/presentation/widgets/undelivered_screen_list_widgets/undeliverable_customer_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/cancelled_invoices/domain/entity/cancelled_invoice_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/widgets/app_structure/data_table_layout.dart';
import 'package:xpro_delivery_admin_app/core/enums/undeliverable_reason.dart';
import 'package:intl/intl.dart';


class UndeliveredCustomerTable extends StatelessWidget {
  final List<CancelledInvoiceEntity> cancelledInvoices;
  final bool isLoading;
  final int currentPage;
  final int totalPages;
  final Function(int) onPageChanged;
  final TextEditingController searchController;
  final String searchQuery;
  final Function(String) onSearchChanged;

  const UndeliveredCustomerTable({
    super.key,
    required this.cancelledInvoices,
    required this.isLoading,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
    required this.searchController,
    required this.searchQuery,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Debug the data
    for (var cancelledInvoice in cancelledInvoices) {
      debugPrint(
        '📋 Cancelled Invoice: ${cancelledInvoice.customer?.name} | Reason: ${cancelledInvoice.reason?.name}',
      );
    }

    return DataTableLayout(
      title: 'Undeliverable Customers',
      searchBar: UndeliveredCustomerSearchBar(
        controller: searchController,
        searchQuery: searchQuery,
        onSearchChanged: onSearchChanged,
      ),
      onCreatePressed: () {
        // Navigate to create undeliverable customer screen
        context.go('/undeliverable-customers/create');
      },
      createButtonText: 'Add Undeliverable Customer',
      columns: const [
        DataColumn(label: Text('Store Name')),
        DataColumn(label: Text('Delivery Number')),
        DataColumn(label: Text('Address')),
        DataColumn(label: Text('Reason')),
        DataColumn(label: Text('Time')),
        DataColumn(label: Text('Actions')),
      ],
      rows:
          cancelledInvoices.map((cancelledInvoice) {
            return DataRow(
              cells: [
                DataCell(Text(cancelledInvoice.customer?.name ?? 'N/A')),
                DataCell(Text(cancelledInvoice.deliveryData?.deliveryNumber ?? 'N/A')),
                DataCell(Text(_formatAddress(cancelledInvoice))),
                DataCell(_buildReasonChip(cancelledInvoice.reason)),
                DataCell(Text(_formatDate(cancelledInvoice.created))),
                DataCell(
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.visibility, color: Colors.blue),
                        tooltip: 'View Details',
                        onPressed: () {
                          // View cancelled invoice details
                          if (cancelledInvoice.id != null) {
                            context.go(
                              '/undeliverable-customers/${cancelledInvoice.id}',
                            );
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.orange),
                        tooltip: 'Edit',
                        onPressed: () {
                          // Edit cancelled invoice
                          if (cancelledInvoice.id != null) {
                            context.go(
                              '/undeliverable-customers/edit/${cancelledInvoice.id}',
                            );
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        tooltip: 'Delete',
                        onPressed: () {
                          // Show confirmation dialog before deleting
                          _showDeleteConfirmationDialog(context, cancelledInvoice);
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
      onFiltered: () {
        // Show filter dialog
        _showFilterDialog(context);
      }, 
      dataLength: '${cancelledInvoices.length}', 
      onDeleted: () {  },
    );
  }

  Widget _buildReasonChip(UndeliverableReason? reason) {
    if (reason == null) return const Text('N/A');

    Color chipColor;
    switch (reason) {
      case UndeliverableReason.customerNotAvailable:
        chipColor = Colors.orange;
        break;
      case UndeliverableReason.environmentalIssues:
        chipColor = Colors.red;
        break;
      case UndeliverableReason.storeClosed:
        chipColor = Colors.purple;
        break;
      case UndeliverableReason.none:
        chipColor = Colors.blue;
        break;
    }

    return Chip(
      label: Text(
        _formatReason(reason),
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: chipColor,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      visualDensity: VisualDensity.compact,
    );
  }

  String _formatReason(UndeliverableReason reason) {
    switch (reason) {
      case UndeliverableReason.storeClosed:
        return 'Store Closed';

      case UndeliverableReason.customerNotAvailable:
        return 'Store Not available';
      case UndeliverableReason.environmentalIssues:
        return 'Environmental Issues';
      case UndeliverableReason.none:
        return 'Other Reason';
    }
  }

  String _formatAddress(CancelledInvoiceEntity cancelledInvoice) {
    final parts = [
      cancelledInvoice.customer?.municipality,
      cancelledInvoice.customer?.province,
    ].where((part) => part != null && part.isNotEmpty).toList();

    return parts.isEmpty ? 'No Address' : parts.join(', ');
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('MMM dd, yyyy hh:mm a').format(date);
  }

  Future<void> _showDeleteConfirmationDialog(
    BuildContext context,
    CancelledInvoiceEntity cancelledInvoice,
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
                Text(
                  'Are you sure you want to delete the undeliverable record for ${cancelledInvoice.customer?.name}?',
                ),
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
                // if (cancelledInvoice.id != null) {
                //   context.read<UndeliverableCustomerBloc>().add(
                //     DeleteUndeliverableCustomerEvent(cancelledInvoice.id!),
                //   );
                // }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showFilterDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Filter Undeliverable Customers'),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Filter options would go here
                // For example, dropdown for reason, date range pickers, etc.
                const Text('Filter options coming soon'),
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
              child: const Text('Apply'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                // Apply filters
              },
            ),
          ],
        );
      },
    );
  }
}
