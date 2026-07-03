import 'dart:math' show pi;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/trip_ticket/cancelled_invoices/domain/entity/cancelled_invoice_entity.dart';
import 'package:xpro_delivery_admin_app/core/enums/undeliverable_reason.dart';

/// Card widget that shows the "Cancelled Deliveries by Customer" donut chart.
///
/// Slices are grouped by customer name. Each slice is colored by the customer's
/// most common cancellation reason. When there are more than 5 customers, the
/// top 5 are shown individually and the rest are summarized as "and N others".
class CancelledDeliveriesStatusDistributionWidget extends StatelessWidget {
  final List<CancelledInvoiceEntity> cancelledInvoices;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isLoading;

  const CancelledDeliveriesStatusDistributionWidget({
    super.key,
    required this.cancelledInvoices,
    this.startDate,
    this.endDate,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final titleColor = scheme.onSurface;
    final subTextColor = scheme.onSurfaceVariant;

    final filteredInvoices = _filterByDateRange(cancelledInvoices);
    final distribution = _buildReasonDistribution(filteredInvoices);
    final total = filteredInvoices.length;

    return Card(
      elevation: 2,
      color: scheme.surface,
      surfaceTintColor: scheme.surfaceTint,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Top Cancellation Reasons',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: titleColor,
              ),
            ),
            const SizedBox(height: 30),
            if (isLoading)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 60),
                child: Center(
                  child: CircularProgressIndicator(color: scheme.primary),
                ),
              )
            else if (distribution.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: Text(
                    'No cancelled deliveries',
                    style: TextStyle(color: subTextColor),
                  ),
                ),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 170,
                        height: 170,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CustomPaint(
                              size: const Size(170, 170),
                              painter: _DonutPainter(
                                distribution: distribution,
                                backgroundColor: scheme.surfaceContainerLow,
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  total.toString(),
                                  style: theme.textTheme.headlineSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: titleColor,
                                        height: 1.0,
                                      ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Total',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: subTextColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 170,
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            itemCount: distribution.length,
                            itemBuilder: (context, index) {
                              final item = distribution[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(8),
                                  onTap: () {
                                    _showCancelledInvoicesDialog(context, item);
                                  },
                                  child: _Legend(
                                    color: item.color,
                                    label: item.label,
                                    value: item.count,
                                    textColor: titleColor,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildReasonLegend(titleColor),
                ],
              ),
          ],
        ),
      ),
    );
  }

  void _showCancelledInvoicesDialog(
    BuildContext context,
    _DistributionItem item,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: SizedBox(
            width: 700,
            height: 550,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: item.color,
                        child: const Icon(Icons.cancel, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          item.label,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        "${item.invoices.length} Deliveries",
                        style: theme.textTheme.titleMedium,
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  const Divider(),

                  Expanded(
                    child: ListView.separated(
                      itemCount: item.invoices.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final invoice = item.invoices[index];

                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: item.color.withOpacity(.15),
                            child: Icon(Icons.receipt_long, color: item.color),
                          ),

                          title: Text(
                            invoice.customer?.name ?? "Unknown Customer",
                          ),

                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Delivery #: ${invoice.deliveryData?.deliveryNumber ?? "-"}",
                              ),

                              if (invoice.created != null)
                                Text(
                                  "Cancelled: ${formatDateTime(invoice.created)}",
                                ),
                            ],
                          ),

                          trailing: Chip(
                            label: Text(item.label),
                            backgroundColor: item.color.withOpacity(.15),
                          ),

                          onTap: () {
                            // TODO:
                            // Open Cancelled Invoice Details
                          },
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 16),

                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                      label: const Text("Close"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  List<CancelledInvoiceEntity> _filterByDateRange(
    List<CancelledInvoiceEntity> invoices,
  ) {
    if (startDate == null || endDate == null) return invoices;

    return invoices.where((invoice) {
      final ts = invoice.created;
      if (ts == null) return false;
      return !ts.isBefore(startDate!) && !ts.isAfter(endDate!);
    }).toList();
  }

  List<_DistributionItem> _buildReasonDistribution(
    List<CancelledInvoiceEntity> cancelledInvoices,
  ) {
    if (cancelledInvoices.isEmpty) return [];

    final Map<UndeliverableReason, int> counts = {};

    for (final invoice in cancelledInvoices) {
      final reason = invoice.reason ?? UndeliverableReason.none;
      counts[reason] = (counts[reason] ?? 0) + 1;
    }

    final distribution =
        counts.entries.map((entry) {
          return _DistributionItem(
            label: _reasonLabel(entry.key),
            count: entry.value,
            color: _reasonColor(entry.key),

            invoices:
                cancelledInvoices
                    .where(
                      (e) =>
                          (e.reason ?? UndeliverableReason.none) == entry.key,
                    )
                    .toList(),
          );
        }).toList();

    distribution.sort((a, b) => b.count.compareTo(a.count));

    return distribution;
  }

  String _reasonLabel(UndeliverableReason reason) {
    switch (reason) {
      case UndeliverableReason.storeClosed:
        return 'Store Closed';

      case UndeliverableReason.customerNotAvailable:
        return 'Customer Not Available';

      case UndeliverableReason.environmentalIssues:
        return 'Environmental Issues';

      case UndeliverableReason.rescheduled:
        return 'Rescheduled';

      case UndeliverableReason.wrongInvoice:
        return 'Wrong Invoice';

      case UndeliverableReason.none:
        return 'No Specific Reason';
    }
  }

  Color _reasonColor(UndeliverableReason reason) {
    return switch (reason) {
      UndeliverableReason.storeClosed => Colors.blue,
      UndeliverableReason.customerNotAvailable => Colors.orange,
      UndeliverableReason.environmentalIssues => Colors.red,
      UndeliverableReason.rescheduled => Colors.green,
      UndeliverableReason.wrongInvoice => Colors.yellow.shade700,
      UndeliverableReason.none => Colors.purple,
    };
  }

  Widget _buildReasonLegend(Color textColor) {
    final reasons = [
      (UndeliverableReason.storeClosed, 'Store Closed'),
      (UndeliverableReason.customerNotAvailable, 'Customer Not Available'),
      (UndeliverableReason.environmentalIssues, 'Environmental Issues'),
      (UndeliverableReason.rescheduled, 'Rescheduled'),
      (UndeliverableReason.wrongInvoice, 'Wrong Invoice'),
      (UndeliverableReason.none, 'No Specific Reason'),
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children:
          reasons.map((entry) {
            final reason = entry.$1;
            final label = entry.$2;
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: _reasonColor(reason),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: textColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            );
          }).toList(),
    );
  }
}

String formatDateTime(DateTime? date) {
  if (date == null) return 'Not set';
  return DateFormat('MM/dd/yyyy').format(date);
}

class _DistributionItem {
  final String label;

  final int count;

  final Color color;

  final List<CancelledInvoiceEntity> invoices;

  _DistributionItem({
    required this.label,
    required this.count,
    required this.color,
    required this.invoices,
  });
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  final int value;
  final Color textColor;

  const _Legend({
    required this.color,
    required this.label,
    required this.value,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            '$label ($value)',
            style: TextStyle(
              fontSize: 13,
              color: textColor,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }
}

/// CustomPainter that draws the donut chart for cancelled-delivery customers.
class _DonutPainter extends CustomPainter {
  final List<_DistributionItem> distribution;
  final Color backgroundColor;

  _DonutPainter({required this.distribution, required this.backgroundColor});

  @override
  void paint(Canvas canvas, Size size) {
    final total = distribution.fold<int>(0, (sum, item) => sum + item.count);
    if (total <= 0) return;

    final radius = size.shortestSide / 2 - 6;
    final center = Offset(size.width / 2, size.height / 2);
    final rect = Rect.fromCircle(center: center, radius: radius);

    const strokeWidth = 26.0;

    final backgroundPaint =
        Paint()
          ..color = backgroundColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, backgroundPaint);

    const twoPi = 6.28318530717958;
    const startAngle = -pi / 2; // 12 o'clock

    var currentAngle = startAngle;
    for (final item in distribution) {
      if (item.count <= 0) continue;
      final sweep = (item.count / total) * twoPi;
      final paint =
          Paint()
            ..color = item.color
            ..style = PaintingStyle.stroke
            ..strokeWidth = strokeWidth
            ..strokeCap = StrokeCap.butt;
      canvas.drawArc(rect, currentAngle, sweep, false, paint);
      currentAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter old) {
    return old.distribution != distribution ||
        old.backgroundColor != backgroundColor;
  }
}
