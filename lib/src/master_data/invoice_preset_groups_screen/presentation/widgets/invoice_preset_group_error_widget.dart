import 'package:flutter/material.dart';

class InvoicePresetGroupErrorWidget extends StatelessWidget {
  final String errorMessage;
  final VoidCallback? onRetry;

  const InvoicePresetGroupErrorWidget({
    super.key,
    required this.errorMessage,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(
            'Error Loading Invoice Preset Groups',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.red[700],
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[800],
                  ),
            ),
          ),
          const SizedBox(height: 24),
          if (onRetry != null)
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
