import 'package:flutter/material.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/trip/domain/entity/trip_entity.dart';
import 'package:desktop_app/core/common/widgets/app_structure/data_dashboard.dart';

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
    // Count active trips (accepted but not ended)
    final activeTrips =
        trips
            .where((trip) => trip.isAccepted == true && trip.isEndTrip != true)
            .length;

    // Count completed trips (ended)
    final completedTrips = trips.where((trip) => trip.isEndTrip == true).length;

    // Count pending trips (not accepted)
    final pendingTrips =
        trips
            .where((trip) => trip.isAccepted != true && trip.isEndTrip != true)
            .length;

    // Count total trips
    final totalTrips = trips.length;

    // // Calculate percentages for trends
    // double activePercentage = 0;
    // double completedPercentage = 0;

    // if (totalTrips > 0) {
    //   activePercentage = (activeTrips / totalTrips) * 100;
    //   completedPercentage = (completedTrips / totalTrips) * 100;
    // }

    return DashboardSummary(
      title: 'Summary Trip for Today',
      isLoading: isLoading,
      crossAxisCount: 4, // Show 4 items in a row
      childAspectRatio: 3.0, // Make cards wider than tall
      items: [
        // Active Trips
        DashboardInfoItem(
          icon: Icons.directions_car,
          value: activeTrips.toString(),
          label: 'Active Trips',
          iconColor: Colors.blue,
          //     trend: activePercentage.round(),
        ),

        // Completed Trips
        DashboardInfoItem(
          icon: Icons.check_circle,
          value: completedTrips.toString(),
          label: 'Completed Trips',
          iconColor: Colors.green,
          //       trend: completedPercentage.round(),
        ),

        // Pending Trips
        DashboardInfoItem(
          icon: Icons.pending_actions,
          value: pendingTrips.toString(),
          label: 'Pending Trips',
          iconColor: Colors.orange,
        ),

        // Total Trips
        DashboardInfoItem(
          icon: Icons.receipt_long,
          value: totalTrips.toString(),
          label: 'Total Trips',
          iconColor: Colors.purple,
        ),
      ],
    );
  }
}
