import 'package:flutter/material.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/trip/domain/entity/trip_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/widgets/app_structure/data_dashboard.dart';
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

    return isLoading 
        ? _buildLoadingSkeleton(context)
        : DashboardSummary(
            title: 'Summary Trip for Today',
            isLoading: false,
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

  Widget _buildLoadingSkeleton(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title skeleton
            Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                width: 200,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Dashboard items skeleton
            GridView.count(
              crossAxisCount: 4,
              childAspectRatio: 3.0,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: List.generate(4, (index) => _buildSkeletonItem(context)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletonItem(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Card(
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon placeholder
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(height: 8),
              
              // Value placeholder
              Container(
                width: 60,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 4),
              
              // Label placeholder
              Container(
                width: 100,
                height: 14,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
