import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/trip_ticket/trip/domain/entity/trip_entity.dart';

Future<void> showVehicleDetailsDialog(BuildContext context, TripEntity trip) {
  final theme = Theme.of(context);
  final scheme = theme.colorScheme;

  final vehicleName =
      (trip.vehicle != null)
          ? ((trip.vehicle as dynamic).name?.toString() ??
              trip.tripNumberId ??
              '')
          : (trip.tripNumberId ?? 'Unknown Vehicle');

  final driverName =
      trip.user != null
          ? ((trip.user as dynamic).name ?? (trip.user as dynamic).email ?? '-')
          : '-';

  final name = trip.name ?? '-';
  final latitude = trip.latitude?.toString() ?? '-';
  final longitude = trip.longitude?.toString() ?? '-';
  final lastUpdated =
      trip.lastLocationUpdated != null
          ? _formatDateTime(trip.lastLocationUpdated)
          : 'N/A';

  return showDialog<void>(
    context: context,
    builder: (_) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: 500,
          padding: const EdgeInsets.all(0),
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 18,
                ),
                decoration: BoxDecoration(
                  color: scheme.primary,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.local_shipping_outlined,
                        color: scheme.onPrimary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        vehicleName,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: scheme.onPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                child: Column(
                  children: [
                    _buildDetailRow(
                      context,
                      icon: Icons.confirmation_num_outlined,
                      label: 'Trip Route',
                      value: name,
                    ),
                    const SizedBox(height: 14),
                    _buildDetailRow(
                      context,
                      icon: Icons.person_outline,
                      label: 'Driver',
                      value: driverName,
                    ),
                    const SizedBox(height: 14),
                    _buildDetailRow(
                      context,
                      icon: Icons.my_location,
                      label: 'Latitude',
                      value: latitude,
                    ),
                    const SizedBox(height: 14),
                    _buildDetailRow(
                      context,
                      icon: Icons.place_outlined,
                      label: 'Longitude',
                      value: longitude,
                    ),
                    const SizedBox(height: 14),
                    _buildDetailRow(
                      context,
                      icon: Icons.update,
                      label: 'Last Location Update',
                      value: lastUpdated,
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        context.go('/vehicle-map');
                      },
                      icon: const Icon(Icons.directions),
                      label: const Text('Go to Vehicle'),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        if (trip.id != null) {
                          context.go('/tripticket/${trip.id}');
                        }
                      },
                      icon: const Icon(Icons.trip_origin),
                      label: const Text('View Tripticket'),
                    ),
                    TextButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                      label: const Text('Close'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

Widget _buildDetailRow(
  BuildContext context, {
  required IconData icon,
  required String label,
  required String value,
}) {
  final theme = Theme.of(context);
  final scheme = theme.colorScheme;

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    decoration: BoxDecoration(
      color: scheme.surfaceContainerHighest.withOpacity(0.45),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: scheme.outline.withOpacity(0.12)),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: scheme.primary.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 18, color: scheme.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurface.withOpacity(0.65),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: scheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

String _formatDateTime(DateTime? dateTime) {
  if (dateTime == null) return 'N/A';

  // Convert UTC to Philippine Time (UTC+8)
  final phDateTime = dateTime.add(const Duration(hours: 8));

  final hour24 = phDateTime.hour;
  final hour12 = hour24 == 0 ? 12 : (hour24 > 12 ? hour24 - 12 : hour24);
  final amPm = hour24 >= 12 ? 'PM' : 'AM';

  final month = phDateTime.month.toString().padLeft(2, '0');
  final day = phDateTime.day.toString().padLeft(2, '0');
  final year = phDateTime.year;

  return '$month/$day/$year '
      '${hour12.toString().padLeft(2, '0')}:'
      '${phDateTime.minute.toString().padLeft(2, '0')} $amPm';
}
