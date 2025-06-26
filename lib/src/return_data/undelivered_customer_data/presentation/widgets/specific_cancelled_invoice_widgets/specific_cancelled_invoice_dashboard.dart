import 'package:flutter/material.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/cancelled_invoices/domain/entity/cancelled_invoice_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/widgets/app_structure/data_dashboard.dart';

class CancelledInvoiceDashboardWidget extends StatelessWidget {
  final CancelledInvoiceEntity cancelledInvoice;

  const CancelledInvoiceDashboardWidget({
    super.key,
    required this.cancelledInvoice,
  });

  @override
  Widget build(BuildContext context) {
    final dashboardItems = _buildDashboardItems();

    return DashboardSummary(
      title: 'Cancelled Invoice Details',
      subtitle: 'Invoice Information',
      detailId: cancelledInvoice.invoice?.name ?? 'N/A',
      items: dashboardItems,
      crossAxisCount: 3,
      childAspectRatio: 3.0,
      crossAxisSpacing: 16.0,
      mainAxisSpacing: 16.0,
      isLoading: false,
    );
  }

  List<DashboardInfoItem> _buildDashboardItems() {
    return [
      // Customer Information
      DashboardInfoItem(
        icon: Icons.person,
        value: cancelledInvoice.customer?.name ?? 'Unknown Customer',
        label: 'Store Name',
        iconColor: Colors.blue,
      ),

      // Store Name
      DashboardInfoItem(
        icon: Icons.store,
        value: cancelledInvoice.customer?.ownerName ?? 'N/A',
        label: 'Customer Name',
        iconColor: Colors.green,
      ),

      // Invoice Number
      DashboardInfoItem(
        icon: Icons.receipt_long,
        value: cancelledInvoice.invoice?.name ?? 'N/A',
        label: 'Invoice Number',
        iconColor: Colors.orange,
      ),

      // Invoice Amount
      DashboardInfoItem(
        icon: Icons.attach_money,
        value: _formatCurrency(cancelledInvoice.invoice?.totalAmount ?? 0),
        label: 'Invoice Amount',
        iconColor: Colors.purple,
      ),

      // Cancellation Reason
      DashboardInfoItem(
        icon: Icons.cancel,
        value: cancelledInvoice.reason?.name ?? 'No Reason',
        label: 'Cancellation Reason',
        iconColor: Colors.red,
      ),

      // Trip Information
      DashboardInfoItem(
        icon: Icons.local_shipping,
        value: cancelledInvoice.trip?.tripNumberId ?? 'N/A',
        label: 'Trip Number',
        iconColor: Colors.indigo,
      ),

      // Delivery Date
      DashboardInfoItem(
        icon: Icons.calendar_today,
        value: _formatDate(cancelledInvoice.deliveryData?.created),
        label: 'Delivery Date',
        iconColor: Colors.teal,
      ),

      // Customer Address
      DashboardInfoItem(
        icon: Icons.location_on,
        value: _formatAddress(cancelledInvoice.customer),
        label: 'Customer Address',
        iconColor: Colors.brown,
      ),

      // Cancelled Date
      DashboardInfoItem(
        icon: Icons.access_time,
        value: _formatDate(cancelledInvoice.created),
        label: 'Cancelled Date',
        iconColor: Colors.grey,
      ),
    ];
  }

  String _formatCurrency(double amount) {
    return '₱${amount.toStringAsFixed(2)}';
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatAddress(dynamic customer) {
    if (customer == null) return 'N/A';

    final parts = <String>[];

    if (customer.province != null && customer.province!.isNotEmpty) {
      parts.add(customer.province!);
    }

    return parts.isEmpty ? 'N/A' : parts.join(', ');
  }
}
