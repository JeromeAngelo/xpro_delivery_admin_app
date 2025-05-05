import 'package:xpro_delivery_admin_app/core/common/app/features/general_auth/domain/entity/users_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/general_auth/presentation/bloc/auth_bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/general_auth/presentation/bloc/auth_event.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/general_auth/presentation/bloc/auth_state.dart';
import 'package:xpro_delivery_admin_app/core/common/widgets/app_structure/desktop_layout.dart';
import 'package:xpro_delivery_admin_app/core/common/widgets/reusable_widgets/app_navigation_items.dart';
import 'package:xpro_delivery_admin_app/src/users/presentation/widgets/all_user_list_widget/all_user_error.dart';
import 'package:xpro_delivery_admin_app/src/users/presentation/widgets/all_user_list_widget/all_user_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class AllUsersView extends StatefulWidget {
  const AllUsersView({super.key});

  @override
  State<AllUsersView> createState() => _DeliveryUsersListViewState();
}

class _DeliveryUsersListViewState extends State<AllUsersView> {
  int _currentPage = 1;
  int _totalPages = 1;
  final int _itemsPerPage = 25;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load delivery users when the screen initializes
    context.read<GeneralUserBloc>().add(const GetAllUsersEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
      child: BlocBuilder<GeneralUserBloc, GeneralUserState>(
        builder: (context, state) {
          // Handle different states
          if (state is GeneralUserInitial) {
            // Initial state, trigger loading
            context.read<GeneralUserBloc>().add(const GetAllUsersEvent());
            return const Center(child: CircularProgressIndicator());
          }

          if (state is GeneralUserLoading) {
            return DeliveryUserDataTable(
              users: [],
              isLoading: true,
              currentPage: _currentPage,
              totalPages: _totalPages,
              onPageChanged: (page) {
                setState(() {
                  _currentPage = page;
                });
              },
              searchController: _searchController,
              searchQuery: _searchQuery,
              onSearchChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            );
          }

          if (state is GeneralUserError) {
            return DeliveryUserErrorWidget(errorMessage: state.message);
          }

          if (state is AllUsersLoaded) {
            List<GeneralUserEntity> users = state.users;

            // Filter users based on search query
            if (_searchQuery.isNotEmpty) {
              users =
                  users.where((user) {
                    final query = _searchQuery.toLowerCase();
                    return (user.name?.toLowerCase().contains(query) ??
                            false) ||
                        (user.email?.toLowerCase().contains(query) ?? false);
                  }).toList();
            }

            // Calculate total pages
            _totalPages = (users.length / _itemsPerPage).ceil();
            if (_totalPages == 0) _totalPages = 1;

            // Paginate users
            final startIndex = (_currentPage - 1) * _itemsPerPage;
            final endIndex =
                startIndex + _itemsPerPage > users.length
                    ? users.length
                    : startIndex + _itemsPerPage;

            final paginatedUsers =
                startIndex < users.length
                    ? users.sublist(startIndex, endIndex)
                    : [];

            return DeliveryUserDataTable(
              users: paginatedUsers as List<GeneralUserEntity>,
              isLoading: false,
              currentPage: _currentPage,
              totalPages: _totalPages,
              onPageChanged: (page) {
                setState(() {
                  _currentPage = page;
                });
              },
              searchController: _searchController,
              searchQuery: _searchQuery,
              onSearchChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
                // If search query is empty, refresh the users list
                if (value.isEmpty) {
                  context.read<GeneralUserBloc>().add(const GetAllUsersEvent());
                }
              },
            );
          }

          // Default fallback
          return const Center(child: Text('Unknown state'));
        },
      ),
    );
  }
}
