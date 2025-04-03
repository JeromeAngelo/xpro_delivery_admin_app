import 'package:flutter/material.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/trip/domain/entity/trip_entity.dart';

class TripStatusChip extends StatelessWidget {
  final TripEntity trip;  // Changed from TripModel to TripEntity

  const TripStatusChip({
    super.key,
    required this.trip,
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    String status;
    
    if (trip.isEndTrip == true) {
      color = Colors.green;
      status = 'Completed';
    } else if (trip.isAccepted == true) {
      color = Colors.blue;
      status = 'In Progress';
    } else {
      color = Colors.orange;
      status = 'Pending';
    }

    return Chip(
      label: Text(
        status,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: color,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      visualDensity: VisualDensity.compact,
    );
  }
}
