// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/customer/domain/entity/customer_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/customer/presentation/bloc/customer_bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/customer/presentation/bloc/customer_event.dart';
import 'package:xpro_delivery_admin_app/core/common/widgets/app_structure/data_table_layout.dart';
import 'package:xpro_delivery_admin_app/core/common/widgets/app_structure/status_icons.dart';

class TripCustomersTable extends StatelessWidget {
  final String tripId;
  final VoidCallback? onAttachCustomer;
  final List<CustomerEntity> customers;
  final bool isLoading;
  final int currentPage;
  final int totalPages;
  final Function(int) onPageChanged;
  final TextEditingController searchController;
  final String searchQuery;
  final Function(String) onSearchChanged;

  const TripCustomersTable({
    super.key,
    required this.tripId,
    this.onAttachCustomer,
    required this.customers,
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
    return DataTableLayout(
      title: 'Customers',
      searchBar: TextField(
        controller: searchController,
        decoration: InputDecoration(
          hintText: 'Search by name, address, or status...',
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
      onCreatePressed: onAttachCustomer,
      createButtonText: 'Attach Customer',
      columns: const [
        DataColumn(label: Text('ID')),
        DataColumn(label: Text('Customer Name')),
        DataColumn(label: Text('Address')),
        DataColumn(label: Text('Status')),
        DataColumn(label: Text('Total Amount')),
        DataColumn(label: Text('Actions')),
      ],
      rows:
          customers.map((customer) {
            return DataRow(
              cells: [
                // ID
                DataCell(
                  Text(customer.id ?? 'N/A'),
                  onTap: () => _navigateToCustomerDetails(context, customer),
                ),

                // Customer Name
                DataCell(
                  Text(customer.storeName ?? 'N/A'),
                  onTap: () => _navigateToCustomerDetails(context, customer),
                ),

                // Address
                DataCell(
                  Text(_formatAddress(customer)),
                  onTap: () => _navigateToCustomerDetails(context, customer),
                ),

                // Status
                DataCell(
                  _buildCustomerStatusChip(customer),
                  onTap: () => _navigateToCustomerDetails(context, customer),
                ),

                // Total Amount
                DataCell(
                  Text(_formatCurrency(customer)),
                  onTap: () => _navigateToCustomerDetails(context, customer),
                ),

                // Actions
                DataCell(
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.visibility, color: Colors.blue),
                        tooltip: 'View Details',
                        onPressed: () {
                          _navigateToCustomerDetails(context, customer);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.orange),
                        tooltip: 'Edit',
                        onPressed: () {
                          // Navigate to edit customer screen
                          context.go('/customer/edit/${customer.id}');
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
          }).toList(),
      currentPage: currentPage,
      totalPages: totalPages,
      onPageChanged: onPageChanged,
      isLoading: isLoading,
      onFiltered: () {
        // Show filter dialog
        _showFilterDialog(context);
      },
      dataLength: '${customers.length}', onDeleted: () {  },
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
      context.go('/customer/${customer.id}');
    }
  }

  Future<void> _showFilterDialog(BuildContext context) async {
    String? selectedStatus;
    double? minAmount;
    double? maxAmount;

    return showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Filter Customers'),
              content: SizedBox(
                width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status Filter
                    const Text('Status:'),
                    DropdownButton<String?>(
                      isExpanded: true,
                      value: selectedStatus,
                      hint: const Text('All Statuses'),
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('All Statuses'),
                        ),
                        ...[
                              'Pending',
                              'In Transit',
                              'Arrived',
                              'Unloading',
                              'Delivered',
                              'Received',
                              'Undelivered',
                              'Completed',
                            ]
                            .map(
                              (status) => DropdownMenuItem<String?>(
                                value: status,
                                child: Text(status),
                              ),
                            )
                            .toList(),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedStatus = value;
                        });
                      },
                    ),

                    const SizedBox(height: 16),

                    // Amount Range Filter
                    const Text('Amount Range:'),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: const InputDecoration(
                              labelText: 'Min Amount',
                              prefixText: '₱',
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              if (value.isNotEmpty) {
                                setState(() {
                                  minAmount = double.tryParse(value);
                                });
                              } else {
                                setState(() {
                                  minAmount = null;
                                });
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            decoration: const InputDecoration(
                              labelText: 'Max Amount',
                              prefixText: '₱',
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              if (value.isNotEmpty) {
                                setState(() {
                                  maxAmount = double.tryParse(value);
                                });
                              } else {
                                setState(() {
                                  maxAmount = null;
                                });
                              }
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
                  child: const Text('Reset'),
                  onPressed: () {
                    setState(() {
                      selectedStatus = null;
                      minAmount = null;
                      maxAmount = null;
                    });
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
                    // Apply filters - this would need a custom event in the CustomerBloc
                    // For now, we'll just refresh the list
                    context.read<CustomerBloc>().add(GetCustomerEvent(tripId));
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}
