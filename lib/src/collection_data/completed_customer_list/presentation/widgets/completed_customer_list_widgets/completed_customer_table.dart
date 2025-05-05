import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/completed_customer/domain/entity/completed_customer_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/completed_customer/presentation/bloc/completed_customer_bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/completed_customer/presentation/bloc/completed_customer_event.dart';
import 'package:xpro_delivery_admin_app/core/common/widgets/app_structure/data_table_layout.dart';
import 'package:xpro_delivery_admin_app/core/enums/mode_of_payment.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class CompletedCustomerDataTable extends StatelessWidget {
  final List<CompletedCustomerEntity> completedCustomers;
  final bool isLoading;
  final int currentPage;
  final int totalPages;
  final Function(int) onPageChanged;
  final TextEditingController searchController;
  final String searchQuery;
  final Function(String) onSearchChanged;
  final String? errorMessage;
  final VoidCallback? onRetry;

  const CompletedCustomerDataTable({
    super.key,
    required this.completedCustomers,
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
    // Format currency
    final currencyFormatter = NumberFormat.currency(
      symbol: '₱',
      decimalDigits: 2,
    );

    return DataTableLayout(
      title: 'Completed Customers',
      searchBar: TextField(
        controller: searchController,
        decoration: InputDecoration(
          hintText: 'Search by store name, delivery number, or owner...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon:
              searchQuery.isNotEmpty
                  ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      searchController.clear();
                      onSearchChanged('');
                    },
                  )
                  : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onChanged: onSearchChanged,
      ),
      onCreatePressed: null, // No create button for completed customers
      columns: const [
        DataColumn(label: Text('Delivery #')),
        DataColumn(label: Text('Store Name')),
        DataColumn(label: Text('Owner')),
        DataColumn(label: Text('Trip ID')),
        DataColumn(label: Text('Mode of Payment')),
        DataColumn(label: Text('Amount')),
        DataColumn(label: Text('Completed At')),
        DataColumn(label: Text('Actions')),
      ],
      rows:
          completedCustomers.map((customer) {
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
                DataCell(
                  InkWell(
                    onTap: () {
                      if (customer.trip?.id != null) {
                        context.go('/collections/${customer.trip!.id}');
                      }
                    },
                    child: Text(
                      customer.trip?.tripNumberId ?? 'N/A',
                      style: const TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
                DataCell(
                  PaymentModeChip(customer: customer),
                  onTap: () => _navigateToCustomerData(context, customer),
                ),
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
      currentPage: currentPage,
      totalPages: totalPages,
      onPageChanged: onPageChanged,
      isLoading: isLoading,
      errorMessage: errorMessage,
      onRetry: onRetry,
      onFiltered: () {
        // Show filter options
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Filter options coming soon')),
        );
      }, dataLength: '${completedCustomers.length}', onDeleted: () {  },
    );
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
                    _getPaymentModeText(customer),
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
                  _buildDetailRow('Trip', customer.trip?.tripNumberId ?? 'N/A'),

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

  String _getPaymentModeText(CompletedCustomerEntity customer) {
    if (customer.modeOfPaymentString != null) {
      final paymentMode = ModeOfPayment.values.firstWhere(
        (mode) => mode.toString() == customer.modeOfPaymentString,
        orElse: () => ModeOfPayment.cashOnDelivery,
      );

      switch (paymentMode) {
        case ModeOfPayment.cashOnDelivery:
          return 'Cash on Delivery';
        case ModeOfPayment.bankTransfer:
          return 'Bank Transfer';
        case ModeOfPayment.cheque:
          return 'Cheque';
        case ModeOfPayment.eWallet:
          return 'E-Wallet';
      }
    } else if (customer.modeOfPayment != null) {
      return customer.modeOfPayment!;
    }

    return 'Unknown';
  }

  void _navigateToCustomerData(
    BuildContext context,
    CompletedCustomerEntity customer,
  ) {
    if (customer.id != null) {
      context.read<CompletedCustomerBloc>().add(
        GetCompletedCustomerByIdEvent(customer.id!),
      );

      context.go('/completed-customers/${customer.id}');
    }
  }
}

// Create a separate PaymentModeChip widget similar to TripStatusChip
class PaymentModeChip extends StatelessWidget {
  final CompletedCustomerEntity customer;

  const PaymentModeChip({super.key, required this.customer});

  @override
  Widget build(BuildContext context) {
    Color color;
    String paymentModeText;

    // Determine payment mode and color based on the ModeOfPayment enum
    if (customer.modeOfPaymentString != null) {
      final paymentMode = ModeOfPayment.values.firstWhere(
        (mode) => mode.toString() == customer.modeOfPaymentString,
        orElse: () => ModeOfPayment.cashOnDelivery,
      );

      switch (paymentMode) {
        case ModeOfPayment.cashOnDelivery:
          color = Colors.orange;
          paymentModeText = 'Cash on Delivery';
          break;
        case ModeOfPayment.bankTransfer:
          color = Colors.purple;
          paymentModeText = 'Bank Transfer';
          break;
        case ModeOfPayment.cheque:
          color = Colors.indigo;
          paymentModeText = 'Cheque';
          break;
        case ModeOfPayment.eWallet:
          color = Colors.teal;
          paymentModeText = 'E-Wallet';
          break;
      }
    } else if (customer.modeOfPayment != null) {
      // Try to parse from the string representation
      if (customer.modeOfPayment!.toLowerCase().contains('cash')) {
        color = Colors.orange;
        paymentModeText = 'Cash on Delivery';
      } else if (customer.modeOfPayment!.toLowerCase().contains('bank')) {
        color = Colors.purple;
        paymentModeText = 'Bank Transfer';
      } else if (customer.modeOfPayment!.toLowerCase().contains('cheque')) {
        color = Colors.indigo;
        paymentModeText = 'Cheque';
      } else if (customer.modeOfPayment!.toLowerCase().contains('wallet') ||
          customer.modeOfPayment!.toLowerCase().contains('e-wallet')) {
        color = Colors.teal;
        paymentModeText = 'E-Wallet';
      } else {
        color = Colors.blue;
        paymentModeText = customer.modeOfPayment!;
      }
    } else {
      color = Colors.grey;
      paymentModeText = 'Unknown';
    }

    // Use the Chip widget with the same styling as TripStatusChip
    return Chip(
      label: Text(
        paymentModeText,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: color,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      visualDensity: VisualDensity.compact,
    );
  }
}
