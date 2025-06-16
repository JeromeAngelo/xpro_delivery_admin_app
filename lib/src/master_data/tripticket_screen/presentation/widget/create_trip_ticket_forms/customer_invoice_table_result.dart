import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/invoice_data/domain/entity/invoice_data_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/invoice_data/presentation/bloc/invoice_data_bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/invoice_data/presentation/bloc/invoice_data_event.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/invoice_data/presentation/bloc/invoice_data_state.dart';
import 'package:xpro_delivery_admin_app/core/common/widgets/create_screen_widgets/dynamic_table.dart';

class CustomerInvoiceDataTableResult extends StatefulWidget {
  final String customerId;
  final List<InvoiceDataEntity> selectedInvoices;
  final Function(List<InvoiceDataEntity>) onInvoicesChanged;
  final String? deliveryId;

  const CustomerInvoiceDataTableResult({
    super.key,
    required this.customerId,
    required this.selectedInvoices,
    required this.onInvoicesChanged,
    this.deliveryId,
  });

  @override
  State<CustomerInvoiceDataTableResult> createState() =>
      _InvoiceDataTableState();
}

class _InvoiceDataTableState extends State<CustomerInvoiceDataTableResult> {
  List<InvoiceDataEntity> _allInvoices = [];
  Set<String> _selectedInvoiceIds = {};
  bool _isAddingToDelivery = false;
  bool _needsRefresh = false;

  @override
  void initState() {
    super.initState();
    // Initialize selected invoices from props
    _selectedInvoiceIds =
        widget.selectedInvoices.map((i) => i.id ?? '').toSet();
    // Load invoices for the selected customer
    _loadInvoicesForCustomer();
  }

  void _loadInvoicesForCustomer() {
    if (widget.customerId.isNotEmpty) {
      context.read<InvoiceDataBloc>().add(
        GetInvoiceDataByCustomerIdEvent(widget.customerId),
      );
    }
  }

  @override
  void didUpdateWidget(CustomerInvoiceDataTableResult oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.customerId != widget.customerId &&
        widget.customerId.isNotEmpty) {
      _loadInvoicesForCustomer();
    }

    if (oldWidget.selectedInvoices != widget.selectedInvoices) {
      _selectedInvoiceIds =
          widget.selectedInvoices.map((i) => i.id ?? '').toSet();
    }
    
    // If we need a refresh and the customer ID hasn't changed, reload the data
    if (_needsRefresh && oldWidget.customerId == widget.customerId) {
      _loadInvoicesForCustomer();
      _needsRefresh = false;
    }
  }

  void _addSelectedInvoicesToDelivery() {
    // Check if we have a valid deliveryId
    final deliveryId = widget.deliveryId;
    
    // If we don't have a deliveryId, we'll pass an empty string to let the remote datasource
    // create a new delivery automatically, rather than showing an error
    if (_selectedInvoiceIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one invoice to add.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isAddingToDelivery = true;
    });

    // Add each selected invoice to the delivery
    for (final invoiceId in _selectedInvoiceIds) {
      context.read<InvoiceDataBloc>().add(
        AddInvoiceDataToDeliveryEvent(
          invoiceId: invoiceId,
          // Pass empty string if deliveryId is null - the remote datasource will create a new delivery
          deliveryId: deliveryId ?? '',
        ),
      );
    }
  }
  
  void _resetTable() {
    setState(() {
      _selectedInvoiceIds = {};
      _isAddingToDelivery = false;
      _needsRefresh = true;
    });
    
    // Update parent with empty selection
    widget.onInvoicesChanged([]);
    
    // Reload the data to reflect changes
    _loadInvoicesForCustomer();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Invoices',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            if (widget.customerId.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loadInvoicesForCustomer,
                tooltip: 'Refresh invoices',
              ),
          ],
        ),
        const SizedBox(height: 8),
        // Wrap the BlocConsumer in a SizedBox with fixed height to avoid unbounded height issues
        SizedBox(
          height: 400, // Fixed height for the table container
          child: BlocConsumer<InvoiceDataBloc, InvoiceDataState>(
            listener: (context, state) {
              if (state is InvoiceDataByCustomerLoaded) {
                setState(() {
                  _allInvoices = state.invoiceData;

                  // If no invoices are selected yet, select all by default
                  if (_selectedInvoiceIds.isEmpty && _allInvoices.isNotEmpty && !_needsRefresh) {
                    _selectedInvoiceIds =
                        _allInvoices.map((i) => i.id ?? '').toSet();
                    widget.onInvoicesChanged(_allInvoices);
                  }
                });
              } else if (state is InvoiceDataAddedToDelivery) {
                // When all invoices are processed, update UI
                if (_selectedInvoiceIds.contains(state.invoiceId)) {
                  _selectedInvoiceIds.remove(state.invoiceId);
                  
                  if (_selectedInvoiceIds.isEmpty) {
                    // All invoices have been processed, reset the table
                    _resetTable();
                    
                    // Show success message
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Invoices successfully added to delivery'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                }
              } else if (state is InvoiceDataError && _isAddingToDelivery) {
                setState(() {
                  _isAddingToDelivery = false;
                });
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: ${state.message}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            builder: (context, state) {
              // Define the table columns once to reuse
              final columns = [
                const DataColumn(label: Text('Select')),
                const DataColumn(label: Text('Invoice Name')),
                const DataColumn(label: Text('Amount')),
                const DataColumn(label: Text('Date')),
              ];

              if (state is InvoiceDataLoading) {
                return _buildShimmerLoadingTable(columns);
              }

              if (state is InvoiceDataError && !_isAddingToDelivery) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Colors.red[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error: ${state.message}',
                        style: TextStyle(color: Colors.red[700]),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          if (widget.customerId.isNotEmpty) {
                            _loadInvoicesForCustomer();
                          }
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              // Show empty table with message if no data
              if (_allInvoices.isEmpty) {
                return _buildEmptyTable(columns);
              }

              // Show table with data
              return DynamicDataTable<InvoiceDataEntity>(
                data: _allInvoices,
                columnBuilder: (context) => columns,
                rowBuilder: (invoice, index) {
                  final isSelected =
                      invoice.id != null &&
                      _selectedInvoiceIds.contains(invoice.id);

                  return DataRow(
                    selected: isSelected,
                    cells: [
                      DataCell(
                        Checkbox(
                          value: isSelected,
                          onChanged: _isAddingToDelivery 
                              ? null 
                              : (value) {
                                  setState(() {
                                    if (invoice.id != null) {
                                      if (value == true) {
                                        _selectedInvoiceIds.add(invoice.id!);
                                      } else {
                                        _selectedInvoiceIds.remove(invoice.id!);
                                      }

                                      // Update selected invoices to parent
                                      final selectedInvoices =
                                          _allInvoices
                                              .where(
                                                (i) =>
                                                    i.id != null &&
                                                    _selectedInvoiceIds.contains(
                                                      i.id,
                                                    ),
                                              )
                                              .toList();
                                      widget.onInvoicesChanged(selectedInvoices);
                                    }
                                  });
                                },
                        ),
                      ),
                      DataCell(Text(invoice.name ?? 'N/A')),
                      DataCell(
                        Text(
                          invoice.totalAmount != null
                              ? '₱${invoice.totalAmount!.toStringAsFixed(2)}'
                              : 'N/A',
                        ),
                      ),
                      DataCell(
                        Text(
                          invoice.documentDate != null
                              ? DateFormat(
                                'MMM dd, yyyy',
                              ).format(invoice.documentDate!)
                              : 'N/A',
                        ),
                      ),
                    ],
                  );
                },
                isLoading: false,
                emptyMessage: 'No invoices available for this customer',
                buttonPlaceholder:
                    _selectedInvoiceIds.isNotEmpty
                        ? ElevatedButton.icon(
                          onPressed: _isAddingToDelivery 
                              ? null 
                              : _addSelectedInvoicesToDelivery,
                          icon: _isAddingToDelivery 
                              ? Container(
                                  width: 24,
                                  height: 24,
                                  padding: const EdgeInsets.all(2.0),
                                  child: const CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 3,
                                  ),
                                )
                              : const Icon(Icons.add_circle_outline),
                          label: Text(
                            _isAddingToDelivery
                                ? 'Adding to Delivery...'
                                : 'Add ${_selectedInvoiceIds.length} To Delivery'
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Theme.of(context).primaryColor.withOpacity(0.7),
                            disabledForegroundColor: Colors.white,
                          ),
                        )
                        : null,
              );
            },
          ),
        ),
      ],
    );
  }

  // Build an empty table with headers and a message
  Widget _buildEmptyTable(List<DataColumn> columns) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Column(
        children: [
          // Table headers
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: columns,
              rows: const [], // No rows
              headingRowColor: MaterialStateProperty.all(Colors.grey[100]),
            ),
          ),

          // Empty state message
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No invoices available for this customer',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.customerId.isEmpty
                        ? 'Please select a customer first'
                        : 'This customer has no invoices',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                  if (widget.customerId.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _loadInvoicesForCustomer,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Refresh'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Build a shimmer loading effect table
  Widget _buildShimmerLoadingTable(List<DataColumn> columns) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Column(
        children: [
          // Table headers
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: columns,
              rows: const [], // No rows while loading
              headingRowColor: MaterialStateProperty.all(Colors.grey[100]),
            ),
          ),

          // Shimmer loading effect for rows
          Expanded(
            child: Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: ListView.builder(
                itemCount: 5, // Show 5 shimmer rows
                itemBuilder: (_, __) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      const SizedBox(width: 16),
                      // Checkbox placeholder
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 32),
                      // Invoice name placeholder
                      Container(
                        width: 150,
                        height: 20,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 32),
                      // Amount placeholder
                      Container(
                        width: 80,
                        height: 20,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 32),
                      // Date placeholder
                      Container(
                        width: 120,
                        height: 20,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

