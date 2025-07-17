import 'package:flutter/material.dart';

class ProcessingLoadingWidget extends StatelessWidget {
  final String? message;
  final VoidCallback? onCancel;
  final String? currentInvoiceId;
  final String? currentProcessMessage;
  final int? currentIndex;
  final int? totalInvoices;

  const ProcessingLoadingWidget({
    super.key,
    this.message,
    this.onCancel,
    this.currentInvoiceId,
    this.currentProcessMessage,
    this.currentIndex,
    this.totalInvoices,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32.0),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8.0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            if (message != null) ...[
              const SizedBox(height: 16.0),
              Text(
                message!,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
            if (totalInvoices != null && currentIndex != null) ...[
              const SizedBox(height: 12.0),
              Text(
                'Processing ${currentIndex! + 1} of $totalInvoices invoices',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8.0),
              LinearProgressIndicator(
                value: (currentIndex! + 1) / totalInvoices!,
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).primaryColor,
                ),
              ),
            ] else if (totalInvoices != null) ...[
              const SizedBox(height: 12.0),
              Text(
                'Processing $totalInvoices invoices...',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8.0),
              LinearProgressIndicator(
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).primaryColor,
                ),
              ),
            ],
            if (currentProcessMessage != null) ...[
              const SizedBox(height: 12.0),
              Text(
                currentProcessMessage!,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
            ],
            if (currentInvoiceId != null) ...[
              const SizedBox(height: 8.0),
              Text(
                'Invoice ID: $currentInvoiceId',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade500,
                  fontFamily: 'monospace',
                ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 24.0),
            ElevatedButton(
              onPressed: onCancel,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}
