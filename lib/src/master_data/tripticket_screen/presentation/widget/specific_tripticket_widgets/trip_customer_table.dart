import 'package:desktop_app/core/common/app/features/Trip_Ticket/customer/domain/entity/customer_entity.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/customer/presentation/bloc/customer_bloc.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/customer/presentation/bloc/customer_event.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/customer/presentation/bloc/customer_state.dart';
import 'package:desktop_app/core/common/widgets/app_structure/data_table_layout.dart';
import 'package:desktop_app/core/common/widgets/app_structure/status_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class TripCustomersTable extends StatelessWidget {
  final String tripId;
  final VoidCallback? onAttachCustomer;

  const TripCustomersTable({
    super.key,
    required this.tripId,
    this.onAttachCustomer,
  });

  @override
  Widget build(BuildContext context) {
    // Wrap with a SizedBox with defined height to ensure the widget has size
    return BlocBuilder<CustomerBloc, CustomerState>(
      builder: (context, state) {
        if (state is CustomerLoading) {
          return _buildCustomerTable(context, [], true);
        }

        if (state is CustomerError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                const SizedBox(height: 16),
                Text(
                  'Error loading customers: ${state.message}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    context.read<CustomerBloc>().add(GetCustomerEvent(tripId));
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        List<CustomerEntity> customers = [];

        if (state is CustomerLoaded) {
          customers = state.customer;
        }

        return _buildCustomerTable(context, customers, false);
      },
    );
  }

  Widget _buildCustomerTable(
    BuildContext context,
    List<CustomerEntity> customers,
    bool isLoading,
  ) {
    final headerStyle = TextStyle(
      fontWeight: FontWeight.bold,
      color: Colors.black,
    );

    // Ensure we have at least one row to prevent layout issues
    final List<DataRow> rows =
        customers.isEmpty && !isLoading
            ? [
              DataRow(
                cells: [
                  DataCell(Text('No data')),
                  DataCell(Text('')),
                  DataCell(Text('')),
                  DataCell(Text('')),
                  DataCell(Text('')),
                  DataCell(Text('')),
                ],
              ),
            ]
            : customers.map((customer) {
              return DataRow(
                cells: [
                  DataCell(
                    Text(customer.id ?? 'N/A'),
                    onTap: () => _navigateToCustomerDetails(context, customer),
                  ),
                  DataCell(
                    Text(customer.storeName ?? 'N/A'),
                    onTap: () => _navigateToCustomerDetails(context, customer),
                  ),
                  DataCell(
                    Text(_formatAddress(customer)),
                    onTap: () => _navigateToCustomerDetails(context, customer),
                  ),
                  DataCell(
                    _buildCustomerStatusChip(customer),
                    onTap: () => _navigateToCustomerDetails(context, customer),
                  ),

                  DataCell(Text(_formatCurrency(customer))),
                  DataCell(
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.visibility,
                            color: Colors.blue,
                          ),
                          tooltip: 'View Details',
                          onPressed: () {
                            // View customer details
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.orange),
                          tooltip: 'Edit',
                          onPressed: () {
                            // Edit customer
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          tooltip: 'Delete',
                          onPressed: () {
                            _showDeleteCustomerDialog(context, customer);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }).toList();

    return DataTableLayout(
      title: 'Customers',
      onCreatePressed: onAttachCustomer,
      createButtonText: 'Attach Customer',
      columns: [
        DataColumn(label: Text('ID', style: headerStyle)),
        DataColumn(label: Text('Customer Name', style: headerStyle)),
        DataColumn(label: Text('Address', style: headerStyle)),
        DataColumn(label: Text('Status', style: headerStyle)),

        DataColumn(label: Text('Total Amount', style: headerStyle)),
        DataColumn(label: Text('Actions', style: headerStyle)),
      ],
      rows: rows,
      currentPage: 1, // Since we're not paginating this table
      totalPages: 1,
      onPageChanged: (page) {
        // No pagination for this table
      },
      isLoading: isLoading,
      onFiltered: () {},
      dataLength: '${customers.length}',
    );
  }

  String _formatAddress(CustomerEntity customer) {
    final parts =
        [
          customer.address,
          customer.municipality,
          customer.province,
        ].where((part) => part != null && part.isNotEmpty).toList();

    return parts.join(', ');
  }

  Widget _buildCustomerStatusChip(CustomerEntity customer) {
    // Get the latest status
    String status = "No Status";

    if (customer.deliveryStatus.isNotEmpty) {
      // Get the last (most recent) status update
      status = customer.deliveryStatus.last.title ?? "No Status";
    }

    // Map status to color
    Color color;
    switch (status.toLowerCase()) {
      case 'arrived':
        color = Colors.blue;
        break;
      case 'unloading':
        color = Colors.amber;
        break;
      case 'undelivered':
      case 'mark as undelivered':
        color = Colors.red;
        break;
      case 'in transit':
        color = Colors.indigo;
        break;
      case 'delivered':
        color = Colors.green;
        break;
      case 'received':
      case 'mark as received':
        color = Colors.teal;
        break;
      case 'completed':
      case 'end delivery':
        color = Colors.green.shade800;
        break;
      case 'pending':
      default:
        color = Colors.orange;
        break;
    }

    // Get the corresponding icon from StatusIcons
    final IconData statusIcon = StatusIcons.getStatusIcon(status);

    return Chip(
      avatar: Icon(statusIcon, size: 16, color: Colors.white),
      label: Text(
        status,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: color,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      visualDensity: VisualDensity.compact,
    );
  }

  String _formatCurrency(CustomerEntity customer) {
    // Try different approaches to get the total amount

    // 1. Try direct totalAmount property (might be a double or a string)
    if (customer.totalAmount != null) {
      if (customer.totalAmount is double) {
        return '₱${(customer.totalAmount as double).toStringAsFixed(2)}';
      } else if (customer.totalAmount is String) {
        try {
          final amount = double.parse(customer.totalAmount as String);
          return '₱${amount.toStringAsFixed(2)}';
        } catch (e) {
          return '₱${customer.totalAmount}';
        }
      }
    }

    // 2. Check if there's a confirmedTotalPayment
    if (customer.confirmedTotalPayment != null) {
      return '₱${customer.confirmedTotalPayment!.toStringAsFixed(2)}';
    }

    // 3. Calculate from invoices
    if (customer.invoicesList.isNotEmpty) {
      double total = 0.0;
      for (var invoice in customer.invoicesList) {
        if (invoice.totalAmount != null) {
          total += invoice.totalAmount!;
        }
      }
      if (total > 0) {
        return '₱${total.toStringAsFixed(2)}';
      }
    }

    return 'N/A';
  }

  void _showDeleteCustomerDialog(
    BuildContext context,
    CustomerEntity customer,
  ) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  'Are you sure you want to remove ${customer.storeName} from this trip?',
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
                // Implement delete functionality
                // context.read<CustomerBloc>().add(DeleteCustomerEvent(customer.id!));
              },
            ),
          ],
        );
      },
    );
  }

  void _navigateToCustomerDetails(
    BuildContext context,
    CustomerEntity customer,
  ) {
    if (customer.id != null) {
      context.read<CustomerBloc>().add(GetCustomerLocationEvent(customer.id!));

      context.go('/customer/:{$customer.id}');
    }
  }
}
