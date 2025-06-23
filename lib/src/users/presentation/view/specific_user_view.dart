import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/general_auth/presentation/bloc/auth_bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/general_auth/presentation/bloc/auth_event.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/general_auth/presentation/bloc/auth_state.dart';
import 'package:xpro_delivery_admin_app/core/common/widgets/app_structure/desktop_layout.dart';
import 'package:xpro_delivery_admin_app/core/common/widgets/reusable_widgets/app_navigation_items.dart';
import 'package:xpro_delivery_admin_app/src/users/presentation/widgets/specific_user_widgets/user_details_dashboard.dart';
import 'package:xpro_delivery_admin_app/src/users/presentation/widgets/specific_user_widgets/user_trip_collection_table.dart';

class SpecificUserView extends StatefulWidget {
  final String userId;

  const SpecificUserView({super.key, required this.userId});

  @override
  State<SpecificUserView> createState() => _SpecificUserViewState();
}

class _SpecificUserViewState extends State<SpecificUserView> {
  @override
  void initState() {
    super.initState();
    // Load user data when the screen initializes
    context.read<GeneralUserBloc>().add(GetUserByIdEvent(widget.userId));
  }

  @override
  Widget build(BuildContext context) {
    // Define navigation items
    final navigationItems = AppNavigationItems.usersNavigationItems();

    return DesktopLayout(
      navigationItems: navigationItems,
      currentRoute: '/all-users',
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
      title: 'User Details',
      child: BlocBuilder<GeneralUserBloc, GeneralUserState>(
        builder: (context, state) {
          if (state is GeneralUserLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is GeneralUserError) {
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
                      context.read<GeneralUserBloc>().add(
                        GetUserByIdEvent(widget.userId),
                      );
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is UserByIdLoaded) {
            final user = state.user;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User details dashboard
                  UserDetailsDashboard(
                    user: user,
                    onEdit: () {
                      context.go('/update-user/${user.id}', extra: user);
                    },
                    onDelete: () {
                      // Show delete confirmation dialog
                      _showDeleteConfirmationDialog(context, user.id ?? '');
                    },
                  ),

                  const SizedBox(height: 32),

                  // User trip collection table
                  SizedBox(
                    height: 600, // Fixed height for the table
                    child: UserTripCollectionTable(
                      tripCollections: user.trip_collection,
                      userId: user.id ?? '',
                      onRefresh: () {
                        context.read<GeneralUserBloc>().add(
                          GetUserByIdEvent(widget.userId),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          }

          // Default fallback
          return const Center(child: Text('Select a user to view details'));
        },
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, String userId) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirm Delete'),
            content: const Text(
              'Are you sure you want to delete this user? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                onPressed: () {
                  Navigator.of(context).pop();
                  context.read<GeneralUserBloc>().add(DeleteUserEvent(userId));
                  // Navigate back to users list after deletion
                  context.go('/all-users');
                },
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }
}
