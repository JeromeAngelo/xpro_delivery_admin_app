import 'package:desktop_app/core/common/app/features/Trip_Ticket/completed_customer/domain/entity/completed_customer_entity.dart';
import 'package:desktop_app/core/common/widgets/app_structure/data_dashboard.dart';
import 'package:desktop_app/core/enums/mode_of_payment.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CompletedCustomerDashboardWidget extends StatelessWidget {
  final CompletedCustomerEntity customer;
  final bool isLoading;

  const CompletedCustomerDashboardWidget({
    super.key,
    required this.customer,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    // Format currency
    final currencyFormatter = NumberFormat.currency(
      symbol: '₱',
      decimalDigits: 2,
    );

    // Format date
    final dateFormatter = DateFormat('MMM dd, yyyy hh:mm a');

    return DashboardSummary(
      title: 'Customer Details',
      isLoading: isLoading,
      crossAxisCount: 3,
      items: [
        DashboardInfoItem(
          icon: Icons.receipt_long,
          value: customer.deliveryNumber ?? 'N/A',
          label: 'Delivery Number',
          iconColor: Colors.blue,
        ),
        DashboardInfoItem(
          icon: Icons.person,
          value: customer.ownerName ?? 'N/A',
          label: 'Owner Name',
          iconColor: Colors.orange,
        ),
        DashboardInfoItem(
          icon: Icons.store,
          value: customer.storeName ?? 'N/A',
          label: 'Store Name',
          iconColor: Colors.green,
        ),
        DashboardInfoItem(
          icon: Icons.payments,
          value:
              customer.totalAmount != null
                  ? currencyFormatter.format(customer.totalAmount)
                  : 'N/A',
          label: 'Total Amount',
          iconColor: Colors.purple,
        ),
        DashboardInfoItem(
          icon: Icons.payment,
          value: _formatModeOfPayment(customer),
          label: 'Mode of Payment',
          iconColor: _getPaymentModeColor(customer),
        ),
        DashboardInfoItem(
          icon: Icons.access_time,
          value:
              customer.timeCompleted != null
                  ? dateFormatter.format(customer.timeCompleted!)
                  : 'N/A',
          label: 'Completed At',
          iconColor: Colors.teal,
        ),
        DashboardInfoItem(
          icon: Icons.location_on,
          value: [customer.address, customer.municipality, customer.province]
              .where((element) => element != null && element.isNotEmpty)
              .join(', '),
          label: 'Address',
          iconColor: Colors.red,
        ),
        DashboardInfoItem(
          icon: Icons.receipt,
          value: customer.invoices.length.toString(),
          label: 'Invoices',
          iconColor: Colors.cyan,
        ),
        DashboardInfoItem(
          icon: Icons.timer,
          value: customer.totalTime ?? 'N/A',
          label: 'Total Time',
          iconColor: Colors.amber,
        ),
      ],
    );
  }

  // Format mode of payment from enum to readable text
  String _formatModeOfPayment(CompletedCustomerEntity customer) {
    // First check if we have the enum string representation
    if (customer.modeOfPaymentString != null) {
      final paymentMode = ModeOfPayment.values.firstWhere(
        (mode) => mode.toString() == customer.modeOfPaymentString,
        orElse: () => ModeOfPayment.cashOnDelivery,
      );

      switch (paymentMode) {
        case ModeOfPayment.cashOnDelivery:
          return 'Cash on Delivery';
        case ModeOfPayment.bankTransfer:
          return 'Bank Transfer';
        case ModeOfPayment.cheque:
          return 'Cheque';
        case ModeOfPayment.eWallet:
          return 'E-Wallet';
      }
    }

    // If we have a string representation
    if (customer.modeOfPayment != null) {
      final modeOfPaymentStr = customer.modeOfPayment!.toLowerCase();

      if (modeOfPaymentStr.contains('cash')) {
        return 'Cash on Delivery';
      } else if (modeOfPaymentStr.contains('bank')) {
        return 'Bank Transfer';
      } else if (modeOfPaymentStr.contains('cheque') ||
          modeOfPaymentStr.contains('check')) {
        return 'Cheque';
      } else if (modeOfPaymentStr.contains('wallet') ||
          modeOfPaymentStr.contains('e-wallet') ||
          modeOfPaymentStr.contains('ewallet')) {
        return 'E-Wallet';
      }

      // If it's a camelCase or snake_case string, format it properly
      return customer.modeOfPayment!
          .replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(0)}')
          .replaceAll('_', ' ')
          .trim()
          .split(' ')
          .map(
            (word) =>
                word.isNotEmpty
                    ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
                    : '',
          )
          .join(' ');
    }

    return 'N/A';
  }

  // Get color based on payment mode
  Color _getPaymentModeColor(CompletedCustomerEntity customer) {
    // First check if we have the enum string representation
    if (customer.modeOfPaymentString != null) {
      final paymentMode = ModeOfPayment.values.firstWhere(
        (mode) => mode.toString() == customer.modeOfPaymentString,
        orElse: () => ModeOfPayment.cashOnDelivery,
      );

      switch (paymentMode) {
        case ModeOfPayment.cashOnDelivery:
          return Colors.orange;
        case ModeOfPayment.bankTransfer:
          return Colors.purple;
        case ModeOfPayment.cheque:
          return Colors.indigo;
        case ModeOfPayment.eWallet:
          return Colors.teal;
      }
    }

    // If we have a string representation
    if (customer.modeOfPayment != null) {
      final modeOfPaymentStr = customer.modeOfPayment!.toLowerCase();

      if (modeOfPaymentStr.contains('cash')) {
        return Colors.orange;
      } else if (modeOfPaymentStr.contains('bank')) {
        return Colors.purple;
      } else if (modeOfPaymentStr.contains('cheque') ||
          modeOfPaymentStr.contains('check')) {
        return Colors.indigo;
      } else if (modeOfPaymentStr.contains('wallet') ||
          modeOfPaymentStr.contains('e-wallet') ||
          modeOfPaymentStr.contains('ewallet')) {
        return Colors.teal;
      }
    }

    return Colors.blue; // Default color
  }
}
