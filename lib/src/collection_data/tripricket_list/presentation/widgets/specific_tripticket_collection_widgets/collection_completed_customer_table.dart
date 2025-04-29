import 'package:desktop_app/core/common/app/features/Trip_Ticket/completed_customer/domain/entity/completed_customer_entity.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/completed_customer/presentation/bloc/completed_customer_bloc.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/completed_customer/presentation/bloc/completed_customer_event.dart';
import 'package:desktop_app/core/common/widgets/app_structure/data_table_layout.dart';
import 'package:desktop_app/core/enums/mode_of_payment.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class CollectionCompletedCustomersTable extends StatefulWidget {
  final String tripId;
  final List<CompletedCustomerEntity> completedCustomers;
  final bool isLoading;

  const CollectionCompletedCustomersTable({
    super.key,
    required this.tripId,
    required this.completedCustomers,
    this.isLoading = false,
  });

  @override
  State<CollectionCompletedCustomersTable> createState() =>
      _CollectionCompletedCustomersTableState();
}

class _CollectionCompletedCustomersTableState
    extends State<CollectionCompletedCustomersTable> {
  int _currentPage = 1;
  int _totalPages = 1;
  final int _itemsPerPage = 10;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Filter customers based on search query
    List<CompletedCustomerEntity> filteredCustomers = widget.completedCustomers;
    if (_searchQuery.isNotEmpty) {
      filteredCustomers =
          filteredCustomers.where((customer) {
            final query = _searchQuery.toLowerCase();
            return (customer.storeName?.toLowerCase().contains(query) ??
                    false) ||
                (customer.deliveryNumber?.toLowerCase().contains(query) ??
                    false) ||
                (customer.ownerName?.toLowerCase().contains(query) ?? false);
          }).toList();
    }

    // Calculate total pages
    _totalPages = (filteredCustomers.length / _itemsPerPage).ceil();
    if (_totalPages == 0) _totalPages = 1;

    // Paginate customers
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex =
        startIndex + _itemsPerPage > filteredCustomers.length
            ? filteredCustomers.length
            : startIndex + _itemsPerPage;

    final paginatedCustomers =
        startIndex < filteredCustomers.length
            ? filteredCustomers.sublist(startIndex, endIndex)
            : [];

    // Format currency
    final currencyFormatter = NumberFormat.currency(
      symbol: '₱',
      decimalDigits: 2,
    );

    return DataTableLayout(
      title: 'Completed Customers',
      searchBar: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search by store name, delivery number, or owner...',
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
      onCreatePressed: null, // No create button for collections view
      columns: const [
        DataColumn(label: Text('Delivery #')),
        DataColumn(label: Text('Store Name')),
        DataColumn(label: Text('Owner')),
        DataColumn(label: Text('Mode of Payment')),
        DataColumn(label: Text('Amount')),
        DataColumn(label: Text('Completed At')),
        DataColumn(label: Text('Actions')),
      ],
      rows:
          paginatedCustomers.map((customer) {
            return DataRow(
              cells: [
                DataCell(
                  Text(customer.deliveryNumber ?? 'N/A'),
                  onTap: () => _navigateToCustomerData(context, customer),
                ),
                DataCell(
                  Text(customer.storeName ?? 'N/A'),
                  onTap: () => _navigateToCustomerData(context, customer),
                ),
                DataCell(
                  Text(customer.ownerName ?? 'N/A'),
                  onTap: () => _navigateToCustomerData(context, customer),
                ),
                DataCell(_buildModeOfPaymentChip(customer.modeOfPayment)),
                DataCell(
                  Text(
                    customer.totalAmount != null
                        ? currencyFormatter.format(customer.totalAmount)
                        : 'N/A',
                  ),
                  onTap: () => _navigateToCustomerData(context, customer),
                ),
                DataCell(
                  Text(
                    customer.timeCompleted != null
                        ? DateFormat(
                          'MMM dd, yyyy hh:mm a',
                        ).format(customer.timeCompleted!)
                        : 'N/A',
                  ),
                  onTap: () => _navigateToCustomerData(context, customer),
                ),
                DataCell(
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.visibility, color: Colors.blue),
                        tooltip: 'View Details',
                        onPressed: () {
                          // View customer details
                          _showCustomerDetailsDialog(context, customer);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.print, color: Colors.green),
                        tooltip: 'Print Receipt',
                        onPressed: () {
                          // Print receipt
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Printing receipt...'),
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
      isLoading: widget.isLoading,
      onFiltered: () {}, dataLength: '${filteredCustomers.length}',
    );
  }

  // Format mode of payment from enum to readable text
  String _formatModeOfPayment(String? modeOfPaymentStr) {
    if (modeOfPaymentStr == null) return 'N/A';

    try {
      // Try to parse the string to the enum
      ModeOfPayment? modeOfPayment;

      // Handle both enum name and raw string cases
      if (modeOfPaymentStr == 'cashOnDelivery' ||
          modeOfPaymentStr == 'Cash On Delivery') {
        modeOfPayment = ModeOfPayment.cashOnDelivery;
      } else if (modeOfPaymentStr == 'bankTransfer' ||
          modeOfPaymentStr == 'Bank Transfer') {
        modeOfPayment = ModeOfPayment.bankTransfer;
      } else if (modeOfPaymentStr == 'cheque' || modeOfPaymentStr == 'Cheque') {
        modeOfPayment = ModeOfPayment.cheque;
      } else if (modeOfPaymentStr == 'eWallet' ||
          modeOfPaymentStr == 'E-Wallet') {
        modeOfPayment = ModeOfPayment.eWallet;
      }

      if (modeOfPayment != null) {
        switch (modeOfPayment) {
          case ModeOfPayment.cashOnDelivery:
            return 'Cash On Delivery';
          case ModeOfPayment.bankTransfer:
            return 'Bank Transfer';
          case ModeOfPayment.cheque:
            return 'Cheque';
          case ModeOfPayment.eWallet:
            return 'E-Wallet';
        }
      }

      // If we couldn't parse it as an enum, format the string directly
      return modeOfPaymentStr
          .replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(0)}')
          .replaceAllMapped(
            RegExp(r'^([a-z])'),
            (match) => match.group(0)!.toUpperCase(),
          );
    } catch (e) {
      // If any error occurs, return the original string
      return modeOfPaymentStr;
    }
  }

  void _showCustomerDetailsDialog(
    BuildContext context,
    CompletedCustomerEntity customer,
  ) {
    // Format currency
    final currencyFormatter = NumberFormat.currency(
      symbol: '₱',
      decimalDigits: 2,
    );

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(customer.storeName ?? 'Customer Details'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDetailRow(
                    'Delivery Number',
                    customer.deliveryNumber ?? 'N/A',
                  ),
                  _buildDetailRow('Owner Name', customer.ownerName ?? 'N/A'),
                  _buildDetailRow(
                    'Contact',
                    customer.contactNumber?.join(', ') ?? 'N/A',
                  ),
                  _buildDetailRow('Address', customer.address ?? 'N/A'),
                  _buildDetailRow(
                    'Municipality',
                    customer.municipality ?? 'N/A',
                  ),
                  _buildDetailRow('Province', customer.province ?? 'N/A'),
                  _buildDetailRow(
                    'Mode of Payment',
                    _formatModeOfPayment(customer.modeOfPayment),
                  ),
                  _buildDetailRow(
                    'Completed At',
                    customer.timeCompleted != null
                        ? DateFormat(
                          'MMM dd, yyyy hh:mm a',
                        ).format(customer.timeCompleted!)
                        : 'N/A',
                  ),
                  _buildDetailRow(
                    'Total Amount',
                    customer.totalAmount != null
                        ? currencyFormatter.format(customer.totalAmount)
                        : 'N/A',
                  ),
                  _buildDetailRow('Total Time', customer.totalTime ?? 'N/A'),

                  const SizedBox(height: 16),
                  const Text(
                    'Invoices',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  customer.invoices.isNotEmpty
                      ? Column(
                        children:
                            customer.invoices.map((invoice) {
                              return ListTile(
                                title: Text(invoice.invoiceNumber ?? 'N/A'),
                                subtitle: Text(
                                  invoice.totalAmount != null
                                      ? currencyFormatter.format(
                                        invoice.totalAmount,
                                      )
                                      : 'N/A',
                                ),
                                trailing: Text(
                                  invoice.created != null
                                      ? DateFormat(
                                        'MMM dd, yyyy',
                                      ).format(invoice.created!)
                                      : 'N/A',
                                ),
                              );
                            }).toList(),
                      )
                      : const Text('No invoices available'),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Printing receipt...')),
                  );
                },
                child: const Text('Print Receipt'),
              ),
            ],
          ),
    );
  }

  Widget _buildModeOfPaymentChip(String? modeOfPaymentStr) {
    // Default values
    Color backgroundColor = Colors.grey[100]!;
    Color textColor = Colors.grey[800]!;
    String label = 'N/A';
    IconData icon = Icons.help_outline;

    if (modeOfPaymentStr != null) {
      String paymentMode = _formatModeOfPayment(modeOfPaymentStr);

      switch (paymentMode) {
        case 'Cash On Delivery':
          backgroundColor = Colors.green[100]!;
          textColor = Colors.green[800]!;
          label = 'COD';
          icon = Icons.payments;
          break;
        case 'Bank Transfer':
          backgroundColor = Colors.blue[100]!;
          textColor = Colors.blue[800]!;
          label = 'Bank';
          icon = Icons.account_balance;
          break;
        case 'Cheque':
          backgroundColor = Colors.purple[100]!;
          textColor = Colors.purple[800]!;
          label = 'Cheque';
          icon = Icons.money;
          break;
        case 'E-Wallet':
          backgroundColor = Colors.orange[100]!;
          textColor = Colors.orange[800]!;
          label = 'E-Wallet';
          icon = Icons.account_balance_wallet;
          break;
        default:
          label = paymentMode;
      }
    }

    return Chip(
      avatar: Icon(icon, size: 16, color: textColor),
      label: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: backgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _navigateToCustomerData(
    BuildContext context,
    CompletedCustomerEntity customer,
  ) {
    if (customer.id != null) {
      context.read<CompletedCustomerBloc>().add(
        GetCompletedCustomerByIdEvent(customer.id!),
      );

      context.go('/completed-customers/:{$customer.id}');
    }
  }
}
