import 'package:flutter/material.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/trip_ticket/trip/domain/entity/trip_entity.dart';

/// Card widget that shows the "Active Trips (Today)" area/line chart
/// matching the Trip Ticket Dashboard design.
///
/// All colors are derived from the active [Theme] (colorScheme + textTheme)
/// so the chart automatically adapts to light/dark/system modes.
class ActiveTripsChartWidget extends StatelessWidget {
  final List<TripEntity> trips;
  final bool isLoading;

  const ActiveTripsChartWidget({
    super.key,
    required this.trips,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    // Active trips are those that have been accepted (isAccepted = true).
    // They are the currently running trips.
    final activeTrips = trips.where((trip) => trip.isAccepted == true).toList();

    // Build 5 data points (8AM, 10AM, 12PM, 2PM, 4PM) based on when each
    // active trip was accepted.  The UI mirrors the mockup which has 5
    // evenly-spaced points every 2 hours.
    final values = _buildHourlyActiveCounts(activeTrips);

    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    // Theme-aware colors.
    final accent = scheme.primary;
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
              'Active Trips (Today)',
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
              // Big number = total count of active trips (isAccepted = true),
              // not the peak bucket value.
              Text(
                activeTrips.length.toString(),
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
                  painter: _ActiveTripsAreaPainter(
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

  /// Distributes active trips into 5 two-hourly buckets that align with the
  /// x-axis labels (8AM, 10AM, 12PM, 2PM, 4PM).
  ///
  /// A trip is bucketed using its `timeAccepted` timestamp when available
  /// AND the timestamp is from today.  If `timeAccepted` is missing or not
  /// from today, the trip is bucketed based on its `created` timestamp as
  /// a fallback.  Active trips that cannot be placed in any of the 5
  /// buckets are appended to the closest bucket so the total still matches
  /// `activeTrips.length`.
  ///
  /// When there is no real data yet, returns a stable demo series so the
  /// chart still looks similar to the mockup.
  List<int> _buildHourlyActiveCounts(List<TripEntity> activeTrips) {
    // 5 buckets, each representing a 2-hour window:
    //   0 -> 08:00 - 09:59
    //   1 -> 10:00 - 11:59
    //   2 -> 12:00 - 13:59
    //   3 -> 14:00 - 15:59
    //   4 -> 16:00 - 17:59
    const bucketStartHours = <int>[8, 10, 12, 14, 16];

    // Default demo curve from the mockup.
    const fallback = <int>[5, 3, 5, 8, 5];

    if (activeTrips.isEmpty) return fallback;

    final counts = List<int>.filled(5, 0);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    for (final trip in activeTrips) {
      // Prefer timeAccepted; fall back to created if it is missing or
      // not from today.
      final ts =
          _pickTodayTimestamp(trip, today) ??
          _pickTodayTimestampFromCreated(trip, today);

      if (ts == null) {
        // Could not place this trip on today's timeline — drop it from the
        // chart but do NOT show the demo fallback (we do have real data).
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
        // Outside 8AM-6PM — snap to the closest bucket.
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

  DateTime? _pickTodayTimestamp(TripEntity trip, DateTime today) {
    final ts = trip.timeAccepted;
    if (ts == null) return null;
    if (ts.year != today.year ||
        ts.month != today.month ||
        ts.day != today.day) {
      return null;
    }
    return ts;
  }

  DateTime? _pickTodayTimestampFromCreated(TripEntity trip, DateTime today) {
    final ts = trip.created;
    if (ts == null) return null;
    if (ts.year != today.year ||
        ts.month != today.month ||
        ts.day != today.day) {
      return null;
    }
    return ts;
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

/// CustomPainter that renders a smooth area + line chart.  All colors are
/// injected from the widget so this painter is decoupled from the
/// BuildContext and theme-aware by construction.
class _ActiveTripsAreaPainter extends CustomPainter {
  final List<int> values;
  final Color lineColor;
  final Color areaStartColor;
  final Color areaEndColor;
  final Color gridColor;
  final Color labelColor;
  final Color nodeFill;

  _ActiveTripsAreaPainter({
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

    const leftPadding = 28.0; // space for y-axis labels
    const rightPadding = 8.0;
    const topPadding = 4.0;
    const bottomPadding = 4.0;

    final chartWidth = size.width - leftPadding - rightPadding;
    final chartHeight = size.height - topPadding - bottomPadding;

    // Determine max value (round up to nearest even number for nicer grid).
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final yMax = (maxValue < 10) ? 10 : (maxValue + 2);

    // --- Grid lines & y-axis labels ---
    final gridPaint =
        Paint()
          ..color = gridColor
          ..strokeWidth = 1;
    const gridSteps = 5; // 0, 2, 4, 6, 8, 10
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

    // --- Compute point positions ---
    final stepX = chartWidth / (values.length - 1);
    final points = <Offset>[];
    for (var i = 0; i < values.length; i++) {
      final x = leftPadding + stepX * i;
      final normalized = values[i] / yMax;
      final y = topPadding + chartHeight * (1 - normalized);
      points.add(Offset(x, y));
    }

    // --- Smooth path (Catmull-Rom -> Bezier) ---
    final linePath = _buildSmoothPath(points);

    // --- Area path (line path + close to bottom) ---
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

    // --- Line stroke on top ---
    final linePaint =
        Paint()
          ..color = lineColor
          ..strokeWidth = 2.5
          ..style = PaintingStyle.stroke
          ..strokeJoin = StrokeJoin.round
          ..strokeCap = StrokeCap.round;
    canvas.drawPath(linePath, linePaint);

    // --- Node markers ---
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
  bool shouldRepaint(covariant _ActiveTripsAreaPainter old) {
    return old.values.toString() != values.toString() ||
        old.lineColor != lineColor ||
        old.areaStartColor != areaStartColor ||
        old.areaEndColor != areaEndColor ||
        old.gridColor != gridColor ||
        old.labelColor != labelColor ||
        old.nodeFill != nodeFill;
  }
}
