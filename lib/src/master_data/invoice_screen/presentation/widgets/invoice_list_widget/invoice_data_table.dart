import 'package:desktop_app/core/common/app/features/Trip_Ticket/invoice/domain/entity/invoice_entity.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/invoice/presentation/bloc/invoice_bloc.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/invoice/presentation/bloc/invoice_event.dart';
import 'package:desktop_app/core/common/widgets/app_structure/data_table_layout.dart';
import 'package:desktop_app/src/master_data/invoice_screen/presentation/widgets/invoice_list_widget/invoice_delete_dialog.dart';
import 'package:desktop_app/src/master_data/invoice_screen/presentation/widgets/invoice_list_widget/invoice_search_bar.dart';
import 'package:desktop_app/src/master_data/invoice_screen/presentation/widgets/invoice_list_widget/invoice_status_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class InvoiceDataTable extends StatelessWidget {
  final List<InvoiceEntity> invoices;
  final bool isLoading;
  final int currentPage;
  final int totalPages;
  final Function(int) onPageChanged;
  final TextEditingController searchController;
  final String searchQuery;
  final Function(String) onSearchChanged;
  final String? errorMessage;
  final VoidCallback? onRetry;

  const InvoiceDataTable({
    super.key,
    required this.invoices,
    required this.isLoading,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
    required this.searchController,
    required this.searchQuery,
    required this.onSearchChanged,
    this.errorMessage,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return DataTableLayout(
      title: 'Invoices',
      searchBar: InvoiceSearchBar(
        controller: searchController,
        searchQuery: searchQuery,
        onSearchChanged: onSearchChanged,
      ),
      onCreatePressed: () {
        // Navigate to create invoice screen
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Create invoice feature coming soon')),
        );
      },
      createButtonText: 'Create Invoice',
      columns: const [
        DataColumn(label: Text('ID')),
        DataColumn(label: Text('Invoice Number')),
        DataColumn(label: Text('Customer')),
        DataColumn(label: Text('Trip')),
        DataColumn(label: Text('Total Amount')),
        DataColumn(label: Text('Status')),
        DataColumn(label: Text('Actions')),
      ],
      rows:
          invoices.map((invoice) {
            return DataRow(
              cells: [
                DataCell(
                  Text(invoice.id?.substring(0, 8) ?? 'N/A'),
                  onTap: () => _navigateToInvoiceDetails(context, invoice),
                ),
                DataCell(
                  Text(invoice.invoiceNumber ?? 'N/A'),
                  onTap: () => _navigateToInvoiceDetails(context, invoice),
                ),
                DataCell(
                  Text(invoice.customer?.storeName ?? 'N/A'),
                  onTap: () => _navigateToInvoiceDetails(context, invoice),
                ),
                DataCell(
                  Text(invoice.trip?.tripNumberId ?? 'N/A'),
                  onTap: () => _navigateToInvoiceDetails(context, invoice),
                ),
                DataCell(
                  Text(_formatAmount(invoice.totalAmount)),
                  onTap: () => _navigateToInvoiceDetails(context, invoice),
                ),
                DataCell(
                  InvoiceStatusChip(invoice: invoice),
                  onTap: () => _navigateToInvoiceDetails(context, invoice),
                ),
                DataCell(
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.visibility, color: Colors.blue),
                        tooltip: 'View Details',
                        onPressed:
                            () => _navigateToInvoiceDetails(context, invoice),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.orange),
                        tooltip: 'Edit',
                        onPressed: () {
                          // Edit invoice
                          if (invoice.id != null) {
                            // Navigate to edit screen
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Edit invoice feature coming soon',
                                ),
                              ),
                            );
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        tooltip: 'Delete',
                        onPressed: () {
                          showInvoiceDeleteDialog(context, invoice);
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
        // Show filter options dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Filter options coming soon')),
        );
      },
    );
  }

  // String _formatDate(DateTime? date) {
  //   if (date == null) return 'N/A';
  //   return DateFormat('MMM dd, yyyy').format(date);
  // }

  String _formatAmount(double? amount) {
    if (amount == null) return 'N/A';
    final formatter = NumberFormat.currency(symbol: '₱', decimalDigits: 2);
    return formatter.format(amount);
  }

  void _navigateToInvoiceDetails(BuildContext context, InvoiceEntity invoice) {
    if (invoice.id != null) {
      // First, dispatch the event to load the invoice data
      context.read<InvoiceBloc>().add(GetInvoiceByIdEvent(invoice.id!));

      // Then navigate to the specific invoice screen with the actual ID
      context.go('/invoice/${invoice.id}');
    }
  }
}
