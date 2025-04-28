import 'package:desktop_app/core/common/widgets/create_screen_widgets/app_drop_down_fields.dart';
import 'package:desktop_app/core/common/widgets/create_screen_widgets/app_textfield.dart';
import 'package:desktop_app/core/common/widgets/create_screen_widgets/form_title.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'package:desktop_app/core/common/app/features/Trip_Ticket/customer/data/model/customer_model.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/invoice/data/models/invoice_models.dart';

class TripDetailsForm extends StatelessWidget {
  final TextEditingController tripIdController;
  final TextEditingController qrCodeController;
  final List<CustomerModel> availableCustomers;
  final List<CustomerModel> selectedCustomers;
  final List<InvoiceModel> availableInvoices;
  final List<InvoiceModel> selectedInvoices;
  final Function(List<CustomerModel>) onCustomersChanged;
  final Function(List<InvoiceModel>) onInvoicesChanged;

  const TripDetailsForm({
    super.key,
    required this.tripIdController,
    required this.qrCodeController,
    required this.availableCustomers,
    required this.selectedCustomers,
    required this.availableInvoices,
    required this.selectedInvoices,
    required this.onCustomersChanged,
    required this.onInvoicesChanged,
  });

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
                controller: tripIdController,
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
                      data: qrCodeController.text,
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
                    'QR Code Value: ${qrCodeController.text}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Customers dropdown - filter for unassigned customers
        _buildCustomersDropdown(context),

        // Invoices dropdown - filter for unassigned invoices
        _buildInvoicesDropdown(context),
      ],
    );
  }

  Widget _buildCustomersDropdown(BuildContext context) {
    // Filter customers to only show those without a trip assigned
    final unassignedCustomers =
        availableCustomers.where((customer) {
          // Check if customer has no trip assigned or trip is null
          return customer.tripId == null || customer.tripId!.isEmpty;
        }).toList();

    debugPrint('📊 Available customers: ${availableCustomers.length}');
    debugPrint('📊 Unassigned customers: ${unassignedCustomers.length}');

    if (unassignedCustomers.isEmpty) {
      return const AppTextField(
        label: 'Customers',
        initialValue: 'No Unassigned Customers',
        readOnly: true,
        helperText: 'No unassigned customers available to select',
      );
    }

    // Convert available customers to dropdown items with search terms
    final customerItems =
        unassignedCustomers.map((customer) {
          // Create search terms focused on store name
          final List<String> searchTerms =
              [
                customer.storeName ?? '',
              ].where((term) => term.isNotEmpty).toList();

          return DropdownItem<CustomerModel>(
            value: customer,
            label: customer.storeName ?? 'Customer ${customer.id}',
            icon: const Icon(Icons.store, size: 16),
            uniqueId: customer.id ?? 'customer_${customer.hashCode}',
            searchTerms: searchTerms, // Add search terms for better filtering
          );
        }).toList();

    return AppDropdownField<CustomerModel>(
      label: 'Customers',
      hintText: 'Select Customer',
      items: customerItems,
      onChanged: (value) {
        if (value != null && !selectedCustomers.contains(value)) {
          final updatedList = List<CustomerModel>.from(selectedCustomers);
          updatedList.add(value);
          onCustomersChanged(updatedList);
        }
      },
      helperText: 'Select customers without an assigned trip',
      selectedItems: selectedCustomers,
      onSelectedItemsChanged: onCustomersChanged,
      enableSearch: true, // Enable search functionality
    );
  }

  Widget _buildInvoicesDropdown(BuildContext context) {
    // Filter invoices to only show those without a trip assigned
    final unassignedInvoices =
        availableInvoices.where((invoice) {
          // Check if invoice has no trip assigned or trip is null
          return invoice.tripId == null || invoice.tripId!.isEmpty;
        }).toList();

    debugPrint('📊 Available invoices: ${availableInvoices.length}');
    debugPrint('📊 Unassigned invoices: ${unassignedInvoices.length}');

    if (unassignedInvoices.isEmpty) {
      return const AppTextField(
        label: 'Invoices',
        initialValue: 'No Unassigned Invoices',
        readOnly: true,
        helperText: 'No unassigned invoices available to select',
      );
    }

    // Convert available invoices to dropdown items with search terms
    final invoiceItems =
        unassignedInvoices.map((invoice) {
          // Create search terms focused on invoice number
          final List<String> searchTerms =
              [
                invoice.invoiceNumber ?? '',
              ].where((term) => term.isNotEmpty).toList();

          // Add customer name to the label if available
          String label = invoice.invoiceNumber ?? 'Invoice ${invoice.id}';
          if (invoice.customer?.storeName != null &&
              invoice.customer!.storeName!.isNotEmpty) {
            label += ' - ${invoice.customer!.storeName}';
          }

          return DropdownItem<InvoiceModel>(
            value: invoice,
            label: label,
            icon: const Icon(Icons.receipt, size: 16),
            uniqueId: invoice.id ?? 'invoice_${invoice.hashCode}',
            searchTerms: searchTerms, // Add search terms for better filtering
          );
        }).toList();

    return AppDropdownField<InvoiceModel>(
      label: 'Invoices',
      hintText: 'Select Invoice',
      items: invoiceItems,
      onChanged: (value) {
        if (value != null && !selectedInvoices.contains(value)) {
          final updatedList = List<InvoiceModel>.from(selectedInvoices);
          updatedList.add(value);
          onInvoicesChanged(updatedList);
        }
      },
      helperText: 'Select invoices without an assigned trip',
      selectedItems: selectedInvoices,
      onSelectedItemsChanged: onInvoicesChanged,
      enableSearch: true, // Enable search functionality
    );
  }
}
