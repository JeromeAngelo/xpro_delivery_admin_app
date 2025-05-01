import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/customer/domain/entity/customer_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/customer/presentation/bloc/customer_bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/customer/presentation/bloc/customer_event.dart';
import 'package:xpro_delivery_admin_app/core/common/widgets/app_structure/data_table_layout.dart';
import 'package:xpro_delivery_admin_app/core/common/widgets/app_structure/status_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class CustomerDataTable extends StatelessWidget {
  final List<CustomerEntity> customers;
  final bool isLoading;
  final int currentPage;
  final int totalPages;
  final Function(int) onPageChanged;
  final TextEditingController searchController;
  final String searchQuery;
  final Function(String) onSearchChanged;
  final String? errorMessage;
  final VoidCallback? onRetry;

  const CustomerDataTable({
    super.key,
    required this.customers,
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
    final headerStyle = TextStyle(
      fontWeight: FontWeight.bold,
      color: Colors.black,
    );

    return DataTableLayout(
      title: 'Customers',
      searchBar: TextField(
        controller: searchController,
        decoration: InputDecoration(
          hintText: 'Search by name, address, or delivery number...',
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
      onCreatePressed: () {
        // Navigate to create customer screen
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Create customer feature coming soon')),
        );
      },
      createButtonText: 'Create Customer',
      columns: [
        DataColumn(label: Text('ID', style: headerStyle)),
        DataColumn(label: Text('Store Name', style: headerStyle)),
        DataColumn(label: Text('Owner', style: headerStyle)),
        DataColumn(label: Text('Address', style: headerStyle)),
        // DataColumn(label: Text('Contact', style: headerStyle)),
        // DataColumn(label: Text('Delivery Number', style: headerStyle)),
        DataColumn(label: Text('Status', style: headerStyle)),
        DataColumn(label: Text('Actions', style: headerStyle)),
      ],
      rows:
          customers.map((customer) {
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
                  Text(customer.ownerName ?? 'N/A'),
                  onTap: () => _navigateToCustomerDetails(context, customer),
                ),
                DataCell(
                  Text(_formatAddress(customer)),
                  onTap: () => _navigateToCustomerDetails(context, customer),
                ),
                // DataCell(
                //   Text(_formatContacts(customer.contactNumber)),
                //   onTap: () => _navigateToCustomerDetails(context, customer),
                // ),
                // DataCell(
                //   Text(customer.deliveryNumber ?? 'N/A'),
                //   onTap: () => _navigateToCustomerDetails(context, customer),
                // ),
                DataCell(
                  _buildCustomerStatusChip(customer),
                  onTap: () => _navigateToCustomerDetails(context, customer),
                ),
                DataCell(
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.visibility, color: Colors.blue),
                        tooltip: 'View Details',
                        onPressed: () {
                          // View customer details
                          if (customer.id != null) {
                            context.read<CustomerBloc>().add(
                              GetCustomerLocationEvent(customer.id!),
                            );
                            // Show customer details dialog or navigate to details page
                            _navigateToCustomerDetails(context, customer);
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.orange),
                        tooltip: 'Edit',
                        onPressed: () {
                          // Edit customer
                          _showEditCustomerDialog(context, customer);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        tooltip: 'Delete',
                        onPressed: () {
                          // Delete customer
                          _showDeleteConfirmationDialog(context, customer);
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
      onFiltered: () {}, dataLength: '${customers.length}',
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

  // String _formatContacts(List<String>? contacts) {
  //   if (contacts == null || contacts.isEmpty) return 'N/A';
  //   return contacts.join(', ');
  // }

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

  void _showEditCustomerDialog(BuildContext context, CustomerEntity customer) {
    // This would be implemented to show a dialog for editing customer
    // For now, just show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Edit customer: ${customer.storeName}'),
        action: SnackBarAction(label: 'OK', onPressed: () {}),
      ),
    );
  }

  void _showDeleteConfirmationDialog(
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
                Text('Are you sure you want to delete ${customer.storeName}?'),
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
                if (customer.id != null) {
                  context.read<CustomerBloc>().add(
                    DeleteCustomerEvent(customer.id!),
                  );
                  // Refresh the list after deletion
                  context.read<CustomerBloc>().add(
                    const GetAllCustomersEvent(),
                  );
                }
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
