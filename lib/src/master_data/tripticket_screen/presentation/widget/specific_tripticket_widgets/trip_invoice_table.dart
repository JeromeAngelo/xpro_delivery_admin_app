import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/invoice/domain/entity/invoice_entity.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/invoice/presentation/bloc/invoice_bloc.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/invoice/presentation/bloc/invoice_event.dart';
import 'package:desktop_app/core/common/widgets/app_structure/data_table_layout.dart';
import 'package:desktop_app/core/enums/invoice_status.dart';
import 'package:intl/intl.dart';

class TripInvoiceTable extends StatelessWidget {
  final List<InvoiceEntity> invoices;
  final bool isLoading;
  final int currentPage;
  final int totalPages;
  final Function(int) onPageChanged;
  final TextEditingController searchController;
  final String searchQuery;
  final Function(String) onSearchChanged;
  final String tripId;

  const TripInvoiceTable({
    super.key,
    required this.invoices,
    required this.isLoading,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
    required this.searchController,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.tripId,
  });

  @override
  Widget build(BuildContext context) {
    return DataTableLayout(
      title: 'Invoices',
      searchBar: TextField(
        controller: searchController,
        decoration: InputDecoration(
          hintText: 'Search by invoice number, customer, or status...',
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
        // Navigate to create invoice screen with pre-filled trip ID
        context.go('/invoice/create?tripId=$tripId');
      },
      createButtonText: 'Create New Invoice',
      columns: const [
        DataColumn(label: Text('Invoice #')),
        DataColumn(label: Text('Customer')),
        DataColumn(label: Text('Status')),
        DataColumn(label: Text('Total Amount')),
        DataColumn(label: Text('Confirmed Amount')),
        DataColumn(label: Text('Created')),
        DataColumn(label: Text('Actions')),
      ],
      rows:
          invoices.map((invoice) {
            return DataRow(
              cells: [
                // Invoice Number
                DataCell(Text(invoice.invoiceNumber ?? 'N/A')),

                // Customer
                DataCell(
                  invoice.customer != null
                      ? InkWell(
                        onTap: () {
                          if (invoice.customer?.id != null) {
                            context.go('/customer/${invoice.customer!.id}');
                          }
                        },
                        child: Text(
                          invoice.customer?.storeName ?? 'N/A',
                          style: const TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      )
                      : const Text('No Customer Data'),
                ),

                // Status
                DataCell(_buildStatusChip(invoice.status)),

                // Total Amount
                DataCell(
                  Text(
                    invoice.totalAmount != null
                        ? NumberFormat.currency(
                          symbol: '₱',
                        ).format(invoice.totalAmount)
                        : 'N/A',
                  ),
                ),

                // Confirmed Amount
                DataCell(
                  Text(
                    invoice.confirmTotalAmount != null
                        ? NumberFormat.currency(
                          symbol: '₱',
                        ).format(invoice.confirmTotalAmount)
                        : 'N/A',
                  ),
                ),

                // Created At
                DataCell(
                  Text(
                    invoice.created != null
                        ? DateFormat('MMM dd, yyyy').format(invoice.created!)
                        : 'N/A',
                  ),
                ),

                // Actions
                DataCell(
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.visibility, color: Colors.blue),
                        tooltip: 'View Details',
                        onPressed: () {
                          // View invoice details
                          if (invoice.id != null) {
                            context.read<InvoiceBloc>().add(
                              GetInvoiceByIdEvent(invoice.id!),
                            );
                            context.go('/invoice/${invoice.id}');
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.orange),
                        tooltip: 'Edit',
                        onPressed: () {
                          // Edit invoice
                          if (invoice.id != null) {
                            context.go('/invoice/edit/${invoice.id}');
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        tooltip: 'Delete',
                        onPressed: () {
                          // Show confirmation dialog before deleting
                          _showDeleteConfirmationDialog(context, invoice);
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
    );
  }

  Widget _buildStatusChip(InvoiceStatus? status) {
    Color chipColor;
    String label;

    switch (status) {
      case InvoiceStatus.truck:
        chipColor = Colors.blue;
        label = 'In Truck';
        break;
      case InvoiceStatus.completed:
        chipColor = Colors.green;
        label = 'Completed';
        break;
      case InvoiceStatus.undelivered:
        chipColor = Colors.red;
        label = 'Undelivered';
        break;
      case InvoiceStatus.unloaded:
        chipColor = Colors.orange;
        label = 'Unloaded';
        break;
      default:
        chipColor = Colors.grey;
        label = 'Unknown';
    }

    return Chip(
      label: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: chipColor,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      visualDensity: VisualDensity.compact,
    );
  }

  Future<void> _showDeleteConfirmationDialog(
    BuildContext context,
    InvoiceEntity invoice,
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
                  'Are you sure you want to delete invoice ${invoice.invoiceNumber}?',
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
                // Add delete invoice event
                if (invoice.id != null) {
                  context.read<InvoiceBloc>().add(
                    DeleteInvoiceEvent(invoice.id!),
                  );

                  // Refresh the invoice list for this trip after a short delay
                  Future.delayed(const Duration(milliseconds: 500), () {
                    context.read<InvoiceBloc>().add(
                      GetInvoicesByTripEvent(tripId),
                    );
                  });
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showFilterDialog(BuildContext context) async {
    InvoiceStatus? selectedStatus;

    return showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Filter Invoices'),
              content: SizedBox(
                width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status Filter
                    const Text('Status:'),
                    DropdownButton<InvoiceStatus?>(
                      isExpanded: true,
                      value: selectedStatus,
                      hint: const Text('All Statuses'),
                      items: [
                        const DropdownMenuItem<InvoiceStatus?>(
                          value: null,
                          child: Text('All Statuses'),
                        ),
                        ...InvoiceStatus.values.map((status) {
                          String label;
                          switch (status) {
                            case InvoiceStatus.truck:
                              label = 'In Truck';
                              break;
                            case InvoiceStatus.unloaded:
                              label = 'Unloaded';
                              break;
                            case InvoiceStatus.undelivered:
                              label = 'Undelivered';
                              break;
                            case InvoiceStatus.completed:
                              label = 'Completed';
                              break;
                          }

                          return DropdownMenuItem<InvoiceStatus?>(
                            value: status,
                            child: Text(label),
                          );
                        }).toList(),
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
                                setState(() {});
                              } else {
                                setState(() {});
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
                                setState(() {});
                              } else {
                                setState(() {});
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
                    // Apply filters - this would need a custom event in the InvoiceBloc
                    // For now, we'll just refresh the list
                    context.read<InvoiceBloc>().add(
                      GetInvoicesByTripEvent(tripId),
                    );
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
