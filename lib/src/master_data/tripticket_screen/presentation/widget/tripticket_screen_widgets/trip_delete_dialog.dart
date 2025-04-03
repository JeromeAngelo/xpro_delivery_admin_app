import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/trip/data/models/trip_models.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/trip/presentation/bloc/trip_bloc.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/trip/presentation/bloc/trip_event.dart';

class TripDeleteDialog extends StatelessWidget {
  final TripModel trip;

  const TripDeleteDialog({
    super.key,
    required this.trip,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Confirm Delete'),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            Text('Are you sure you want to delete Trip Ticket ${trip.tripNumberId}?'),
            const SizedBox(height: 10),
            const Text('This action cannot be undone.'),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text('Delete', style: TextStyle(color: Colors.red)),
          onPressed: () {
            Navigator.of(context).pop();
            if (trip.id != null) {
              context.read<TripBloc>().add(DeleteTripTicketEvent(trip.id!));
            }
          },
        ),
      ],
    );
  }
}

Future<void> showTripDeleteDialog(BuildContext context, TripModel trip) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext dialogContext) {
      return TripDeleteDialog(trip: trip);
    },
  );
}
