import 'package:desktop_app/core/common/app/features/Trip_Ticket/return_product/domain/entity/return_entity.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/return_product/presentation/bloc/return_bloc.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/return_product/presentation/bloc/return_event.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/return_product/presentation/bloc/return_state.dart';
import 'package:desktop_app/core/common/widgets/app_structure/desktop_layout.dart';
import 'package:desktop_app/core/common/widgets/reusable_widgets/app_navigation_items.dart';
import 'package:desktop_app/src/return_data/return_list_screen/presentation/widgets/return_list_screen_widgets/return_data_table.dart';
import 'package:desktop_app/src/return_data/return_list_screen/presentation/widgets/return_list_screen_widgets/return_error_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ReturnListView extends StatefulWidget {
  const ReturnListView({super.key});

  @override
  State<ReturnListView> createState() => _ReturnListViewState();
}

class _ReturnListViewState extends State<ReturnListView> {
  int _currentPage = 1;
  int _totalPages = 1;
  final int _itemsPerPage = 25; // Same as product_list_screen_view.dart
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load returns when the screen initializes
    context.read<ReturnBloc>().add(const GetAllReturnsEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Define navigation items
    final navigationItems = AppNavigationItems.returnsNavigationItems();

    return DesktopLayout(
      navigationItems: navigationItems,
      currentRoute: '/returns', // Match the route in app_navigation_items.dart
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
      child: BlocBuilder<ReturnBloc, ReturnState>(
        builder: (context, state) {
          // Handle different states
          if (state is ReturnInitial) {
            // Initial state, trigger loading
            context.read<ReturnBloc>().add(const GetAllReturnsEvent());
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ReturnLoading) {
            return ReturnDataTable(
              returns: [],
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

          if (state is ReturnError) {
            return ReturnErrorWidget(errorMessage: state.message);
          }

          if (state is AllReturnsLoaded) {
            List<ReturnEntity> returns = state.returns;

            // Filter returns based on search query
            if (_searchQuery.isNotEmpty) {
              returns = returns.where((returnItem) {
                final query = _searchQuery.toLowerCase();
                return (returnItem.productName?.toLowerCase().contains(query) ?? false) ||
                       (returnItem.productDescription?.toLowerCase().contains(query) ?? false) ||
                       (returnItem.customer?.storeName?.toLowerCase().contains(query) ?? false) ||
                       (returnItem.trip?.tripNumberId?.toLowerCase().contains(query) ?? false) ||
                       (returnItem.reason?.toString().toLowerCase().contains(query) ?? false);
              }).toList();
            }

            // Calculate total pages
            _totalPages = (returns.length / _itemsPerPage).ceil();
            if (_totalPages == 0) _totalPages = 1;

            // Paginate returns
            final startIndex = (_currentPage - 1) * _itemsPerPage;
            final endIndex = startIndex + _itemsPerPage > returns.length
                ? returns.length
                : startIndex + _itemsPerPage;

            final paginatedReturns = startIndex < returns.length
                ? returns.sublist(startIndex, endIndex)
                : [];

            return ReturnDataTable(
              returns: paginatedReturns as List<ReturnEntity>,
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
                // If search query is empty, refresh the returns list
                if (value.isEmpty) {
                  context.read<ReturnBloc>().add(const GetAllReturnsEvent());
                }
                // You could implement a debounced search here if needed
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
