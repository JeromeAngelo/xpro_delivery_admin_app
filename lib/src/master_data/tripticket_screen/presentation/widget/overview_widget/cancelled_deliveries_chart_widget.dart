import 'package:flutter/material.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/trip_ticket/cancelled_invoices/domain/entity/cancelled_invoice_entity.dart';

/// Card widget that shows the "Cancelled Deliveries (Today)" area/line chart.
/// Mirrors [ActiveTripsChartWidget] but uses cancelled invoice data.
class CancelledDeliveriesChartWidget extends StatelessWidget {
  final List<CancelledInvoiceEntity> cancelledInvoices;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isLoading;

  const CancelledDeliveriesChartWidget({
    super.key,
    required this.cancelledInvoices,
    this.startDate,
    this.endDate,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final filteredInvoices = _filterByDateRange(cancelledInvoices);
    final values = _buildHourlyCancelledCounts(filteredInvoices);

    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final accent = Colors.redAccent;
    final titleColor = scheme.onSurface;
    final subTextColor = scheme.onSurfaceVariant;
    final gridColor = scheme.outlineVariant.withOpacity(isDark ? 0.30 : 0.55);
    final cardBackground = scheme.surface;

    return Card(
      elevation: 2,
      color: scheme.surface,
      surfaceTintColor: scheme.surfaceTint,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cancelled Deliveries (Today)',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: titleColor,
              ),
            ),
            const SizedBox(height: 4),
            if (isLoading)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 48),
                child: Center(child: CircularProgressIndicator(color: accent)),
              )
            else ...[
              const SizedBox(height: 8),
              Text(
                filteredInvoices.length.toString(),
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: accent,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 200,
                child: CustomPaint(
                  size: Size.infinite,
                  painter: _CancelledDeliveriesAreaPainter(
                    values: values,
                    lineColor: accent,
                    areaStartColor: accent.withOpacity(isDark ? 0.45 : 0.30),
                    areaEndColor: accent.withOpacity(0.02),
                    gridColor: gridColor,
                    labelColor: subTextColor,
                    nodeFill: cardBackground,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              _XAxisLabels(color: subTextColor),
            ],
          ],
        ),
      ),
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

  List<int> _buildHourlyCancelledCounts(
    List<CancelledInvoiceEntity> cancelledInvoices,
  ) {
    const bucketStartHours = <int>[8, 10, 12, 14, 16];
    const fallback = <int>[5, 3, 5, 8, 5];

    if (cancelledInvoices.isEmpty) return fallback;

    final counts = List<int>.filled(5, 0);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    for (final invoice in cancelledInvoices) {
      final ts = invoice.created;
      if (ts == null) continue;
      if (ts.year != today.year ||
          ts.month != today.month ||
          ts.day != today.day) {
        continue;
      }

      final hour = ts.hour;
      var bucket = -1;
      for (var i = 0; i < bucketStartHours.length; i++) {
        if (hour >= bucketStartHours[i] && hour < bucketStartHours[i] + 2) {
          bucket = i;
          break;
        }
      }

      if (bucket == -1) {
        if (hour < bucketStartHours.first) {
          bucket = 0;
        } else {
          bucket = bucketStartHours.length - 1;
        }
      }

      counts[bucket] += 1;
    }

    return counts;
  }
}

class _XAxisLabels extends StatelessWidget {
  final Color color;
  const _XAxisLabels({required this.color});

  @override
  Widget build(BuildContext context) {
    const labels = ['8AM', '10AM', '12PM', '2PM', '4PM'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children:
          labels
              .map((l) => Text(l, style: TextStyle(fontSize: 12, color: color)))
              .toList(),
    );
  }
}

class _CancelledDeliveriesAreaPainter extends CustomPainter {
  final List<int> values;
  final Color lineColor;
  final Color areaStartColor;
  final Color areaEndColor;
  final Color gridColor;
  final Color labelColor;
  final Color nodeFill;

  _CancelledDeliveriesAreaPainter({
    required this.values,
    required this.lineColor,
    required this.areaStartColor,
    required this.areaEndColor,
    required this.gridColor,
    required this.labelColor,
    required this.nodeFill,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    const leftPadding = 28.0;
    const rightPadding = 8.0;
    const topPadding = 4.0;
    const bottomPadding = 4.0;

    final chartWidth = size.width - leftPadding - rightPadding;
    final chartHeight = size.height - topPadding - bottomPadding;

    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final yMax = (maxValue < 10) ? 10 : (maxValue + 2);

    final gridPaint =
        Paint()
          ..color = gridColor
          ..strokeWidth = 1;
    const gridSteps = 5;
    for (var i = 0; i <= gridSteps; i++) {
      final y = topPadding + chartHeight * (i / gridSteps);
      canvas.drawLine(
        Offset(leftPadding, y),
        Offset(leftPadding + chartWidth, y),
        gridPaint,
      );

      final textPainter = TextPainter(
        text: TextSpan(
          text: (yMax - (yMax * i / gridSteps)).round().toString(),
          style: TextStyle(fontSize: 11, color: labelColor),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(
        canvas,
        Offset(leftPadding - textPainter.width - 6, y - textPainter.height / 2),
      );
    }

    final stepX = chartWidth / (values.length - 1);
    final points = <Offset>[];
    for (var i = 0; i < values.length; i++) {
      final x = leftPadding + stepX * i;
      final normalized = values[i] / yMax;
      final y = topPadding + chartHeight * (1 - normalized);
      points.add(Offset(x, y));
    }

    final linePath = _buildSmoothPath(points);

    final areaPath =
        Path.from(linePath)
          ..lineTo(points.last.dx, topPadding + chartHeight)
          ..lineTo(points.first.dx, topPadding + chartHeight)
          ..close();

    final areaPaint =
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [areaStartColor, areaEndColor],
          ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(areaPath, areaPaint);

    final linePaint =
        Paint()
          ..color = lineColor
          ..strokeWidth = 2.5
          ..style = PaintingStyle.stroke
          ..strokeJoin = StrokeJoin.round
          ..strokeCap = StrokeCap.round;
    canvas.drawPath(linePath, linePaint);

    final nodeFillPaint = Paint()..color = nodeFill;
    final nodeStrokePaint =
        Paint()
          ..color = lineColor
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;
    for (final p in points) {
      canvas.drawCircle(p, 4, nodeFillPaint);
      canvas.drawCircle(p, 4, nodeStrokePaint);
    }
  }

  Path _buildSmoothPath(List<Offset> points) {
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final midX = (p0.dx + p1.dx) / 2;
      path.cubicTo(midX, p0.dy, midX, p1.dy, p1.dx, p1.dy);
    }
    return path;
  }

  @override
  bool shouldRepaint(covariant _CancelledDeliveriesAreaPainter old) {
    return old.values.toString() != values.toString() ||
        old.lineColor != lineColor ||
        old.areaStartColor != areaStartColor ||
        old.areaEndColor != areaEndColor ||
        old.gridColor != gridColor ||
        old.labelColor != labelColor ||
        old.nodeFill != nodeFill;
  }
}
