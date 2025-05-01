import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/completed_customer/domain/entity/completed_customer_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/widgets/app_structure/data_dashboard.dart';
import 'package:xpro_delivery_admin_app/core/enums/mode_of_payment.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

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
    if (isLoading) {
      return _buildLoadingSkeleton(context);
    }
    
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

  Widget _buildLoadingSkeleton(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title skeleton
            Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                width: 180,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Grid of skeleton items
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 3.0,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: List.generate(
                9, // Same number as actual items
                (index) => _buildDashboardItemSkeleton(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardItemSkeleton(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            // Icon placeholder
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(width: 16),
            
            // Content placeholder
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Value placeholder
                  Container(
                    width: double.infinity,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Label placeholder
                  Container(
                    width: 100,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
