import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/completed_customer/domain/entity/completed_customer_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/completed_customer/presentation/bloc/completed_customer_bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/completed_customer/presentation/bloc/completed_customer_event.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/completed_customer/presentation/bloc/completed_customer_state.dart';
import 'package:xpro_delivery_admin_app/core/common/widgets/app_structure/desktop_layout.dart';
import 'package:xpro_delivery_admin_app/core/common/widgets/reusable_widgets/app_navigation_items.dart';
import 'package:xpro_delivery_admin_app/src/collection_data/completed_customer_list/presentation/widgets/completed_customer_list_widgets/completed_customer_error_widget.dart';
import 'package:xpro_delivery_admin_app/src/collection_data/completed_customer_list/presentation/widgets/completed_customer_list_widgets/completed_customer_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class CompletedCustomerListScreen extends StatefulWidget {
  const CompletedCustomerListScreen({super.key});

  @override
  State<CompletedCustomerListScreen> createState() =>
      _CompletedCustomerListScreenState();
}

class _CompletedCustomerListScreenState
    extends State<CompletedCustomerListScreen> {
  int _currentPage = 1;
  int _totalPages = 1;
  final int _itemsPerPage = 25; // 25 items per page
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load completed customers when the screen initializes
    context.read<CompletedCustomerBloc>().add(
      const GetAllCompletedCustomersEvent(),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use the reusable navigation items
    final navigationItems = AppNavigationItems.collectionNavigationItems();

    return DesktopLayout(
      navigationItems: navigationItems,
      currentRoute: '/completed-customers',
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

      child: BlocBuilder<CompletedCustomerBloc, CompletedCustomerState>(
        builder: (context, state) {
          // Handle different states
          if (state is CompletedCustomerInitial) {
            // Initial state, trigger loading
            context.read<CompletedCustomerBloc>().add(
              const GetAllCompletedCustomersEvent(),
            );
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CompletedCustomerLoading) {
            return CompletedCustomerDataTable(
              completedCustomers: [],
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

          if (state is CompletedCustomerError) {
            return CompletedCustomerErrorWidget(errorMessage: state.message);
          }

          if (state is AllCompletedCustomersLoaded) {
            List<CompletedCustomerEntity> completedCustomers = state.customers;

            // Filter completed customers based on search query
            if (_searchQuery.isNotEmpty) {
              completedCustomers =
                  completedCustomers.where((customer) {
                    final query = _searchQuery.toLowerCase();
                    return (customer.storeName?.toLowerCase().contains(query) ??
                            false) ||
                        (customer.deliveryNumber?.toLowerCase().contains(
                              query,
                            ) ??
                            false) ||
                        (customer.ownerName?.toLowerCase().contains(query) ??
                            false) ||
                        (customer.address?.toLowerCase().contains(query) ??
                            false) ||
                        (customer.trip?.tripNumberId?.toLowerCase().contains(
                              query,
                            ) ??
                            false);
                  }).toList();
            }

            // Calculate total pages
            _totalPages = (completedCustomers.length / _itemsPerPage).ceil();
            if (_totalPages == 0) _totalPages = 1;

            // Paginate completed customers
            final startIndex = (_currentPage - 1) * _itemsPerPage;
            final endIndex =
                startIndex + _itemsPerPage > completedCustomers.length
                    ? completedCustomers.length
                    : startIndex + _itemsPerPage;

            final paginatedCustomers =
                startIndex < completedCustomers.length
                    ? completedCustomers.sublist(startIndex, endIndex)
                    : [];

            return CompletedCustomerDataTable(
              completedCustomers:
                  paginatedCustomers as List<CompletedCustomerEntity>,
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
                  // If search query is cleared, load all completed customers
                  context.read<CompletedCustomerBloc>().add(
                    const GetAllCompletedCustomersEvent(),
                  );
                }
                // Search functionality can be implemented later if needed
              },
              errorMessage: null,
              onRetry: () {
                context.read<CompletedCustomerBloc>().add(
                  const GetAllCompletedCustomersEvent(),
                );
              },
            );
          }

          // Default fallback
          return const Center(
            child: Text(
              'Unknown state - Please check your CompletedCustomerBloc implementation',
            ),
          );
        },
      ),
    );
  }
}
