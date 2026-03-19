import 'package:flutter/material.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/trip_ticket/trip/domain/entity/trip_entity.dart';
import 'package:shimmer/shimmer.dart';

class TripTicketSummaryDashboard extends StatelessWidget {
  final List<TripEntity> trips;
  final bool isLoading;

  const TripTicketSummaryDashboard({
    super.key,
    required this.trips,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final activeTrips =
        trips
            .where((trip) => trip.isAccepted == true && trip.isEndTrip != true)
            .length;

    final completedTrips = trips.where((trip) => trip.isEndTrip == true).length;

    final pendingTrips =
        trips
            .where((trip) => trip.isAccepted != true && trip.isEndTrip != true)
            .length;

    final totalTrips = trips.length;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.all(16),
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.all(0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Summary Trip for Today',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),

            isLoading
                ? GridView.count(
                  crossAxisCount: 4,
                  childAspectRatio: 3.2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: List.generate(
                    4,
                    (index) => _buildSkeletonItem(context, index),
                  ),
                )
                : GridView.count(
                  crossAxisCount: 4,
                  childAspectRatio: 3.2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    _buildSummaryTile(
                      context,
                      label: 'Active Trips',
                      value: activeTrips.toString(),
                      icon: Icons.show_chart_rounded,
                      glowColor: const Color(0xFF2D9CFF),
                    ),
                    _buildSummaryTile(
                      context,
                      label: 'Completed Trips',
                      value: completedTrips.toString(),
                      icon: Icons.check_circle_outline_rounded,
                      glowColor: const Color(0xFF22C55E),
                    ),
                    _buildSummaryTile(
                      context,
                      label: 'Pending Trips',
                      value: pendingTrips.toString(),
                      icon: Icons.access_time_rounded,
                      glowColor: const Color(0xFFF59E0B),
                    ),
                    _buildSummaryTile(
                      context,
                      label: 'Total Trips',
                      value: totalTrips.toString(),
                      icon: Icons.people_outline_rounded,
                      glowColor: const Color(0xFFA855F7),
                    ),
                  ],
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryTile(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    required Color glowColor,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final baseColor = scheme.onSurface.withOpacity(
      theme.brightness == Brightness.dark ? 0.15 : 0.05,
    );

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: baseColor,
        border: Border.all(color: glowColor.withOpacity(0.8), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: glowColor.withOpacity(0.28),
            blurRadius: 18,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurface.withOpacity(0.85),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: glowColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: glowColor.withOpacity(0.35)),
                  ),
                  child: Icon(icon, size: 16, color: glowColor),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: theme.textTheme.headlineMedium?.copyWith(
                color: scheme.onSurface,
                fontWeight: FontWeight.w800,
                height: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletonItem(BuildContext context, int index) {
    final colors = [
      const Color(0xFF2D9CFF),
      const Color(0xFF22C55E),
      const Color(0xFFF59E0B),
      const Color(0xFFA855F7),
    ];

    return Shimmer.fromColors(
      baseColor: Colors.white,
      highlightColor: const Color(0xFF374151),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: Colors.white,
          border: Border.all(color: colors[index].withOpacity(0.5), width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 80,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                width: 48,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
