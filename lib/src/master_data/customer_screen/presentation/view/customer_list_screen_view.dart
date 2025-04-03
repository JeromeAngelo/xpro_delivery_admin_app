import 'package:desktop_app/core/common/app/features/Trip_Ticket/customer/domain/entity/customer_entity.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/customer/presentation/bloc/customer_bloc.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/customer/presentation/bloc/customer_event.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/customer/presentation/bloc/customer_state.dart';
import 'package:desktop_app/core/common/widgets/app_structure/desktop_layout.dart';
import 'package:desktop_app/core/common/widgets/reusable_widgets/app_navigation_items.dart';
import 'package:desktop_app/src/master_data/customer_screen/presentation/widgets/customer_list_view_widget/customer_data_table.dart';
import 'package:desktop_app/src/master_data/customer_screen/presentation/widgets/customer_list_view_widget/customer_error_widget.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class CustomerListScreenView extends StatefulWidget {
  const CustomerListScreenView({super.key});

  @override
  State<CustomerListScreenView> createState() => _CustomerListScreenViewState();
}

class _CustomerListScreenViewState extends State<CustomerListScreenView> {
  int _currentPage = 1;
  int _totalPages = 1;
  final int _itemsPerPage = 25; // 25 items per page
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load customers when the screen initializes
    context.read<CustomerBloc>().add(const GetAllCustomersEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use the reusable navigation items
    final navigationItems = AppNavigationItems.tripticketNavigationItems();

    return DesktopLayout(
      navigationItems: navigationItems,
      currentRoute: '/customer-list',
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
      child: BlocBuilder<CustomerBloc, CustomerState>(
        builder: (context, state) {
          // Handle different states
          if (state is CustomerInitial) {
            // Initial state, trigger loading
            context.read<CustomerBloc>().add(const GetAllCustomersEvent());
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CustomerLoading) {
            return CustomerDataTable(
              customers: [],
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

          if (state is CustomerError) {
            return CustomerErrorWidget(errorMessage: state.message);
          }

          if (state is AllCustomersLoaded) {
            List<CustomerEntity> customers = state.customers;

            // Filter customers based on search query
            if (_searchQuery.isNotEmpty) {
              customers =
                  customers.where((customer) {
                    final query = _searchQuery.toLowerCase();
                    return (customer.id?.toLowerCase().contains(query) ??
                            false) ||
                        (customer.storeName?.toLowerCase().contains(query) ??
                            false) ||
                        (customer.ownerName?.toLowerCase().contains(query) ??
                            false) ||
                        (customer.address?.toLowerCase().contains(query) ??
                            false) ||
                        (customer.deliveryNumber?.toLowerCase().contains(
                              query,
                            ) ??
                            false);
                  }).toList();
            }

            // Calculate total pages
            _totalPages = (customers.length / _itemsPerPage).ceil();
            if (_totalPages == 0) _totalPages = 1;

            // Paginate customers
            final startIndex = (_currentPage - 1) * _itemsPerPage;
            final endIndex =
                startIndex + _itemsPerPage > customers.length
                    ? customers.length
                    : startIndex + _itemsPerPage;

            final paginatedCustomers =
                startIndex < customers.length
                    ? customers.sublist(startIndex, endIndex)
                    : [];

            return CustomerDataTable(
              customers: paginatedCustomers as List<CustomerEntity>,
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
                  // If search query is cleared, load all customers
                  context.read<CustomerBloc>().add(
                    const GetAllCustomersEvent(),
                  );
                }
                // Search functionality will be implemented later
                // else {
                //   // If search query is not empty, search customers
                //   // context.read<CustomerBloc>().add(SearchCustomersEvent(value));
                // }
              },
              errorMessage: null,
              onRetry: () {
                context.read<CustomerBloc>().add(const GetAllCustomersEvent());
              },
            );
          }

          // Default fallback
          return const Center(
            child: Text(
              'Unknown state - Please check your CustomerBloc implementation',
            ),
          );
        },
      ),
    );
  }
}
