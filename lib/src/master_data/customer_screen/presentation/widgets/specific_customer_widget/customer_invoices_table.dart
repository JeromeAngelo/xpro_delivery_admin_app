import 'package:desktop_app/core/common/app/features/Trip_Ticket/customer/domain/entity/customer_entity.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/invoice/domain/entity/invoice_entity.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/invoice/presentation/bloc/invoice_bloc.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/invoice/presentation/bloc/invoice_event.dart';
import 'package:desktop_app/core/common/widgets/app_structure/data_table_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class CustomerInvoicesTable extends StatefulWidget {
  final CustomerEntity customer;
  final List<InvoiceEntity> invoices;
  final VoidCallback? onAddInvoice;

  const CustomerInvoicesTable({
    super.key,
    required this.customer,
    this.invoices = const [],
    this.onAddInvoice,
  });

  @override
  State<CustomerInvoicesTable> createState() => _CustomerInvoicesTableState();
}

class _CustomerInvoicesTableState extends State<CustomerInvoicesTable> {
  int _currentPage = 1;
  int _totalPages = 1;
  final int _itemsPerPage = 10;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _calculateTotalPages();
  }

  @override
  void didUpdateWidget(CustomerInvoicesTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.invoices.length != widget.invoices.length) {
      _calculateTotalPages();
    }
  }

  void _calculateTotalPages() {
    _totalPages = (widget.invoices.length / _itemsPerPage).ceil();
    if (_totalPages == 0) _totalPages = 1;
    if (_currentPage > _totalPages) {
      _currentPage = _totalPages;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Add debug print to check invoices
    debugPrint(
      '📊 Building CustomerInvoicesTable with ${widget.invoices.length} invoices',
    );
    // Filter invoices based on search query
    List<InvoiceEntity> filteredInvoices = widget.invoices;
    if (_searchQuery.isNotEmpty) {
      filteredInvoices =
          widget.invoices.where((invoice) {
            final query = _searchQuery.toLowerCase();
            return (invoice.invoiceNumber?.toLowerCase().contains(query) ??
                    false) ||
                (invoice.status?.toString().toLowerCase().contains(query) ??
                    false) ||
                (invoice.customerDeliveryStatus?.toLowerCase().contains(
                      query,
                    ) ??
                    false);
          }).toList();
    }

    // Calculate total pages
    _totalPages = (filteredInvoices.length / _itemsPerPage).ceil();
    if (_totalPages == 0) _totalPages = 1;

    // Paginate invoices
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex =
        startIndex + _itemsPerPage > filteredInvoices.length
            ? filteredInvoices.length
            : startIndex + _itemsPerPage;

    final paginatedInvoices =
        startIndex < filteredInvoices.length
            ? filteredInvoices.sublist(startIndex, endIndex)
            : [];

    // More debug info
    debugPrint(
      '📊 Paginated invoices: ${paginatedInvoices.length} (page $_currentPage of $_totalPages)',
    );

    return DataTableLayout(
      title: 'Customer Invoices',
      searchBar: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search by invoice number or status...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon:
              _searchQuery.isNotEmpty
                  ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      setState(() {
                        _searchController.clear();
                        _searchQuery = '';
                      });
                    },
                  )
                  : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
      onCreatePressed: widget.onAddInvoice,
      createButtonText: 'Add Invoice',
      columns: const [
        DataColumn(label: Text('ID')),

        DataColumn(label: Text('Invoice #')),
        DataColumn(label: Text('Date')),
        DataColumn(label: Text('Total Amount')),
        DataColumn(label: Text('Confirmed Amount')),
        DataColumn(label: Text('Status')),
        DataColumn(label: Text('Actions')),
      ],
      rows:
          paginatedInvoices.map((invoice) {
            return DataRow(
              cells: [
                DataCell(
                  Text(invoice.id ?? 'N/A'),
                  onTap: () => _navigateToInvoice(context, invoice),
                ),

                DataCell(
                  Text(invoice.invoiceNumber ?? 'N/A'),
                  onTap: () => _navigateToInvoice(context, invoice),
                ),
                DataCell(
                  Text(_formatDate(invoice.created)),
                  onTap: () => _navigateToInvoice(context, invoice),
                ),
                DataCell(
                  Text(_formatAmount(invoice.totalAmount)),
                  onTap: () => _navigateToInvoice(context, invoice),
                ),
                DataCell(
                  Text(_formatAmount(invoice.confirmTotalAmount)),
                  onTap: () => _navigateToInvoice(context, invoice),
                ),
                DataCell(
                  _buildStatusChip(invoice.status?.toString() ?? 'Pending'),
                  onTap: () => _navigateToInvoice(context, invoice),
                ),

                DataCell(
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.visibility, color: Colors.blue),
                        tooltip: 'View Details',
                        onPressed: () {
                          _navigateToInvoice(context, invoice);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.orange),
                        tooltip: 'Edit',
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Edit invoice feature coming soon'),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.print, color: Colors.green),
                        tooltip: 'Print',
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Print invoice feature coming soon',
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
      currentPage: _currentPage,
      totalPages: _totalPages,
      onPageChanged: (page) {
        setState(() {
          _currentPage = page;
        });
      },
      isLoading: false,
      onFiltered: () {}, dataLength: '${filteredInvoices.length}',
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('MMM dd, yyyy').format(date);
  }

  String _formatAmount(dynamic amount) {
    if (amount == null) return 'N/A';

    if (amount is double) {
      return '₱${amount.toStringAsFixed(2)}';
    } else if (amount is String) {
      try {
        final numAmount = double.parse(amount);
        return '₱${numAmount.toStringAsFixed(2)}';
      } catch (_) {
        return '₱$amount';
      }
    }

    return '₱$amount';
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String displayStatus = status;

    // Handle enum values
    if (status.contains('.')) {
      displayStatus = status.split('.').last;
    }

    switch (displayStatus.toLowerCase()) {
      case 'paid':
        color = Colors.green;
        break;
      case 'pending':
        color = Colors.orange;
        break;
      case 'overdue':
        color = Colors.red;
        break;
      case 'cancelled':
        color = Colors.grey;
        break;
      case 'partial':
        color = Colors.blue;
        break;
      default:
        color = Colors.grey;
    }

    return Chip(
      label: Text(
        displayStatus,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: color,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      visualDensity: VisualDensity.compact,
    );
  }

  void _navigateToInvoice(BuildContext context, InvoiceEntity invoice) {
    if (invoice.id != null) {
      // First, dispatch the event to load the invoice data
      context.read<InvoiceBloc>().add(GetInvoiceByIdEvent(invoice.id!));

      // Then navigate to the specific invoice screen with the actual ID
      context.go('/invoice/${invoice.id}');
    }
  }

  // void _showInvoiceDetailsDialog(BuildContext context, InvoiceEntity invoice) {
  //   showDialog(
  //     context: context,
  //     builder:
  //         (context) => AlertDialog(
  //           title: Text('Invoice ${invoice.invoiceNumber ?? 'Details'}'),
  //           content: SingleChildScrollView(
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               mainAxisSize: MainAxisSize.min,
  //               children: [
  //                 _buildDetailRow(
  //                   'Invoice Number',
  //                   invoice.invoiceNumber ?? 'N/A',
  //                 ),
  //                 _buildDetailRow('Date Created', _formatDate(invoice.created)),
  //                 _buildDetailRow('Last Updated', _formatDate(invoice.updated)),
  //                 _buildDetailRow(
  //                   'Total Amount',
  //                   _formatAmount(invoice.totalAmount),
  //                 ),
  //                 _buildDetailRow(
  //                   'Confirmed Amount',
  //                   _formatAmount(invoice.confirmTotalAmount),
  //                 ),
  //                 _buildDetailRow('Status', _formatStatus(invoice.status)),
  //                 _buildDetailRow(
  //                   'Delivery Status',
  //                   invoice.customerDeliveryStatus ?? 'N/A',
  //                 ),
  //                 _buildDetailRow(
  //                   'Customer',
  //                   widget.customer.storeName ?? 'N/A',
  //                 ),

  //                 const SizedBox(height: 16),
  //                 _buildDetailRow(
  //                   'Products',
  //                   invoice.productsList.isEmpty
  //                       ? 'No products'
  //                       : '${invoice.productsList.length} product(s)',
  //                 ),
  //               ],
  //             ),
  //           ),
  //           actions: [
  //             TextButton(
  //               onPressed: () => Navigator.of(context).pop(),
  //               child: const Text('Close'),
  //             ),
  //             TextButton(
  //               onPressed: () {
  //                 Navigator.of(context).pop();
  //                 ScaffoldMessenger.of(context).showSnackBar(
  //                   const SnackBar(content: Text('Print feature coming soon')),
  //                 );
  //               },
  //               child: const Text('Print'),
  //             ),
  //           ],
  //         ),
  //   );
  // }

  // String _formatStatus(dynamic status) {
  //   if (status == null) return 'N/A';

  //   if (status.toString().contains('.')) {
  //     return status.toString().split('.').last;
  //   }

  //   return status.toString();
  // }

  // Widget _buildDetailRow(String label, String value) {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(vertical: 8.0),
  //     child: Row(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         SizedBox(
  //           width: 120,
  //           child: Text(
  //             '$label:',
  //             style: const TextStyle(fontWeight: FontWeight.bold),
  //           ),
  //         ),
  //         Expanded(child: Text(value)),
  //       ],
  //     ),
  //   );
  // }
}
