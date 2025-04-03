import 'package:desktop_app/core/common/widgets/create_screen_widgets/app_drop_down_fields.dart';
import 'package:desktop_app/core/common/widgets/create_screen_widgets/app_textfield.dart';
import 'package:desktop_app/core/common/widgets/create_screen_widgets/form_title.dart';
import 'package:flutter/material.dart';

import 'package:desktop_app/core/common/app/features/Trip_Ticket/customer/data/model/customer_model.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/invoice/data/models/invoice_models.dart';

class TripDetailsForm extends StatelessWidget {
  final TextEditingController tripIdController;
  final List<CustomerModel> availableCustomers;
  final List<CustomerModel> selectedCustomers;
  final List<InvoiceModel> availableInvoices;
  final List<InvoiceModel> selectedInvoices;
  final Function(List<CustomerModel>) onCustomersChanged;
  final Function(List<InvoiceModel>) onInvoicesChanged;

  const TripDetailsForm({
    super.key,
    required this.tripIdController,
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

        // Trip ID field
        AppTextField(
          label: 'Trip ID',
          controller: tripIdController,
          readOnly: true, // Auto-generated, so read-only
          //  helperText: 'Automatically generated trip ID',
        ),

        // Customers dropdown
        _buildCustomersDropdown(context),

        // Invoices dropdown
        _buildInvoicesDropdown(context),
      ],
    );
  }

  Widget _buildCustomersDropdown(BuildContext context) {
    if (availableCustomers.isEmpty) {
      return const AppTextField(
        label: 'Customers',
        initialValue: 'No Customers',
        readOnly: true,
        helperText: 'No customers available to select',
      );
    }

    // Convert available customers to dropdown items with search terms
    final customerItems =
        availableCustomers.map((customer) {
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
      //   helperText: 'Select customers for this trip (search by store name)',
      selectedItems: selectedCustomers,
      onSelectedItemsChanged: onCustomersChanged,
      enableSearch: true, // Enable search functionality
    );
  }

  // ignore: unused_element
  Widget _buildInvoicesDropdown(BuildContext context) {
    if (availableInvoices.isEmpty) {
      return const AppTextField(
        label: 'Invoices',
        initialValue: 'No Invoices',
        readOnly: true,
        helperText: 'No invoices available to select',
      );
    }

    // Convert available invoices to dropdown items with search terms
    final invoiceItems =
        availableInvoices.map((invoice) {
          // Create search terms focused on invoice number
          final List<String> searchTerms =
              [
                invoice.invoiceNumber ?? '',
              ].where((term) => term.isNotEmpty).toList();

          return DropdownItem<InvoiceModel>(
            value: invoice,
            label: invoice.invoiceNumber ?? 'Invoice ${invoice.id}',
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
      //   helperText: 'Select invoices for this trip (search by invoice number)',
      selectedItems: selectedInvoices,
      onSelectedItemsChanged: onInvoicesChanged,
      enableSearch: true, // Enable search functionality
    );
  }
}
