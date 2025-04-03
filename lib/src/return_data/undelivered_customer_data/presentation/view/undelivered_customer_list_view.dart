import 'package:desktop_app/core/common/app/features/Trip_Ticket/undeliverable_customer/domain/entity/undeliverable_customer_entity.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/undeliverable_customer/presentation/bloc/undeliverable_customer_bloc.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/undeliverable_customer/presentation/bloc/undeliverable_customer_event.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/undeliverable_customer/presentation/bloc/undeliverable_customer_state.dart';
import 'package:desktop_app/core/common/widgets/app_structure/desktop_layout.dart';
import 'package:desktop_app/core/common/widgets/reusable_widgets/app_navigation_items.dart';
import 'package:desktop_app/src/return_data/undelivered_customer_data/presentation/widgets/undelivered_screen_list_widgets/undeliverable_customer_table.dart';
import 'package:desktop_app/src/return_data/undelivered_customer_data/presentation/widgets/undelivered_screen_list_widgets/undelivered_customer_error_wigdet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class UndeliveredCustomerListView extends StatefulWidget {
  const UndeliveredCustomerListView({super.key});

  @override
  State<UndeliveredCustomerListView> createState() => _UndeliveredCustomerListViewState();
}

class _UndeliveredCustomerListViewState extends State<UndeliveredCustomerListView> {
  int _currentPage = 1;
  int _totalPages = 1;
  final int _itemsPerPage = 25; // 25 items per page
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load undeliverable customers when the screen initializes
    context.read<UndeliverableCustomerBloc>().add(const GetAllUndeliverableCustomersEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use the reusable navigation items
    final navigationItems = AppNavigationItems.returnsNavigationItems();

    return DesktopLayout(
      navigationItems: navigationItems,
      currentRoute: '/undeliverable-customers',
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
      child: BlocBuilder<UndeliverableCustomerBloc, UndeliverableCustomerState>(
        builder: (context, state) {
          // Handle different states
          if (state is UndeliverableCustomerInitial) {
            // Initial state, trigger loading
            context.read<UndeliverableCustomerBloc>().add(const GetAllUndeliverableCustomersEvent());
            return const Center(child: CircularProgressIndicator());
          }

          if (state is UndeliverableCustomerLoading) {
            return UndeliveredCustomerTable(
              undeliveredCustomers: [],
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

          if (state is UndeliverableCustomerError) {
            return UndeliveredCustomerErrorWidget(errorMessage: state.message);
          }

          if (state is AllUndeliverableCustomersLoaded) {
            List<UndeliverableCustomerEntity> customers = state.customers;

            // Filter customers based on search query
            if (_searchQuery.isNotEmpty) {
              customers = customers.where((customer) {
                final query = _searchQuery.toLowerCase();
                return (customer.id?.toLowerCase().contains(query) ?? false) ||
                    (customer.storeName?.toLowerCase().contains(query) ?? false) ||
                    (customer.deliveryNumber?.toLowerCase().contains(query) ?? false) ||
                    (customer.address?.toLowerCase().contains(query) ?? false) ||
                    (customer.municipality?.toLowerCase().contains(query) ?? false) ||
                    (customer.province?.toLowerCase().contains(query) ?? false);
              }).toList();
            }

            // Calculate total pages
            _totalPages = (customers.length / _itemsPerPage).ceil();
            if (_totalPages == 0) _totalPages = 1;

            // Paginate customers
            final startIndex = (_currentPage - 1) * _itemsPerPage;
            final endIndex = startIndex + _itemsPerPage > customers.length
                ? customers.length
                : startIndex + _itemsPerPage;

            final paginatedCustomers = startIndex < customers.length
                ? customers.sublist(startIndex, endIndex)
                : [];

            return UndeliveredCustomerTable(
              undeliveredCustomers: paginatedCustomers as List<UndeliverableCustomerEntity>,
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

                if (value.isEmpty) {
                  // If search query is cleared, load all undeliverable customers
                  context.read<UndeliverableCustomerBloc>().add(
                    const GetAllUndeliverableCustomersEvent(),
                  );
                }
                // Search functionality can be implemented later if needed
              },
            );
          }

          // Default fallback
          return const Center(
            child: Text(
              'Unknown state - Please check your UndeliverableCustomerBloc implementation',
            ),
          );
        },
      ),
    );
  }
}
