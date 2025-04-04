import 'package:flutter/material.dart';
import 'package:desktop_app/core/enums/mode_of_payment.dart';

class PaymentModeChip extends StatelessWidget {
  final ModeOfPayment mode;
  final int count;

  const PaymentModeChip({
    super.key,
    required this.mode,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    if (count == 0) {
      return const SizedBox.shrink(); // Don't show if count is 0
    }
    
    Color color;
    String label;

    switch (mode) {
      case ModeOfPayment.cashOnDelivery:
        color = Colors.orange;
        label = 'COD';
        break;
      case ModeOfPayment.bankTransfer:
        color = Colors.purple;
        label = 'Bank';
        break;
      case ModeOfPayment.cheque:
        color = Colors.indigo;
        label = 'Cheque';
        break;
      case ModeOfPayment.eWallet:
        color = Colors.teal;
        label = 'E-Wallet';
        break;
    }

    return Chip(
      label: Text(
        '$label: $count',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: color,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      visualDensity: VisualDensity.compact,
    );
  }
}
