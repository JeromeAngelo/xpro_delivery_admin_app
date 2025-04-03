import 'package:desktop_app/core/common/app/features/Trip_Ticket/customer/domain/entity/customer_entity.dart';
import 'package:desktop_app/core/common/widgets/app_structure/data_dashboard.dart';
import 'package:flutter/material.dart';

class CustomerDashboardWidget extends StatelessWidget {
  final CustomerEntity customer;

  const CustomerDashboardWidget({super.key, required this.customer});

  @override
  Widget build(BuildContext context) {
    // Get the latest delivery status
    String deliveryStatus = "No Status";
    if (customer.deliveryStatus.isNotEmpty) {
      // Get the last (most recent) status update
      deliveryStatus = customer.deliveryStatus.last.title ?? "No Status";
    }

    return DashboardSummary(
      title: 'Customer Details',
      detailId: customer.storeName ?? 'N/A',
      items: [
        DashboardInfoItem(
          icon: Icons.person,
          value: customer.ownerName ?? 'N/A',
          label: 'Owner Name',
          iconColor: Colors.orange,
        ),
        DashboardInfoItem(
          icon: Icons.location_on,
          value: _formatAddress(),
          label: 'Address',
          iconColor: Colors.red,
        ),
        DashboardInfoItem(
          icon: Icons.receipt,
          value: customer.invoices.length.toString(),
          label: 'Number of Invoices',
          iconColor: Colors.green,
        ),
        DashboardInfoItem(
          icon: Icons.phone,
          value: _formatContacts(),
          label: 'Contact Numbers',
          iconColor: Colors.green,
        ),
        DashboardInfoItem(
          icon: Icons.receipt_long,
          value: customer.deliveryNumber ?? 'N/A',
          label: 'Delivery Number',
          iconColor: Colors.purple,
        ),
        DashboardInfoItem(
          icon: Icons.payment,
          value: customer.modeOfPayment ?? 'N/A',
          label: 'Payment Mode',
          iconColor: Colors.teal,
        ),
        DashboardInfoItem(
          icon: Icons.attach_money,
          value: _formatAmount(customer.totalAmount),
          label: 'Total Amount',
          iconColor: Colors.amber,
        ),
        // Added delivery status item
        DashboardInfoItem(
          icon: Icons.local_shipping,
          value: deliveryStatus,
          label: 'Delivery Status',
          iconColor: _getStatusColor(deliveryStatus),
        ),
        DashboardInfoItem(
          icon: Icons.numbers,
          value: customer.trip?.tripNumberId ?? 'n/a',
          label: 'Trip Number ID',
          iconColor: _getStatusColor(deliveryStatus),
        ),
      ],
    );
  }

  String _formatAddress() {
    final parts =
        [
          customer.address,
          customer.municipality,
          customer.province,
        ].where((part) => part != null && part.isNotEmpty).toList();

    return parts.join(', ');
  }

  String _formatContacts() {
    if (customer.contactNumber == null || customer.contactNumber!.isEmpty) {
      return 'No contacts';
    }
    return customer.contactNumber!.join(', ');
  }

  String _formatAmount(dynamic amount) {
    if (amount == null) return 'N/A';

    if (amount is double) {
      return '₱${amount.toStringAsFixed(2)}';
    } else if (amount is String) {
      try {
        final numAmount = double.parse(amount);
        return '₱${numAmount.toStringAsFixed(2)}';
      } catch (_) {
        return '₱$amount';
      }
    }

    return '₱$amount';
  }

  // Helper method to get appropriate color for status
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'arrived':
        return Colors.blue;
      case 'unloading':
        return Colors.amber;
      case 'undelivered':
      case 'mark as undelivered':
        return Colors.red;
      case 'in transit':
        return Colors.indigo;
      case 'delivered':
        return Colors.green;
      case 'received':
      case 'mark as received':
        return Colors.teal;
      case 'completed':
      case 'end delivery':
        return Colors.green.shade800;
      case 'pending':
      default:
        return Colors.orange;
    }
  }
}
