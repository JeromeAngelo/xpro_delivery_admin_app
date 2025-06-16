import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/delivery_data/data/model/delivery_data_model.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/delivery_data/presentation/bloc/delivery_data_bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/delivery_data/presentation/bloc/delivery_data_event.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/delivery_data/presentation/bloc/delivery_data_state.dart';
import 'package:xpro_delivery_admin_app/core/common/widgets/create_screen_widgets/dynamic_table.dart';

class DeliveryDataTable extends StatefulWidget {
  final List<DeliveryDataModel> selectedDeliveries;
  final Function(List<DeliveryDataModel>) onDeliveriesChanged;

  const DeliveryDataTable({
    super.key,
    required this.selectedDeliveries,
    required this.onDeliveriesChanged,
  });

  @override
  State<DeliveryDataTable> createState() => _DeliveryDataTableState();
}

class _DeliveryDataTableState extends State<DeliveryDataTable> {
  List<DeliveryDataModel> _allDeliveries = [];
  Set<String> _selectedDeliveryIds = {};

  @override
  void initState() {
    super.initState();
    // Initialize selected deliveries from props
    _selectedDeliveryIds =
        widget.selectedDeliveries.map((d) => d.id ?? '').toSet();
    // Load all delivery data
    _refreshDeliveryData();
  }

  void _refreshDeliveryData() {
    context.read<DeliveryDataBloc>().add(const GetAllDeliveryDataEvent());
  }

  @override
  void didUpdateWidget(DeliveryDataTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedDeliveries != widget.selectedDeliveries) {
      _selectedDeliveryIds =
          widget.selectedDeliveries.map((d) => d.id ?? '').toSet();
    }
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
              'Deliveries',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _refreshDeliveryData,
              tooltip: 'Refresh delivery data',
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 500, // Fixed height for the table container
          child: BlocConsumer<DeliveryDataBloc, DeliveryDataState>(
            listener: (context, state) {
              if (state is AllDeliveryDataLoaded) {
                setState(() {
                  _allDeliveries =
                      state.deliveryData
                          .map((delivery) => delivery as DeliveryDataModel)
                          .toList();

                  // Update selected deliveries to parent
                  final selectedDeliveries =
                      _allDeliveries
                          .where(
                            (d) =>
                                d.id != null &&
                                _selectedDeliveryIds.contains(d.id),
                          )
                          .toList();
                  widget.onDeliveriesChanged(selectedDeliveries);
                });
              }
            },
            builder: (context, state) {
              // Define the table columns once to reuse
              final columns = [
                const DataColumn(label: Text('Select')),
                const DataColumn(label: Text('Customer')),
                const DataColumn(label: Text('Invoices')),
                const DataColumn(label: Text('Total Amount')),
                const DataColumn(label: Text('Document Date')),
              ];

              if (state is DeliveryDataLoading) {
                return _buildShimmerLoadingTable(columns);
              }

              if (state is DeliveryDataError) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Error: ${state.message}'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _refreshDeliveryData,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              // Show empty table with message if no data
              if (_allDeliveries.isEmpty) {
                return _buildEmptyTable(columns);
              }

              // Show table with data
              return DynamicDataTable<DeliveryDataModel>(
                data: _allDeliveries,
                columnBuilder: (context) => columns,
                rowBuilder: (delivery, index) {
                  final isSelected =
                      delivery.id != null &&
                      _selectedDeliveryIds.contains(delivery.id);

                  return DataRow(
                    selected: isSelected,
                    cells: [
                      DataCell(
                        Checkbox(
                          value: isSelected,
                          onChanged: (value) {
                            setState(() {
                              if (delivery.id != null) {
                                if (value == true) {
                                  _selectedDeliveryIds.add(delivery.id!);
                                } else {
                                  _selectedDeliveryIds.remove(delivery.id!);
                                }

                                // Update selected deliveries to parent
                                final selectedDeliveries =
                                    _allDeliveries
                                        .where(
                                          (d) =>
                                              d.id != null &&
                                              _selectedDeliveryIds.contains(
                                                d.id,
                                              ),
                                        )
                                        .toList();
                                widget.onDeliveriesChanged(selectedDeliveries);
                              }
                            });
                          },
                        ),
                      ),
                      DataCell(Text(delivery.customer?.name ?? 'N/A')),
                      DataCell(Text(delivery.invoice?.name ?? 'N/A')),
                      DataCell(
                        Text(
                          delivery.invoice?.totalAmount != null
                              ? '₱${delivery.invoice?.totalAmount!.toStringAsFixed(2)}'
                              : 'N/A',
                        ),
                      ),
                      DataCell(
                        Text(_formatDate(delivery.invoice?.documentDate)),
                      ),
                    ],
                  );
                },
                isLoading: false,
                emptyMessage: 'No delivery data available',
                buttonPlaceholder:
                    _selectedDeliveryIds.isNotEmpty
                        ? ElevatedButton.icon(
                          // In the remove delivery data button's onPressed callback:
                          onPressed: () {
                            // Show confirmation dialog before deleting
                            showDialog(
                              context: context,
                              builder:
                                  (dialogContext) => AlertDialog(
                                    title: const Text('Confirm Deletion'),
                                    content: const Text(
                                      'Are you sure you want to delete the selected delivery data? This action cannot be undone.',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed:
                                            () =>
                                                Navigator.of(
                                                  dialogContext,
                                                ).pop(),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(dialogContext).pop();

                                          // Get the IDs of selected delivery data
                                          final selectedIds =
                                              _selectedDeliveryIds.toList();

                                          // Delete each selected delivery data
                                          for (final id in selectedIds) {
                                            context
                                                .read<DeliveryDataBloc>()
                                                .add(
                                                  DeleteDeliveryDataEvent(id),
                                                );
                                          }

                                          // Clear selection after deletion
                                          setState(() {
                                            _selectedDeliveryIds.clear();
                                          });
                                        },
                                        style: TextButton.styleFrom(
                                          foregroundColor: Colors.red,
                                        ),
                                        child: const Text('Remove'),
                                      ),
                                    ],
                                  ),
                            );
                          },

                          icon: const Icon(Icons.check),
                          label: Text(
                            'Remove ${_selectedDeliveryIds.length} Selected',
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
                  Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No delivery data available',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add preset groups to create deliveries',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _refreshDeliveryData,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh'),
                  ),
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
                itemBuilder:
                    (_, __) => Padding(
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
                          // Customer name placeholder
                          Container(
                            width: 120,
                            height: 20,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 32),
                          // Invoice placeholder
                          Container(
                            width: 100,
                            height: 20,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 32),
                          // Amount placeholder
                          Container(width: 80, height: 20, color: Colors.white),
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

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    try {
      // Change the format from "MMM dd, yyyy hh:mm a" to "MM/dd/yyyy hh:mm a"
      return DateFormat('MM/dd/yyyy hh:mm a').format(date);
    } catch (e) {
      debugPrint('❌ Error formatting date: $e');
      return 'Invalid Date';
    }
  }
}
