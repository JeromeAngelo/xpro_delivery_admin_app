import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/invoice/domain/entity/invoice_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/invoice/presentation/bloc/invoice_bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/invoice/presentation/bloc/invoice_event.dart';
import 'package:xpro_delivery_admin_app/core/common/widgets/app_structure/data_table_layout.dart';
import 'package:xpro_delivery_admin_app/src/master_data/invoice_screen/presentation/widgets/invoice_list_widget/invoice_status_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class CompletedCustomerInvoiceTable extends StatelessWidget {
  final List<InvoiceEntity> invoices;
  final bool isLoading;
  final int currentPage;
  final int totalPages;
  final Function(int) onPageChanged;
  final String completedCustomerId;
  final String? errorMessage;
  final VoidCallback? onRetry;

  const CompletedCustomerInvoiceTable({
    super.key,
    required this.invoices,
    required this.isLoading,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
    required this.completedCustomerId,
    this.errorMessage,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return DataTableLayout(
      title: 'Customer Invoices',
      columns: const [
        DataColumn(label: Text('Invoice Number')),
        DataColumn(label: Text('Date')),
        DataColumn(label: Text('Total Amount')),
        DataColumn(label: Text('Confirmed Total Amount')),
        DataColumn(label: Text('Status')),
        DataColumn(label: Text('Actions')),
      ],
      rows:
          invoices.map((invoice) {
            return DataRow(
              cells: [
                DataCell(
                  Text(invoice.invoiceNumber ?? 'N/A'),
                  onTap: () => _navigateToInvoiceDetails(context, invoice),
                ),
                DataCell(
                  Text(_formatDate(invoice.created)),
                  onTap: () => _navigateToInvoiceDetails(context, invoice),
                ),
                DataCell(
                  Text(_formatAmount(invoice.totalAmount)),
                  onTap: () => _navigateToInvoiceDetails(context, invoice),
                ),
                DataCell(
                  Text(_formatAmount(invoice.confirmTotalAmount)),
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
                        icon: const Icon(
                          Icons.picture_as_pdf,
                          color: Colors.red,
                        ),
                        tooltip: 'View PDF',
                        onPressed: () {
                          // View PDF functionality
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('PDF viewer coming soon'),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.print, color: Colors.green),
                        tooltip: 'Print Invoice',
                        onPressed: () {
                          // Print functionality
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Print functionality coming soon'),
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
      onFiltered: () {}, dataLength: '${invoices.length}', onDeleted: () {  },
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

  void _navigateToInvoiceDetails(BuildContext context, InvoiceEntity invoice) {
    if (invoice.id != null) {
      // First, dispatch the event to load the invoice data
      context.read<InvoiceBloc>().add(GetInvoiceByIdEvent(invoice.id!));

      // Then navigate to the specific invoice screen
      context.go('/invoice/${invoice.id}');
    }
  }
}
