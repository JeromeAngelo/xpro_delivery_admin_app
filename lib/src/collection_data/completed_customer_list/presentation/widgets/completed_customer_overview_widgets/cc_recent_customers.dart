import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/completed_customer/domain/entity/completed_customer_entity.dart';
import 'package:xpro_delivery_admin_app/core/enums/mode_of_payment.dart';

class RecentCompletedCustomers extends StatelessWidget {
  final List<CompletedCustomerEntity> customers;
  final bool isLoading;

  const RecentCompletedCustomers({
    super.key,
    required this.customers,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    // Sort customers by completion date (newest first)
    final sortedCustomers = List<CompletedCustomerEntity>.from(customers)..sort(
      (a, b) => (b.timeCompleted ?? DateTime.now()).compareTo(
        a.timeCompleted ?? DateTime.now(),
      ),
    );

    // Take only the 5 most recent customers
    final recentCustomers = sortedCustomers.take(5).toList();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Completed Customers',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  onPressed: () => context.go('/completed-customers'),
                  icon: const Icon(Icons.visibility),
                  label: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (recentCustomers.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No completed customers found',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              )
            else
              Table(
                columnWidths: const {
                  0: FlexColumnWidth(2), // Store Name
                  1: FlexColumnWidth(2), // Address
                  2: FlexColumnWidth(1.5), // Completion Date
                  3: FlexColumnWidth(1.5), // Amount
                  4: FlexColumnWidth(1.5), // Payment Mode
                  5: FlexColumnWidth(1), // Actions
                },
                border: TableBorder(
                  horizontalInside: BorderSide(
                    color: Colors.grey[300]!,
                    width: 1,
                  ),
                ),
                children: [
                  // Table Header
                  TableRow(
                    decoration: BoxDecoration(color: Colors.grey[100]),
                    children: [
                      _buildTableHeader(context, 'Store Name'),
                      _buildTableHeader(context, 'Address'),
                      _buildTableHeader(context, 'Completion Date'),
                      _buildTableHeader(context, 'Amount'),
                      _buildTableHeader(context, 'Payment Mode'),
                      _buildTableHeader(context, 'Actions'),
                    ],
                  ),
                  // Table Rows
                  ...recentCustomers.map(
                    (customer) => TableRow(
                      children: [
                        _buildTableCell(context, customer.storeName ?? 'N/A'),
                        _buildTableCell(context, customer.address ?? 'N/A'),
                        _buildTableCell(
                          context,
                          _formatDate(customer.timeCompleted),
                        ),
                        _buildTableCell(
                          context,
                          _formatCurrency(customer.totalAmount ?? 0),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8.0,
                            horizontal: 16.0,
                          ),
                          child: _buildPaymentModeChip(customer),
                        ),
                        _buildActionCell(context, customer),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableHeader(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildTableCell(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      child: Text(text),
    );
  }

  Widget _buildActionCell(
    BuildContext context,
    CompletedCustomerEntity customer,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: IconButton(
        icon: const Icon(Icons.visibility, color: Colors.blue),
        onPressed: () {
          if (customer.id != null) {
            context.go('/completed-customers/details/${customer.id}');
          }
        },
        tooltip: 'View Details',
      ),
    );
  }

  Widget _buildPaymentModeChip(CompletedCustomerEntity customer) {
    // Determine payment mode and color
    Color color;
    String paymentModeText;

    if (customer.modeOfPaymentString != null) {
      final paymentMode = ModeOfPayment.values.firstWhere(
        (mode) => mode.toString() == customer.modeOfPaymentString,
        orElse: () => ModeOfPayment.cashOnDelivery,
      );

      switch (paymentMode) {
        case ModeOfPayment.cashOnDelivery:
          color = Colors.orange;
          paymentModeText = 'Cash on Delivery';
          break;
        case ModeOfPayment.bankTransfer:
          color = Colors.purple;
          paymentModeText = 'Bank Transfer';
          break;
        case ModeOfPayment.cheque:
          color = Colors.indigo;
          paymentModeText = 'Cheque';
          break;
        case ModeOfPayment.eWallet:
          color = Colors.teal;
          paymentModeText = 'E-Wallet';
          break;
      }
    } else if (customer.modeOfPayment != null) {
      paymentModeText = customer.modeOfPayment!;
      color = Colors.blue;
    } else {
      paymentModeText = 'Unknown';
      color = Colors.grey;
    }

    return Chip(
      label: Text(
        paymentModeText,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: color,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      visualDensity: VisualDensity.compact,
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('MMM dd, yyyy').format(date);
  }

  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(symbol: '₱', decimalDigits: 2);
    return formatter.format(amount);
  }
}
