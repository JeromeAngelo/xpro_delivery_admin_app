import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/customer_data/domain/entity/customer_data_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/customer_data/presentation/bloc/customer_data_bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/customer_data/presentation/bloc/customer_data_event.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/customer_data/presentation/bloc/customer_data_state.dart';
import 'package:xpro_delivery_admin_app/core/common/widgets/app_structure/desktop_layout.dart';
import 'package:xpro_delivery_admin_app/core/common/widgets/reusable_widgets/app_navigation_items.dart';
import 'package:xpro_delivery_admin_app/src/master_data/customer_screen/presentation/widgets/customer_list_view_widget/customer_data_table.dart';
import 'package:xpro_delivery_admin_app/src/master_data/customer_screen/presentation/widgets/customer_list_view_widget/customer_error_widget.dart';

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
    context.read<CustomerDataBloc>().add(const GetAllCustomerDataEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use the reusable navigation items
    final navigationItems = AppNavigationItems.generalTripItems();

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
      child: BlocBuilder<CustomerDataBloc, CustomerDataState>(
        builder: (context, state) {
          // Handle different states - SAME FORMAT AS INVOICE PRESET GROUPS
          if (state is CustomerDataInitial) {
            // Initial state, trigger loading
            context.read<CustomerDataBloc>().add(const GetAllCustomerDataEvent());
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CustomerDataLoading) {
            // Return the table directly with loading state - NO WRAPPING
            return CustomerDataTable(
              customers: const <CustomerDataEntity>[],
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

          if (state is CustomerDataError) {
            return CustomerErrorWidget(errorMessage: state.message);
          }

          if (state is AllCustomerDataLoaded) {
            // Create an empty list of CustomerDataEntity
            List<CustomerDataEntity> customers = <CustomerDataEntity>[];
            
            // Only try to map if there are items in the list
            if (state.customerData.isNotEmpty) {
              // Safely map each item to CustomerDataEntity
              customers = state.customerData.map((customer) {
                // Ensure each item is a CustomerDataEntity
                return customer;
              }).toList();
            }

            // Filter customers based on search query
            if (_searchQuery.isNotEmpty) {
              customers = customers.where((customer) {
                final query = _searchQuery.toLowerCase();
                return (customer.id?.toLowerCase().contains(query) ?? false) ||
                    (customer.name?.toLowerCase().contains(query) ?? false) ||
                    (customer.refId?.toLowerCase().contains(query) ?? false) ||
                    (customer.province?.toLowerCase().contains(query) ?? false) ||
                    (customer.municipality?.toLowerCase().contains(query) ?? false) ||
                    (customer.barangay?.toLowerCase().contains(query) ?? false);
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

            final List<CustomerDataEntity> paginatedCustomers =
                startIndex < customers.length
                    ? List<CustomerDataEntity>.from(customers.sublist(startIndex, endIndex))
                    : <CustomerDataEntity>[];

            // Return the table directly - NO WRAPPING WITH COLUMN/SINGLECHILDSCROLLVIEW
            return CustomerDataTable(
              customers: paginatedCustomers,
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
                  _currentPage = 1; // Reset to first page when searching
                });
              },
              errorMessage: null,
              onRetry: () {
                context.read<CustomerDataBloc>().add(const GetAllCustomerDataEvent());
              },
            );
          }

          // Default fallback
          return const Center(
            child: Text(
              'Unknown state - Please check your CustomerDataBloc implementation',
            ),
          );
        },
      ),
    );
  }
}
