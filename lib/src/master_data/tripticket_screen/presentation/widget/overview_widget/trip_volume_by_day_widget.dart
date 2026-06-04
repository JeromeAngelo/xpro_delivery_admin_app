import 'package:flutter/material.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/trip_ticket/trip/domain/entity/trip_entity.dart';

/// Card widget that shows the "Trip Volume by Day (Current Week)" bar chart
/// matching the Trip Ticket Dashboard design.
class TripVolumeByDayWidget extends StatelessWidget {
  final List<TripEntity> trips;
  final bool isLoading;

  const TripVolumeByDayWidget({
    super.key,
    required this.trips,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final daily = _buildWeeklyCounts(trips);

    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final titleColor = scheme.onSurface;
    final subTextColor = scheme.onSurfaceVariant;
    final barColor = scheme.primary.withOpacity(isDark ? 0.85 : 0.70);
    final valueLabelColor = scheme.onSurface;

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
              'Trip Volume by Day (Current Week)',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: titleColor,
              ),
            ),
            const SizedBox(height: 16),
            if (isLoading)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 80),
                child: Center(
                  child: CircularProgressIndicator(color: scheme.primary),
                ),
              )
            else
              SizedBox(
                height: 200,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return _BarChart(
                      values: daily,
                      width: constraints.maxWidth,
                      barColor: barColor,
                      valueColor: valueLabelColor,
                      labelColor: subTextColor,
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Counts trips per weekday (Mon → Sun) for the current week.
  /// Falls back to the mockup's demo series when no real data is present.
  List<int> _buildWeeklyCounts(List<TripEntity> trips) {
    const demo = [45, 52, 48, 55, 60, 35, 25];
    if (trips.isEmpty) return demo;

    final now = DateTime.now();
    // Compute start of the week (Monday).
    final monday = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: now.weekday - 1));
    final counts = List<int>.filled(7, 0);
    var used = false;

    for (final trip in trips) {
      final created = trip.created;
      if (created == null) continue;
      final dayStart = DateTime(created.year, created.month, created.day);
      final diff = dayStart.difference(monday).inDays;
      if (diff < 0 || diff > 6) continue;
      counts[diff] += 1;
      used = true;
    }

    return used ? counts : demo;
  }
}

class _BarChart extends StatelessWidget {
  final List<int> values;
  final double width;
  final Color barColor;
  final Color valueColor;
  final Color labelColor;

  const _BarChart({
    required this.values,
    required this.width,
    required this.barColor,
    required this.valueColor,
    required this.labelColor,
  });

  static const _dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Each bar gets an equal share of the horizontal space; reserve
        // extra room for the value label above the bar.
        const barCount = 7;
        const reservedForLabel = 22.0;
        final maxValue = values.reduce((a, b) => a > b ? a : b);
        final yMax = (maxValue < 10) ? 10 : (maxValue + 10);

        return Column(
          children: [
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(barCount, (i) {
                  final value = values[i];
                  final h =
                      (value / yMax) *
                      (constraints.maxHeight - reservedForLabel);
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            value.toString(),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: valueColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            width: double.infinity,
                            height: h.clamp(2, constraints.maxHeight),
                            decoration: BoxDecoration(
                              color: barColor,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(4),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children:
                  _dayLabels
                      .map(
                        (label) => Expanded(
                          child: Center(
                            child: Text(
                              label,
                              style: TextStyle(fontSize: 12, color: labelColor),
                            ),
                          ),
                        ),
                      )
                      .toList(),
            ),
          ],
        );
      },
    );
  }
}
