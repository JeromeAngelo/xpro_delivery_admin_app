import 'package:desktop_app/core/common/app/features/Trip_Ticket/invoice/domain/entity/invoice_entity.dart';
import 'package:desktop_app/core/enums/invoice_status.dart';
import 'package:flutter/material.dart';

class InvoiceStatusChip extends StatelessWidget {
  final InvoiceEntity invoice;

  const InvoiceStatusChip({
    super.key,
    required this.invoice,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(
        _getStatusText(invoice.status),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: _getStatusColor(invoice.status),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      visualDensity: VisualDensity.compact,
    );
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
