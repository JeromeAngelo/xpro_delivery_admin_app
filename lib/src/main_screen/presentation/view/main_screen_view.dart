import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/common/app/features/general_auth/presentation/bloc/auth_bloc.dart';
import '../../../../core/common/app/features/general_auth/presentation/bloc/auth_state.dart';
import '../../../../core/common/app/features/trip_ticket/trip/domain/entity/trip_entity.dart';
import '../../../../core/common/app/features/trip_ticket/trip/presentation/bloc/trip_bloc.dart';
import '../../../../core/common/app/features/trip_ticket/trip/presentation/bloc/trip_event.dart';
import '../../../../core/common/app/features/trip_ticket/trip/presentation/bloc/trip_state.dart';
import '../../../../core/common/widgets/reusable_widgets/default_drawer.dart';
import '../widgets/dashboard_feature_card.dart';
import '../widgets/dashboard_map_section.dart';
import '../widgets/dashboard_notification_button.dart';
import '../widgets/dashboard_user_menu.dart';

class MainScreenView extends StatefulWidget {
  const MainScreenView({super.key});

  @override
  State<MainScreenView> createState() => _MainScreenViewState();
}

class _MainScreenViewState extends State<MainScreenView> {
  final GlobalKey _themeSelection = GlobalKey();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentState = context.read<GeneralUserBloc>().state;
      debugPrint(
        '🏠 MainScreen initState - Current auth state: ${currentState.runtimeType}',
      );

      if (currentState is UserAuthenticated) {
        debugPrint('✅ User is authenticated: ${currentState.user.email}');
      } else {
        debugPrint('⚠️ User is not authenticated in MainScreen');
      }

      context.read<TripBloc>().add(const GetAllActiveTripTicketsEvent());
    });
  }

  void _onRefreshMap() {
    context.read<TripBloc>().add(const GetAllActiveTripTicketsEvent());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;

    final isWide = screenWidth >= 1400;
    final isMedium = screenWidth >= 1000 && screenWidth < 1400;

    final featureCrossAxisCount = isWide ? 4 : (isMedium ? 2 : 1);
    final quickActionCrossAxisCount = isWide ? 2 : 1;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: scheme.primary,
        actionsIconTheme: IconThemeData(color: scheme.surface),
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: scheme.onSurface),
        title: Text(
          'X-Pro Delivery Admin App',
          style: theme.textTheme.headlineSmall?.copyWith(color: scheme.surface),
        ),
        actions: const [
          DashboardNotificationsButton(),
          DashboardUserMenu(),
          SizedBox(width: 12),
        ],
      ),
      drawer: const DefaultDrawer(),
      body: BlocBuilder<TripBloc, TripState>(
        builder: (context, state) {
          List<TripEntity> activeTrips = [];

          if (state is AllActiveTripTicketsLoaded) {
            activeTrips = state.trips;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Map Overview',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 18),

                DashboardMapSection(
                  activeTrips: activeTrips,
                  isLoading: state is TripLoading,
                  onRefresh: _onRefreshMap,
                ),

                const SizedBox(height: 28),

                Text(
                  'Features',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 18),

                GridView.count(
                  crossAxisCount: featureCrossAxisCount,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: isWide ? 1.7 : 1.55,
                  children: [
                    DashboardFeatureCard(
                      title: 'Trip Tickets',
                      subtitle: 'Trip tickets and current ticket overview.',
                      icon: Icons.confirmation_num_outlined,
                      startColor: scheme.primary,
                      endColor: scheme.primaryContainer,
                      iconColor: scheme.primary,
                      onTap: () => context.go('/trip-overview'),
                    ),
                    DashboardFeatureCard(
                      title: 'Delivery Monitoring',
                      subtitle:
                          'Delivery monitoring for manner and status flow.',
                      icon: Icons.monitor_outlined,
                      startColor: scheme.error,
                      endColor: scheme.errorContainer,
                      iconColor: scheme.error,
                      onTap: () => context.go('/delivery-monitoring'),
                    ),
                    DashboardFeatureCard(
                      title: 'Vehicle Monitoring',
                      subtitle:
                          'Map and vehicle monitoring with live locations.',
                      icon: Icons.map_outlined,
                      startColor: Colors.orange,
                      endColor: Colors.amber.shade200,
                      iconColor: Colors.orange.shade700,
                      onTap: () => context.go('/vehicle-map'),
                    ),
                    DashboardFeatureCard(
                      title: 'Collections',
                      subtitle: 'Collections and cash transaction overview.',
                      icon: Icons.payments_outlined,
                      startColor: Colors.green,
                      endColor: Colors.green.shade200,
                      iconColor: Colors.green.shade700,
                      onTap: () => context.go('/collections-overview'),
                    ),
                  ],
                ),

                const SizedBox(height: 34),

                Text(
                  'Quick Actions',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 18),

                GridView.count(
                  crossAxisCount: quickActionCrossAxisCount,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 16,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: isWide ? 4.8 : 4.2,
                  children: [
                    DashboardFeatureCard(
                      title: 'Users Management',
                      subtitle: 'Manage user accounts and access',
                      icon: Icons.verified_user_outlined,
                      startColor: Colors.redAccent,
                      endColor: Colors.red.shade200,
                      iconColor: Colors.white,
                      onTap: () => context.go('/all-users'),
                    ),
                    DashboardFeatureCard(
                      title: 'Cancelled Deliveries',
                      subtitle: 'View and manage cancelled deliveries',
                      icon: Icons.event_busy_outlined,
                      startColor: Colors.deepPurpleAccent,
                      endColor: Colors.deepPurple.shade200,
                      iconColor: Colors.white,
                      onTap: () => context.go('/undeliverable-customers'),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
