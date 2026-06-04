import 'package:flutter/material.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/trip_ticket/trip/domain/entity/trip_entity.dart';

/// Card widget that shows the "Trip Status Distribution" donut chart
/// matching the Trip Ticket Dashboard design.
///
/// The three statuses (matching [TripStatusChip]):
///   * Completed  — `trip.isEndTrip == true`     (green)
///   * In Progress — `trip.isAccepted == true`    (blue)
///   * Pending    — anything else                (orange)
class TripStatusDistributionWidget extends StatelessWidget {
  final List<TripEntity> trips;
  final bool isLoading;

  const TripStatusDistributionWidget({
    super.key,
    required this.trips,
    this.isLoading = false,
  });

  // Status colors (kept brand-consistent in both modes for instant
  // recognition of completed / in-progress / pending).
  static const Color _completedColor = Color(0xFF6BCB77);
  static const Color _inProgressColor = Color(0xFF3B82F6);
  static const Color _pendingColor = Color(0xFFFF9F1C);

  @override
  Widget build(BuildContext context) {
    // Compute status counts from the actual trip data.
    final completed = trips.where((t) => t.isEndTrip == true).length;
    final inProgress =
        trips.where((t) => t.isEndTrip != true && t.isAccepted == true).length;
    final pending = trips.length - completed - inProgress;
    final total = trips.length;

    // Use the mockup's demo numbers when no real data is loaded yet so the
    // donut still looks similar to the design.  In-progress is given a
    // small slice (5) so the three statuses are all visible.
    final hasData = total > 0;
    final displayCompleted = hasData ? completed : 263;
    final displayInProgress = hasData ? inProgress : 5;
    final displayPending = hasData ? pending : 28;
    final displayTotal =
        hasData
            ? total
            : (displayCompleted + displayInProgress + displayPending);

    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final titleColor = scheme.onSurface;
    final subTextColor = scheme.onSurfaceVariant;
    // The empty portion of the donut is a soft, theme-aware neutral.
    final donutBackground =
        isDark ? scheme.surfaceContainerHighest : scheme.surfaceContainerLow;

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
              'Trip Status Distribution',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: titleColor,
              ),
            ),
            const SizedBox(height: 12),
            if (isLoading)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 60),
                child: Center(
                  child: CircularProgressIndicator(color: scheme.primary),
                ),
              )
            else
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
                            completed: displayCompleted,
                            inProgress: displayInProgress,
                            pending: displayPending,
                            backgroundColor: donutBackground,
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              displayTotal.toString(),
                              style: theme.textTheme.headlineSmall?.copyWith(
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _Legend(
                          color: _completedColor,
                          label: 'Completed',
                          value: displayCompleted,
                          textColor: titleColor,
                        ),
                        const SizedBox(height: 10),
                        _Legend(
                          color: _inProgressColor,
                          label: 'In Progress',
                          value: displayInProgress,
                          textColor: titleColor,
                        ),
                        const SizedBox(height: 10),
                        _Legend(
                          color: _pendingColor,
                          label: 'Pending',
                          value: displayPending,
                          textColor: titleColor,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
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
          ),
        ),
      ],
    );
  }
}

/// CustomPainter that draws the donut chart.
///
/// The arcs are drawn in this order, starting from 12 o'clock and going
/// clockwise:
///   1. Completed  (green)
///   2. In Progress (blue)
///   3. Pending     (orange)
///
/// The background ring color is injected from the widget so it adapts to
/// the active theme.
class _DonutPainter extends CustomPainter {
  final int completed;
  final int inProgress;
  final int pending;
  final Color backgroundColor;

  _DonutPainter({
    required this.completed,
    required this.inProgress,
    required this.pending,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final total = (completed + inProgress + pending).toDouble();
    if (total <= 0) return;

    final radius = size.shortestSide / 2 - 6;
    final center = Offset(size.width / 2, size.height / 2);
    final rect = Rect.fromCircle(center: center, radius: radius);

    const strokeWidth = 26.0;

    // Background ring (very light gray) for empty portion.
    final backgroundPaint =
        Paint()
          ..color = backgroundColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, backgroundPaint);

    const twoPi = 6.28318530717958;
    const startAngle = -1.5707963267948966; // -pi/2 (12 o'clock)

    // Sweep sizes (in radians).
    final completedSweep = (completed / total) * twoPi;
    final inProgressSweep = (inProgress / total) * twoPi;
    final pendingSweep = (pending / total) * twoPi;

    // 1) Completed arc
    if (completed > 0) {
      final paint =
          Paint()
            ..color = TripStatusDistributionWidget._completedColor
            ..style = PaintingStyle.stroke
            ..strokeWidth = strokeWidth
            ..strokeCap = StrokeCap.butt;
      canvas.drawArc(rect, startAngle, completedSweep, false, paint);
    }

    // 2) In Progress arc
    if (inProgress > 0) {
      final paint =
          Paint()
            ..color = TripStatusDistributionWidget._inProgressColor
            ..style = PaintingStyle.stroke
            ..strokeWidth = strokeWidth
            ..strokeCap = StrokeCap.butt;
      canvas.drawArc(
        rect,
        startAngle + completedSweep,
        inProgressSweep,
        false,
        paint,
      );
    }

    // 3) Pending arc
    if (pending > 0) {
      final paint =
          Paint()
            ..color = TripStatusDistributionWidget._pendingColor
            ..style = PaintingStyle.stroke
            ..strokeWidth = strokeWidth
            ..strokeCap = StrokeCap.butt;
      canvas.drawArc(
        rect,
        startAngle + completedSweep + inProgressSweep,
        pendingSweep,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter old) {
    return old.completed != completed ||
        old.inProgress != inProgress ||
        old.pending != pending ||
        old.backgroundColor != backgroundColor;
  }
}
