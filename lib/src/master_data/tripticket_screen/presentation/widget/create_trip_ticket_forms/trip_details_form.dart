import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/customer_data/data/model/customer_data_model.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/customer_data/presentation/bloc/customer_data_bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/customer_data/presentation/bloc/customer_data_event.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/customer_data/presentation/bloc/customer_data_state.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/delivery_data/data/model/delivery_data_model.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/invoice_data/data/model/invoice_data_model.dart';
import 'package:xpro_delivery_admin_app/core/common/widgets/create_screen_widgets/app_drop_down_fields.dart';
import 'package:xpro_delivery_admin_app/core/common/widgets/create_screen_widgets/app_textfield.dart';
import 'package:xpro_delivery_admin_app/core/common/widgets/create_screen_widgets/form_title.dart';
import 'package:xpro_delivery_admin_app/src/master_data/tripticket_screen/presentation/widget/create_trip_ticket_forms/customer_invoice_table_result.dart';
import 'package:xpro_delivery_admin_app/src/master_data/tripticket_screen/presentation/widget/create_trip_ticket_forms/delivery_data_table.dart';
import 'package:xpro_delivery_admin_app/src/master_data/tripticket_screen/presentation/widget/create_trip_ticket_forms/invoice_preset_group_dialog.dart';

class TripDetailsForm extends StatefulWidget {
  final TextEditingController tripIdController;
  final TextEditingController qrCodeController;
  final List<CustomerDataModel> selectedCustomers;
  final List<InvoiceDataModel> selectedInvoices;
  final List<DeliveryDataModel> selectedDeliveries;
  final Function(List<CustomerDataModel>) onCustomersChanged;
  final Function(List<InvoiceDataModel>) onInvoicesChanged;
  final Function(List<DeliveryDataModel>) onDeliveriesChanged;

  const TripDetailsForm({
    super.key,
    required this.tripIdController,
    required this.qrCodeController,
    required this.selectedCustomers,
    required this.selectedInvoices,
    this.selectedDeliveries = const [],
    required this.onCustomersChanged,
    required this.onInvoicesChanged,
    required this.onDeliveriesChanged,
  });

  @override
  State<TripDetailsForm> createState() => _TripDetailsFormState();
}

class _TripDetailsFormState extends State<TripDetailsForm> {
  CustomerDataModel? _selectedCustomer;
  List<InvoiceDataModel> _selectedInvoices = [];
  List<DeliveryDataModel> _selectedDeliveries = [];

  @override
  void initState() {
    super.initState();
    // Load all customers when the form is initialized
    context.read<CustomerDataBloc>().add(const GetAllCustomerDataEvent());
    _selectedDeliveries = List.from(widget.selectedDeliveries);
  }

  void _showPresetGroupDialog() {
    showDialog(
      context: context,
      builder:
          (context) => InvoicePresetGroupDialog(
            deliveryId:
                _selectedDeliveries.isNotEmpty
                    ? _selectedDeliveries.first.id
                    : null,
            onPresetAdded: () {
              // Refresh delivery data after preset is added
              setState(() {
                // This will trigger a refresh of the delivery data table
              });
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FormSectionTitle(title: 'Trip Details'),

        // Trip ID and QR Code in a row
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Trip ID field
            Expanded(
              flex: 2,
              child: AppTextField(
                label: 'Trip ID',
                controller: widget.tripIdController,
                readOnly: true, // Auto-generated, so read-only
              ),
            ),
            const SizedBox(width: 24),

            // QR Code display
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Trip QR Code',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 3,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(12),
                    child: QrImageView(
                      data: widget.qrCodeController.text,
                      version: QrVersions.auto,
                      size: 150,
                      backgroundColor: Colors.white,
                      errorStateBuilder: (context, error) {
                        return const Center(
                          child: Text(
                            'Error generating QR code',
                            style: TextStyle(color: Colors.red),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'QR Code Value: ${widget.qrCodeController.text}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),
        // Replace lines 149-166 with this code:
        SizedBox(
          width: 755,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Preset Group label
              SizedBox(
                width: 200,
                child: Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: RichText(
                    text: TextSpan(
                      text: 'Preset Group',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
              ),

              // Custom dropdown that shows dialog instead of dropdown items
              Expanded(
                child: InkWell(
                  onTap: _showPresetGroupDialog,
                  child: Container(
                    height: 56,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Select Preset Group',
                          style: TextStyle(color: Colors.grey),
                        ),
                        Icon(
                          Icons.arrow_drop_down,
                          color: Colors.grey.shade600,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Customer dropdown and tables in a row
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left column: Customer dropdown and Invoice table
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Customers dropdown
                  _buildCustomerDropdown(),

                  const SizedBox(height: 24),

                  // Invoices table
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 450,
                        child:
                            _selectedCustomer != null
                                ? CustomerInvoiceDataTableResult(
                                  customerId: _selectedCustomer!.id!,
                                  selectedInvoices: _selectedInvoices,
                                  onInvoicesChanged: (invoices) {
                                    setState(() {
                                      _selectedInvoices =
                                          invoices.map((invoice) {
                                            if (invoice is InvoiceDataModel) {
                                              return invoice;
                                            } else {
                                              return InvoiceDataModel(
                                                id: invoice.id,
                                                name: invoice.name,
                                                refId: invoice.refId,
                                                totalAmount:
                                                    invoice.totalAmount,
                                                documentDate:
                                                    invoice.documentDate,
                                                customer:
                                                    invoice.customer
                                                            is CustomerDataModel
                                                        ? invoice.customer
                                                            as CustomerDataModel
                                                        : null,
                                              );
                                            }
                                          }).toList();
                                    });

                                    widget.onInvoicesChanged(_selectedInvoices);
                                  },
                                )
                                : Card(
                                  child: Center(
                                    child: Text(
                                      'Select a customer to view invoices',
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                  ),
                                ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 30),

            // Right column: Delivery Data table
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Column(
                  children: [
                    DeliveryDataTable(
                      selectedDeliveries: _selectedDeliveries,
                      onDeliveriesChanged: (deliveries) {
                        setState(() {
                          _selectedDeliveries = deliveries;
                        });
                        widget.onDeliveriesChanged(deliveries);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCustomerDropdown() {
    return BlocBuilder<CustomerDataBloc, CustomerDataState>(
      builder: (context, state) {
        if (state is CustomerDataLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is CustomerDataError) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Customer',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text('Error: ${state.message}'),
              ElevatedButton(
                onPressed: () {
                  context.read<CustomerDataBloc>().add(
                    const GetAllCustomerDataEvent(),
                  );
                },
                child: const Text('Retry'),
              ),
            ],
          );
        }

        if (state is AllCustomerDataLoaded) {
          final customers = state.customerData;

          // Create dropdown items from customers
          final customerItems =
              customers.map((customer) {
                return DropdownItem<CustomerDataModel>(
                  value: customer as CustomerDataModel,
                  label: customer.name ?? 'Unnamed Customer',
                  icon: const Icon(Icons.store, size: 16),
                  uniqueId: customer.id ?? 'customer_${customer.hashCode}',
                  searchTerms: [
                    customer.name ?? '',
                    customer.refId ?? '',
                    customer.province ?? '',
                    customer.municipality ?? '',
                    customer.barangay ?? '',
                  ],
                );
              }).toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              AppDropdownField<CustomerDataModel>(
                label: 'Select Customer',
                hintText: 'Choose a customer',
                items: customerItems,
                selectedItems:
                    _selectedCustomer != null ? [_selectedCustomer!] : [],
                onChanged: (customer) {
                  if (customer != null) {
                    setState(() {
                      _selectedCustomer = customer;
                      // Clear previously selected invoices when customer changes
                      _selectedInvoices = [];
                    });

                    // Update parent with the selected customer
                    widget.onCustomersChanged([customer]);
                  }
                },
                onSelectedItemsChanged: (customers) {
                  if (customers.isNotEmpty) {
                    setState(() {
                      _selectedCustomer = customers.first;
                      // Clear previously selected invoices when customer changes
                      _selectedInvoices = [];
                    });
                    widget.onCustomersChanged(customers);
                  } else {
                    setState(() {
                      _selectedCustomer = null;
                      _selectedInvoices = [];
                    });
                    widget.onCustomersChanged([]);
                  }
                },
              ),
            ],
          );
        }

        // Default state
        return const AppTextField(
          label: 'Customer',
          initialValue: 'Loading customers...',
          readOnly: true,
        );
      },
    );
  }
}
