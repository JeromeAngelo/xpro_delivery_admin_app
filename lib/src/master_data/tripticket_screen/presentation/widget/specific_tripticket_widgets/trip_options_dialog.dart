import 'package:desktop_app/core/common/app/features/Trip_Ticket/trip/domain/entity/trip_entity.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/trip/presentation/bloc/trip_bloc.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/trip/presentation/bloc/trip_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

void showTripOptionsDialog(BuildContext context, TripEntity trip) {
  showDialog<void>(
    context: context,
    builder: (BuildContext dialogContext) {
      return SimpleDialog(
        title: const Text('Trip Options'),
        children: <Widget>[
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(dialogContext);
              // Print trip details
              _showPrintDialog(context, trip);
            },
            child: const ListTile(
              leading: Icon(Icons.print),
              title: Text('Print Trip Ticket'),
            ),
          ),
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(dialogContext);
              // Export trip data
              _showExportDialog(context, trip);
            },
            child: const ListTile(
              leading: Icon(Icons.download),
              title: Text('Export Data'),
            ),
          ),
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(dialogContext);
              // Show trip history
              _showTripHistory(context, trip);
            },
            child: const ListTile(
              leading: Icon(Icons.history),
              title: Text('View History'),
            ),
          ),
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(dialogContext);
              // Duplicate trip
              _duplicateTrip(context, trip);
            },
            child: const ListTile(
              leading: Icon(Icons.copy),
              title: Text('Duplicate Trip'),
            ),
          ),
          const Divider(),
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(dialogContext);
              // Show delete confirmation
              _showDeleteConfirmation(context, trip);
            },
            child: const ListTile(
              leading: Icon(Icons.delete, color: Colors.red),
              title: Text('Delete Trip', style: TextStyle(color: Colors.red)),
            ),
          ),
        ],
      );
    },
  );
}

void _showPrintDialog(BuildContext context, TripEntity trip) {
  showDialog<void>(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: const Text('Print Trip Ticket'),
        content: const Text('This will generate a printable PDF of the trip ticket. Continue?'),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(dialogContext).pop();
            },
          ),
          TextButton(
            child: const Text('Print'),
            onPressed: () {
              Navigator.of(dialogContext).pop();
              // Implement print functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Printing trip ticket...')),
              );
            },
          ),
        ],
      );
    },
  );
}

void _showExportDialog(BuildContext context, TripEntity trip) {
  showDialog<void>(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: const Text('Export Trip Data'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select export format:'),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.description),
              title: const Text('Excel (.xlsx)'),
              onTap: () {
                Navigator.of(dialogContext).pop();
                // Export as Excel
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Exporting as Excel...')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: const Text('PDF (.pdf)'),
              onTap: () {
                Navigator.of(dialogContext).pop();
                // Export as PDF
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Exporting as PDF...')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.code),
              title: const Text('CSV (.csv)'),
              onTap: () {
                Navigator.of(dialogContext).pop();
                // Export as CSV
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Exporting as CSV...')),
                );
              },
            ),
          ],
        ),
      );
    },
  );
}

void _showTripHistory(BuildContext context, TripEntity trip) {
  // Implement trip history view
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Trip history feature coming soon')),
  );
}

void _duplicateTrip(BuildContext context, TripEntity trip) {
  showDialog<void>(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: const Text('Duplicate Trip'),
        content: const Text('This will create a new trip with the same customers and settings. Continue?'),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(dialogContext).pop();
            },
          ),
          TextButton(
            child: const Text('Duplicate'),
            onPressed: () {
              Navigator.of(dialogContext).pop();
              // Implement duplication functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Duplicating trip...')),
              );
            },
          ),
        ],
      );
    },
  );
}

void _showDeleteConfirmation(BuildContext context, TripEntity trip) {
  showDialog<void>(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: const Text('Delete Trip'),
        content: Text('Are you sure you want to delete trip ${trip.tripNumberId}? This action cannot be undone.'),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(dialogContext).pop();
            },
          ),
          TextButton(
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
            onPressed: () {
              Navigator.of(dialogContext).pop();
              if (trip.id != null) {
                // Delete the trip
                context.read<TripBloc>().add(DeleteTripTicketEvent(trip.id!));
                // Navigate back to trip list
                context.go('/tripticket');
              }
            },
          ),
        ],
      );
    },
  );
}
