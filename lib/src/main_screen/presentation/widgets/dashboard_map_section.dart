import 'package:flutter/material.dart';

import '../../../../core/common/app/features/trip_ticket/trip/domain/entity/trip_entity.dart';
import 'map_view_widget.dart';

class DashboardMapSection extends StatelessWidget {
  final List<TripEntity> activeTrips;
  final bool isLoading;
  final VoidCallback? onRefresh;
  final VoidCallback? onSelectVehicle;

  const DashboardMapSection({
    super.key,
    required this.activeTrips,
    required this.isLoading,
    this.onSelectVehicle,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: isLoading
            ? const SizedBox(
                height: 340,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            : MapViewWidget(
                trips: activeTrips,
                height: 340,
                width: double.infinity,
                onRefresh: onRefresh,
                onSelectVehicle: onSelectVehicle,
              ),
      ),
    );
  }
}