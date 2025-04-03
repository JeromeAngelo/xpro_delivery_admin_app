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
          value: _formatModeOfPayment(customer.modeOfPayment),
          label: 'Mode of Payment',
          iconColor: Colors.indigo,
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
      ],
    );
  }

  // Format mode of payment from enum to readable text
  String _formatModeOfPayment(String? modeOfPaymentStr) {
    if (modeOfPaymentStr == null) return 'N/A';

    try {
      // Try to parse the string to the enum
      ModeOfPayment? modeOfPayment;

      // Handle both enum name and raw string cases
      if (modeOfPaymentStr == 'cashOnDelivery' ||
          modeOfPaymentStr == 'Cash On Delivery') {
        modeOfPayment = ModeOfPayment.cashOnDelivery;
      } else if (modeOfPaymentStr == 'bankTransfer' ||
          modeOfPaymentStr == 'Bank Transfer') {
        modeOfPayment = ModeOfPayment.bankTransfer;
      } else if (modeOfPaymentStr == 'cheque' || modeOfPaymentStr == 'Cheque') {
        modeOfPayment = ModeOfPayment.cheque;
      } else if (modeOfPaymentStr == 'eWallet' ||
          modeOfPaymentStr == 'E-Wallet') {
        modeOfPayment = ModeOfPayment.eWallet;
      }

      if (modeOfPayment != null) {
        switch (modeOfPayment) {
          case ModeOfPayment.cashOnDelivery:
            return 'Cash On Delivery';
          case ModeOfPayment.bankTransfer:
            return 'Bank Transfer';
          case ModeOfPayment.cheque:
            return 'Cheque';
          case ModeOfPayment.eWallet:
            return 'E-Wallet';
        }
      }

      // If we couldn't parse it as an enum, format the string directly
      return modeOfPaymentStr
          .replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(0)}')
          .replaceAllMapped(
            RegExp(r'^([a-z])'),
            (match) => match.group(0)!.toUpperCase(),
          );
    } catch (e) {
      // If any error occurs, return the original string
      return modeOfPaymentStr;
    }
  }
}
