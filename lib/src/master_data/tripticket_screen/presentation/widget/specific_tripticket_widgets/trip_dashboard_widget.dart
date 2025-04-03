import 'package:desktop_app/core/common/app/features/Trip_Ticket/trip/domain/entity/trip_entity.dart';
import 'package:desktop_app/core/common/widgets/app_structure/data_dashboard.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TripDashboardWidget extends StatelessWidget {
  final TripEntity trip;

  const TripDashboardWidget({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    String formatDate(DateTime? date) {
      if (date == null) return 'Not set';
      return DateFormat('MM/dd/yyyy hh:mm a').format(date);
    }

    return DashboardSummary(
      items: [
        DashboardInfoItem(
          icon: Icons.numbers,
          value: trip.tripNumberId ?? 'N/A',
          label: 'Trip Number',
        ),
        DashboardInfoItem(
          icon: Icons.people,
          value: trip.customers.length.toString(),
          label: 'Customers',
        ),
        DashboardInfoItem(
          icon: Icons.receipt,
          value: trip.invoices.length.toString(),
          label: 'Invoices',
        ),
        DashboardInfoItem(
          icon: Icons.play_circle_filled,
          value: formatDate(trip.timeAccepted),
          label: 'Start of Trip',
        ),
        DashboardInfoItem(
          icon: Icons.stop_circle,
          value: formatDate(trip.timeEndTrip),
          label: 'End of Trip',
        ),
        DashboardInfoItem(
          icon: Icons.check_circle,
          value: trip.completedCustomers.length.toString(),
          label: 'Completed Deliveries',
        ),
        DashboardInfoItem(
          icon: Icons.cancel,
          value: trip.undeliverableCustomers.length.toString(),
          label: 'Undelivered',
        ),
        DashboardInfoItem(
          icon: Icons.route,
          value: trip.totalTripDistance ?? '0 km',
          label: 'Total Distance',
        ),
      ],
    );
  }
}
