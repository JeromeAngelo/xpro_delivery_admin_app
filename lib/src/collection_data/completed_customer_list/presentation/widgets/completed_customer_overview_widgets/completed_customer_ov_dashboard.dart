import 'package:flutter/material.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/completed_customer/domain/entity/completed_customer_entity.dart';
import 'package:desktop_app/core/common/widgets/app_structure/data_dashboard.dart';
import 'package:desktop_app/core/enums/mode_of_payment.dart';
import 'package:intl/intl.dart';

class CompletedCustomerDashboard extends StatelessWidget {
  final List<CompletedCustomerEntity> customers;
  final bool isLoading;

  const CompletedCustomerDashboard({
    super.key,
    required this.customers,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate dashboard metrics
    final totalCustomers = customers.length;
    final totalAmount = customers.fold<double>(
      0,
      (sum, customer) => sum + (customer.totalAmount ?? 0),
    );

    // Calculate totals by payment mode
    final paymentTotals = _calculatePaymentTotals();

    // Format currency
    final currencyFormatter = NumberFormat.currency(
      symbol: '₱',
      decimalDigits: 2,
    );

    return DashboardSummary(
      title: 'Completed Customers Overview',
      isLoading: isLoading,
      items: [
        // Total Completed Customers
        DashboardInfoItem(
          icon: Icons.people,
          value: totalCustomers.toString(),
          label: 'Total Completed Customers',
          iconColor: Colors.blue,
        ),
        
        // Total Amount
        DashboardInfoItem(
          icon: Icons.monetization_on,
          value: currencyFormatter.format(totalAmount),
          label: 'Total Collections',
          iconColor: Colors.green,
        ),
        
        // Cash on Delivery Total
        DashboardInfoItem(
          icon: Icons.payments,
          value: currencyFormatter.format(paymentTotals[ModeOfPayment.cashOnDelivery] ?? 0),
          label: 'Cash on Delivery',
          iconColor: Colors.orange,
        ),
        
        // Bank Transfer Total
        DashboardInfoItem(
          icon: Icons.account_balance,
          value: currencyFormatter.format(paymentTotals[ModeOfPayment.bankTransfer] ?? 0),
          label: 'Bank Transfer',
          iconColor: Colors.purple,
        ),
        
        // Cheque Total
        DashboardInfoItem(
          icon: Icons.money,
          value: currencyFormatter.format(paymentTotals[ModeOfPayment.cheque] ?? 0),
          label: 'Cheque',
          iconColor: Colors.indigo,
        ),
        
        // E-Wallet Total
        DashboardInfoItem(
          icon: Icons.account_balance_wallet,
          value: currencyFormatter.format(paymentTotals[ModeOfPayment.eWallet] ?? 0),
          label: 'E-Wallet',
          iconColor: Colors.teal,
        ),
      ],
      crossAxisCount: 3,
      childAspectRatio: 3.0,
    );
  }

  Map<ModeOfPayment, double> _calculatePaymentTotals() {
    final Map<ModeOfPayment, double> totals = {
      for (var mode in ModeOfPayment.values) mode: 0.0,
    };

    for (final customer in customers) {
      // Get payment mode from string or use default
      ModeOfPayment paymentMode;
      
      if (customer.modeOfPaymentString != null) {
        paymentMode = ModeOfPayment.values.firstWhere(
          (mode) => mode.toString() == customer.modeOfPaymentString,
          orElse: () => ModeOfPayment.cashOnDelivery,
        );
      } else if (customer.modeOfPayment != null) {
        // Try to parse from the string representation
        try {
          paymentMode = ModeOfPayment.values.firstWhere(
            (mode) => mode.toString().toLowerCase().contains(
                  customer.modeOfPayment!.toLowerCase().replaceAll(' ', ''),
                ),
            orElse: () => ModeOfPayment.cashOnDelivery,
          );
        } catch (_) {
          paymentMode = ModeOfPayment.cashOnDelivery;
        }
      } else {
        paymentMode = ModeOfPayment.cashOnDelivery;
      }
      
      // Add to the total for this payment mode
      totals[paymentMode] = (totals[paymentMode] ?? 0) + (customer.totalAmount ?? 0);
    }

    return totals;
  }
}
