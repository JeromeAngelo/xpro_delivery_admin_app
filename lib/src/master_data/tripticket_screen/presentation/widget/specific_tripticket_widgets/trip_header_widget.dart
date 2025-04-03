import 'package:desktop_app/core/common/app/features/Trip_Ticket/trip/domain/entity/trip_entity.dart';
import 'package:desktop_app/core/common/widgets/app_structure/desktop_header.dart';
import 'package:flutter/material.dart';

class TripHeaderWidget extends StatelessWidget {
  final TripEntity trip;
  final VoidCallback? onEditPressed;
  final VoidCallback? onOptionsPressed;

  const TripHeaderWidget({
    super.key,
    required this.trip,
    this.onEditPressed,
    this.onOptionsPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: DetailedDesktopHeader(
          title: 'Trip Ticket Details',
          subtitle: trip.tripNumberId ?? 'No Trip Number',
          leadingIcon: Icon(
            Icons.receipt_long,
            size: 32,
            color: Theme.of(context).colorScheme.primary,
          ),
          actions: [
            if (onEditPressed != null)
              IconButton(
                icon: const Icon(Icons.edit),
                tooltip: 'Edit Trip',
                onPressed: onEditPressed,
              ),
            if (onOptionsPressed != null)
              IconButton(
                icon: const Icon(Icons.more_vert),
                tooltip: 'More Options',
                onPressed: onOptionsPressed,
              ),
          ],
          showDivider: false,
          backgroundColor: Theme.of(context).cardColor,
        ),
      ),
    );
  }
}
