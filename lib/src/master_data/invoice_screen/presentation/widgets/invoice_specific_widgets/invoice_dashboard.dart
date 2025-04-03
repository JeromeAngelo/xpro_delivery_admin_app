import 'package:desktop_app/core/common/app/features/Trip_Ticket/invoice/domain/entity/invoice_entity.dart';
import 'package:desktop_app/core/common/widgets/app_structure/data_dashboard.dart';
import 'package:desktop_app/core/enums/invoice_status.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class InvoiceDashboardWidget extends StatelessWidget {
  final InvoiceEntity invoice;

  const InvoiceDashboardWidget({
    super.key,
    required this.invoice,
  });

  @override
  Widget build(BuildContext context) {
    return DashboardSummary(
      title: 'Invoice Details',
      detailId: invoice.invoiceNumber ?? 'N/A',
      items: [
        DashboardInfoItem(
          icon: Icons.receipt,
          value: invoice.invoiceNumber ?? 'N/A',
          label: 'Invoice Number',
          iconColor: Colors.blue,
        ),
        DashboardInfoItem(
          icon: Icons.store,
          value: invoice.customer?.storeName ?? 'N/A',
          label: 'Customer',
          iconColor: Colors.green,
        ),
        DashboardInfoItem(
          icon: Icons.local_shipping,
          value: invoice.trip?.tripNumberId ?? 'N/A',
          label: 'Trip ID',
          iconColor: Colors.orange,
        ),
        DashboardInfoItem(
          icon: Icons.attach_money,
          value: _formatAmount(invoice.totalAmount),
          label: 'Total Amount',
          iconColor: Colors.amber,
        ),
        DashboardInfoItem(
          icon: Icons.check_circle,
          value: _formatAmount(invoice.confirmTotalAmount),
          label: 'Confirmed Amount',
          iconColor: Colors.teal,
        ),
        DashboardInfoItem(
          icon: Icons.inventory_2,
          value: '${invoice.productsList.length}',
          label: 'Products Count',
          iconColor: Colors.indigo,
        ),
        DashboardInfoItem(
          icon: Icons.info,
          value: _getStatusText(invoice.status),
          label: 'Status',
          iconColor: _getStatusColor(invoice.status),
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

  String _getStatusText(InvoiceStatus? status) {
    if (status == null) return 'Unknown';
    
    switch (status) {
      case InvoiceStatus.truck:
        return 'In Truck';
      case InvoiceStatus.unloaded:
        return 'Unloaded';
      case InvoiceStatus.completed:
        return 'Completed';
      case InvoiceStatus.undelivered:
        return 'Undelivered';
      }
  }

  Color _getStatusColor(InvoiceStatus? status) {
    if (status == null) return Colors.grey;
    
    switch (status) {
      case InvoiceStatus.truck:
        return Colors.blue;
      case InvoiceStatus.unloaded:
        return Colors.orange;
      case InvoiceStatus.completed:
        return Colors.green;
      case InvoiceStatus.undelivered:
        return Colors.red;
      }
  }
}
