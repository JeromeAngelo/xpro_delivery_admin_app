import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/invoice_data/domain/entity/invoice_data_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/widgets/app_structure/data_dashboard.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class InvoiceDashboardWidget extends StatelessWidget {
  final InvoiceDataEntity invoice;

  const InvoiceDashboardWidget({
    super.key,
    required this.invoice,
  });

  @override
  Widget build(BuildContext context) {
    return DashboardSummary(
      title: 'Invoice Details',
      detailId: invoice.name ?? 'N/A',
      items: [
        DashboardInfoItem(
          icon: Icons.receipt,
          value: invoice.refId ?? 'N/A',
          label: 'Invoice Number',
          iconColor: Colors.blue,
        ),
       
       
        DashboardInfoItem(
          icon: Icons.attach_money,
          value: _formatAmount(invoice.totalAmount),
          label: 'Total Amount',
          iconColor: Colors.amber,
        ),
       
      
      
        DashboardInfoItem(
          icon: Icons.calendar_today,
          value: _formatDate(invoice.created),
          label: 'Created Date',
          iconColor: Colors.purple,
        ),
        DashboardInfoItem(
          icon: Icons.update,
          value: _formatDate(invoice.updated),
          label: 'Last Updated',
          iconColor: Colors.grey,
        ),
      ],
    );
  }

  String _formatAmount(double? amount) {
    if (amount == null) return 'N/A';
    final formatter = NumberFormat.currency(symbol: '₱', decimalDigits: 2);
    return formatter.format(amount);
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('MMM dd, yyyy hh:mm a').format(date);
  }


}
