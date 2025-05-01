import 'package:flutter/material.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/trip/domain/entity/trip_entity.dart';

class TripStatisticsWidget extends StatelessWidget {
  final List<TripEntity> trips;
  final bool isLoading;

  const TripStatisticsWidget({
    super.key,
    required this.trips,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    // Count active trips (accepted but not ended)
    final activeTrips = trips.where((trip) => 
      trip.isAccepted == true && trip.isEndTrip != true).length;
    
    // Count completed trips (ended)
    final completedTrips = trips.where((trip) => 
      trip.isEndTrip == true).length;
    
    // Count pending trips (not accepted)
    final pendingTrips = trips.where((trip) => 
      trip.isAccepted != true).length;
    
    // Count total trips
    final totalTrips = trips.length;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Trip Statistics',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else
              Row(
                children: [
                  _buildStatCard(
                    context,
                    title: 'Active Trips',
                    value: activeTrips.toString(),
                    icon: Icons.directions_car,
                    color: Colors.blue,
                  ),
                  _buildStatCard(
                    context,
                    title: 'Completed',
                    value: completedTrips.toString(),
                    icon: Icons.check_circle,
                    color: Colors.green,
                  ),
                  _buildStatCard(
                    context,
                    title: 'Pending',
                    value: pendingTrips.toString(),
                    icon: Icons.pending_actions,
                    color: Colors.orange,
                  ),
                  _buildStatCard(
                    context,
                    title: 'Total',
                    value: totalTrips.toString(),
                    icon: Icons.receipt_long,
                    color: Colors.purple,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Card(
        elevation: 0,
        color: color.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: color.withOpacity(0.3)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  Icon(icon, color: color, size: 24),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
