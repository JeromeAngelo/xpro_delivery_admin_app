import 'package:desktop_app/core/common/app/features/Trip_Ticket/trip/domain/entity/trip_entity.dart';
import 'package:desktop_app/core/common/widgets/app_structure/desktop_header.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CollectionTripHeaderWidget extends StatelessWidget {
  final TripEntity trip;
  final VoidCallback? onPrintReport;

  const CollectionTripHeaderWidget({
    super.key,
    required this.trip,
    this.onPrintReport,
  });

  @override
  Widget build(BuildContext context) {
    return DetailedDesktopHeader(
      title: 'Trip Ticket',
      subtitle: trip.tripNumberId ?? 'N/A',
      description: _buildDescription(),
      leadingIcon: const Icon(Icons.receipt_long, size: 32, color: Colors.blue),
      actions: [
        if (onPrintReport != null)
          IconButton(
            icon: const Icon(Icons.print),
            tooltip: 'Print Collection Report',
            onPressed: onPrintReport,
          ),
      ],
      backgroundColor: const Color.fromARGB(255, 39, 38, 38),
      padding: const EdgeInsets.all(20),
    );
  }

  String _buildDescription() {
    final startDate =
        trip.timeAccepted != null
            ? DateFormat('MMM dd, yyyy').format(trip.timeAccepted!)
            : 'N/A';

    final endDate =
        trip.timeEndTrip != null
            ? DateFormat('MMM dd, yyyy').format(trip.timeEndTrip!)
            : 'N/A';

    return 'Started: $startDate | Completed: $endDate';
  }
}
