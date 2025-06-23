import 'package:xpro_delivery_admin_app/src/return_data/undelivered_customer_data/presentation/widgets/undelivered_screen_list_widgets/undeliverable_customer_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/cancelled_invoices/domain/entity/cancelled_invoice_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/cancelled_invoices/presentation/bloc/cancelled_invoice_bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/cancelled_invoices/presentation/bloc/cancelled_invoice_event.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/cancelled_invoices/presentation/bloc/cancelled_invoice_state.dart';
import 'package:xpro_delivery_admin_app/core/common/widgets/app_structure/data_table_layout.dart';
import 'package:xpro_delivery_admin_app/core/enums/undeliverable_reason.dart';
import 'package:intl/intl.dart';

class UndeliveredCustomerTable extends StatefulWidget {
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
  State<UndeliveredCustomerTable> createState() => _UndeliveredCustomerTableState();
}

class _UndeliveredCustomerTableState extends State<UndeliveredCustomerTable> {
  // Track selected rows for bulk actions
  Set<String> _selectedRows = {};
  bool _selectAll = false;

  @override
  Widget build(BuildContext context) {
    // Debug the data
    for (var cancelledInvoice in widget.cancelledInvoices) {
      debugPrint(
        '📋 Cancelled Invoice: ${cancelledInvoice.customer?.name} | Reason: ${cancelledInvoice.reason?.name}',
      );
    }

    return BlocListener<CancelledInvoiceBloc, CancelledInvoiceState>(
      listener: (context, state) {
        if (state is CancelledInvoiceTripReassigned) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Successfully reassigned ${_selectedRows.length} invoice(s) to trip',
              ),
              backgroundColor: Colors.green,
            ),
          );
          // Clear selection after successful reassignment
          setState(() {
            _selectedRows.clear();
            _selectAll = false;
          });
        } else if (state is CancelledInvoiceError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${state.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: DataTableLayout(
        title: 'Undeliverable Customers',
        searchBar: UndeliveredCustomerSearchBar(
          controller: widget.searchController,
          searchQuery: widget.searchQuery,
          onSearchChanged: widget.onSearchChanged,
        ),
        onCreatePressed: () {
          // Navigate to create undeliverable customer screen
          context.go('/undeliverable-customers/create');
        },
        createButtonText: 'Add Undeliverable Customer',
        columns: _buildColumns(),
        rows: _buildRows(),
        currentPage: widget.currentPage,
        totalPages: widget.totalPages,
        onPageChanged: widget.onPageChanged,
        isLoading: widget.isLoading,
        onFiltered: () {
          // Show filter dialog
          _showFilterDialog(context);
        },
        dataLength: '${widget.cancelledInvoices.length}',
        onDeleted: () {
          _showBulkDeleteDialog(context);
        },
        
        // NEW: Custom action for re-assigning trips
        showCustomAction: true,
        customActionIcon: Icons.assignment_return,
        customActionTooltip: 'Re-assign Selected to Trip',
        customActionColor: Colors.orange,
        onCustomAction: () => _showBulkReassignDialog(context),
      ),
    );
  }

  List<DataColumn> _buildColumns() {
    return [
      // Select All Checkbox
      DataColumn(
        label: Checkbox(
          value: _selectAll,
          onChanged: (value) {
            setState(() {
              _selectAll = value ?? false;
              if (_selectAll) {
                _selectedRows = widget.cancelledInvoices
                    .where((invoice) => invoice.id != null)
                    .map((invoice) => invoice.id!)
                    .toSet();
              } else {
                _selectedRows.clear();
              }
            });
          },
        ),
      ),
      const DataColumn(label: Text('Store Name')),
      const DataColumn(label: Text('Delivery Number')),
      const DataColumn(label: Text('Address')),
      const DataColumn(label: Text('Reason')),
      const DataColumn(label: Text('Time')),
      const DataColumn(label: Text('Actions')),
    ];
  }

  List<DataRow> _buildRows() {
    return widget.cancelledInvoices.map((cancelledInvoice) {
      final isSelected = _selectedRows.contains(cancelledInvoice.id);
      
      return DataRow(
        selected: isSelected,
        onSelectChanged: (selected) {
          if (cancelledInvoice.id != null) {
            setState(() {
              if (selected == true) {
                _selectedRows.add(cancelledInvoice.id!);
              } else {
                _selectedRows.remove(cancelledInvoice.id!);
              }
              _selectAll = _selectedRows.length == widget.cancelledInvoices.length;
            });
          }
        },
        cells: [
          // Checkbox Cell
          DataCell(
            Checkbox(
              value: isSelected,
              onChanged: (selected) {
                if (cancelledInvoice.id != null) {
                  setState(() {
                    if (selected == true) {
                      _selectedRows.add(cancelledInvoice.id!);
                    } else {
                      _selectedRows.remove(cancelledInvoice.id!);
                    }
                    _selectAll = _selectedRows.length == widget.cancelledInvoices.length;
                  });
                }
              },
            ),
          ),
          DataCell(
            Text(cancelledInvoice.customer?.name ?? 'N/A'),
            onTap: () => _onNavigateToSpecificCancelledInvoice(
              cancelledInvoice,
              context,
            ),
          ),
          DataCell(
            Text(cancelledInvoice.deliveryData?.deliveryNumber ?? 'N/A'),
            onTap: () => _onNavigateToSpecificCancelledInvoice(
              cancelledInvoice,
              context,
            ),
          ),
          DataCell(
            Text(_formatAddress(cancelledInvoice)),
            onTap: () => _onNavigateToSpecificCancelledInvoice(
              cancelledInvoice,
              context,
            ),
          ),
          DataCell(
            _buildReasonChip(cancelledInvoice.reason),
            onTap: () => _onNavigateToSpecificCancelledInvoice(
              cancelledInvoice,
              context,
            ),
          ),
          DataCell(
            Text(_formatDate(cancelledInvoice.created)),
            onTap: () => _onNavigateToSpecificCancelledInvoice(
              cancelledInvoice,
              context,
            ),
          ),
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
                  icon: const Icon(Icons.assignment_return, color: Colors.orange),
                  tooltip: 'Re-assign to Trip',
                  onPressed: () {
                    _showSingleReassignDialog(context, cancelledInvoice);
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
                    _showDeleteConfirmationDialog(
                      context,
                      cancelledInvoice,
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      );
    }).toList();
  }

  // NEW: Show bulk re-assign dialog
  void _showBulkReassignDialog(BuildContext context) {
    if (_selectedRows.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one invoice to re-assign'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final selectedInvoices = widget.cancelledInvoices
        .where((invoice) => _selectedRows.contains(invoice.id))
        .toList();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Re-assign to Trip'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Are you sure you want to re-assign ${_selectedRows.length} cancelled invoice(s) back to their respective trips?',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selected Invoices:',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      ...selectedInvoices.take(5).map((invoice) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text(
                          '• ${invoice.customer?.name ?? 'Unknown'} - ${invoice.invoice?.name ?? 'N/A'}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      )),
                      if (selectedInvoices.length > 5)
                        Text(
                          '... and ${selectedInvoices.length - 5} more',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _performBulkReassign(context, selectedInvoices);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text('Re-assign All'),
            ),
          ],
        );
      },
    );
  }

  // NEW: Show single re-assign dialog
  void _showSingleReassignDialog(BuildContext context, CancelledInvoiceEntity cancelledInvoice) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Re-assign to Trip'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Are you sure you want to re-assign this cancelled invoice back to the trip?',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Invoice: ${cancelledInvoice.invoice?.name ?? 'N/A'}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text('Customer: ${cancelledInvoice.customer?.name ?? 'N/A'}'),
                    Text('Trip: ${cancelledInvoice.trip?.tripNumberId ?? 'N/A'}'),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _performSingleReassign(context, cancelledInvoice);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text('Re-assign'),
            ),
          ],
        );
      },
    );
  }

  // NEW: Perform bulk re-assign
  void _performBulkReassign(BuildContext context, List<CancelledInvoiceEntity> invoices) {
    for (var invoice in invoices) {
      if (invoice.deliveryData?.id != null) {
        context.read<CancelledInvoiceBloc>().add(
          ReassignTripForCancelledInvoiceEvent(invoice.deliveryData!.id!),
        );
      }
    }
  }

  // NEW: Perform single re-assign
  void _performSingleReassign(BuildContext context, CancelledInvoiceEntity cancelledInvoice) {
    if (cancelledInvoice.deliveryData?.id != null) {
      context.read<CancelledInvoiceBloc>().add(
        ReassignTripForCancelledInvoiceEvent(cancelledInvoice.deliveryData!.id!),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: No delivery data ID found'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showBulkDeleteDialog(BuildContext context) {
    if (_selectedRows.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one item to delete'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete Selected Items'),
          content: Text(
            'Are you sure you want to delete ${_selectedRows.length} selected item(s)? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                // Perform bulk delete
                for (String id in _selectedRows) {
                  context.read<CancelledInvoiceBloc>().add(
                    DeleteCancelledInvoiceEvent(id),
                  );
                }
                setState(() {
                  _selectedRows.clear();
                  _selectAll = false;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Filter Options'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Add filter options here
              ListTile(
                title: const Text('Filter by Reason'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  // Implement reason filter
                },
              ),
              ListTile(
                title: const Text('Filter by Date Range'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  // Implement date range filter
                },
              ),
              ListTile(
                title: const Text('Filter by Trip'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  // Implement trip filter
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(
    BuildContext context,
    CancelledInvoiceEntity cancelledInvoice,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete Cancelled Invoice'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Are you sure you want to delete this cancelled invoice? This action cannot be undone.',
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Customer: ${cancelledInvoice.customer?.name ?? 'N/A'}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text('Delivery Number: ${cancelledInvoice.deliveryData?.deliveryNumber ?? 'N/A'}'),
                    Text('Reason: ${cancelledInvoice.reason?.name ?? 'N/A'}'),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                if (cancelledInvoice.id != null) {
                  context.read<CancelledInvoiceBloc>().add(
                    DeleteCancelledInvoiceEvent(cancelledInvoice.id!),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _onNavigateToSpecificCancelledInvoice(
    CancelledInvoiceEntity cancelledInvoice,
    BuildContext context,
  ) {
    if (cancelledInvoice.id != null) {
      context.go('/undeliverable-customers/${cancelledInvoice.id}');
    }
  }

  Widget _buildReasonChip(UndeliverableReason? reason) {
    if (reason == null) {
      return Chip(
        label: const Text('No Reason'),
        backgroundColor: Colors.grey[300],
      );
    }

    Color chipColor;
    switch (reason) {
      case UndeliverableReason.customerNotAvailable:
        chipColor = Colors.orange;
        break;
      case UndeliverableReason.environmentalIssues:
        chipColor = Colors.red;
        break;
      case UndeliverableReason.none:
        chipColor = Colors.purple;
        break;
      case UndeliverableReason.storeClosed:
        chipColor = Colors.blue;
        break;
     
      
    }

    return Chip(
      label: Text(
        reason.name,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: chipColor,
    );
  }

  String _formatAddress(CancelledInvoiceEntity cancelledInvoice) {
    final customer = cancelledInvoice.customer;
    if (customer == null) return 'N/A';

    final parts = <String>[];
  
    if (customer.municipality != null && customer.municipality!.isNotEmpty) {
      parts.add(customer.municipality!);
    }
    if (customer.province != null && customer.province!.isNotEmpty) {
      parts.add(customer.province!);
    }

    return parts.isEmpty ? 'N/A' : parts.join(', ');
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('MMM dd, yyyy HH:mm').format(date);
  }

  // Getter to check if any rows are selected (for DataTableLayout)
  bool get hasSelectedRows => _selectedRows.isNotEmpty;
}
