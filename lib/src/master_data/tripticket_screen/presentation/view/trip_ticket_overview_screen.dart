import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/trip/domain/entity/trip_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/widgets/reusable_widgets/app_navigation_items.dart';
import 'package:xpro_delivery_admin_app/src/master_data/tripticket_screen/presentation/widget/overview_widget/quick_access_widget.dart';
import 'package:xpro_delivery_admin_app/src/master_data/tripticket_screen/presentation/widget/overview_widget/recent_trips_widget.dart';
import 'package:xpro_delivery_admin_app/src/master_data/tripticket_screen/presentation/widget/tripticket_screen_widgets/tripticket_summary_dashboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/trip/presentation/bloc/trip_bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/trip/presentation/bloc/trip_event.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/trip/presentation/bloc/trip_state.dart';
import 'package:xpro_delivery_admin_app/core/common/widgets/app_structure/desktop_layout.dart';

class TripTicketOverviewScreen extends StatefulWidget {
  const TripTicketOverviewScreen({super.key});

  @override
  State<TripTicketOverviewScreen> createState() =>
      _TripTicketOverviewScreenState();
}

class _TripTicketOverviewScreenState extends State<TripTicketOverviewScreen> {
  @override
  void initState() {
    super.initState();
    // Load trip tickets when the screen initializes
    context.read<TripBloc>().add(const GetAllTripTicketsEvent());
  }

  @override
  Widget build(BuildContext context) {
    // Define navigation items
    final navigationItems = AppNavigationItems.generalTripItems();

    return DesktopLayout(
      navigationItems: navigationItems,
      currentRoute: '/trip-overview',
      onNavigate: (route) {
        // Handle navigation using GoRouter
        context.go(route);
      },
      onThemeToggle: () {
        // Handle theme toggle
      },
      onNotificationTap: () {
        // Handle notification tap
      },
      onProfileTap: () {
        // Handle profile tap
      },
      title: 'Trip Ticket Dashboard',
      child: BlocBuilder<TripBloc, TripState>(
        builder: (context, state) {
          // Handle different states
          if (state is TripInitial) {
            // Initial state, trigger loading
            context.read<TripBloc>().add(const GetAllTripTicketsEvent());
            return const Center(child: CircularProgressIndicator());
          }

          if (state is TripLoading) {
            return _buildContent(context, [], true);
          }

          if (state is TripError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${state.message}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<TripBloc>().add(
                        const GetAllTripTicketsEvent(),
                      );
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is AllTripTicketsLoaded ||
              state is TripTicketsSearchResults) {
            final trips =
                state is AllTripTicketsLoaded
                    ? state.trips
                    : (state as TripTicketsSearchResults).trips;

            return _buildContent(context, trips, false);
          }

          // Default fallback
          return const Center(child: Text('Unknown state'));
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, List trips, bool isLoading) {
    final typedTrips = trips.cast<TripEntity>();
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Dashboard
            TripTicketSummaryDashboard(trips: typedTrips, isLoading: isLoading),

            const SizedBox(height: 24),

            // Quick Access Buttons
            const QuickAccessWidget(),

            const SizedBox(height: 24),

            const SizedBox(height: 24),

            // Recent Trips
            RecentTripsWidget(trips: typedTrips, isLoading: isLoading),

            const SizedBox(height: 24),

            // Additional Info Card
            //  _buildInfoCard(context),
          ],
        ),
      ),
    );
  }
}
