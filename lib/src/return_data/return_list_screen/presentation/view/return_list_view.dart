import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/return_product/domain/entity/return_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/return_product/presentation/bloc/return_bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/return_product/presentation/bloc/return_event.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/return_product/presentation/bloc/return_state.dart';
import 'package:xpro_delivery_admin_app/core/common/widgets/app_structure/desktop_layout.dart';
import 'package:xpro_delivery_admin_app/core/common/widgets/app_structure/empty_data_table.dart';
import 'package:xpro_delivery_admin_app/core/common/widgets/reusable_widgets/app_navigation_items.dart';
import 'package:xpro_delivery_admin_app/src/return_data/return_list_screen/presentation/widgets/return_list_screen_widgets/return_data_table.dart';
import 'package:xpro_delivery_admin_app/src/return_data/return_list_screen/presentation/widgets/return_list_screen_widgets/return_error_widget.dart';
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
            // Check if returns is null or empty
            // Inside the build method, where we check for empty returns:
            if (state.returns.isEmpty) {
              // Use EmptyDataTable when there's no data
              return EmptyDataTable(
                title: 'Returns',
                errorMessage: 'No return data available',
                columns: const [
                  DataColumn(label: Text('Product')),
                  DataColumn(label: Text('Description')),
                  DataColumn(label: Text('Customer')),
                  DataColumn(label: Text('Trip')),
                  DataColumn(label: Text('Reason')),
                  DataColumn(label: Text('Date')),
                  DataColumn(label: Text('Actions')),
                ],
                onRetry: () {
                  context.read<ReturnBloc>().add(const GetAllReturnsEvent());
                },
                onCreatePressed: () {
                  // Navigate to create return screen
                },
                createButtonText: 'Create Return',
                searchBar: SizedBox(
                  height: 48, // Explicit height for the search bar
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search returns...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),
              );
            }

            List<ReturnEntity> returns = state.returns;

            // Filter returns based on search query
            if (_searchQuery.isNotEmpty) {
              returns =
                  returns.where((returnItem) {
                    final query = _searchQuery.toLowerCase();
                    return (returnItem.productName?.toLowerCase().contains(
                              query,
                            ) ??
                            false) ||
                        (returnItem.productDescription?.toLowerCase().contains(
                              query,
                            ) ??
                            false) ||
                        (returnItem.customer?.storeName?.toLowerCase().contains(
                              query,
                            ) ??
                            false) ||
                        (returnItem.trip?.tripNumberId?.toLowerCase().contains(
                              query,
                            ) ??
                            false) ||
                        (returnItem.reason?.toString().toLowerCase().contains(
                              query,
                            ) ??
                            false);
                  }).toList();
            }

            // If filtered returns is empty, show EmptyDataTable
            if (returns.isEmpty) {
              return EmptyDataTable(
                title: 'Returns',
                errorMessage: 'No returns match your search criteria',
                columns: const [
                  DataColumn(label: Text('Product')),
                  DataColumn(label: Text('Description')),
                  DataColumn(label: Text('Customer')),
                  DataColumn(label: Text('Trip')),
                  DataColumn(label: Text('Reason')),
                  DataColumn(label: Text('Date')),
                  DataColumn(label: Text('Actions')),
                ],
                onRetry: () {
                  setState(() {
                    _searchQuery = '';
                    _searchController.clear();
                  });
                  context.read<ReturnBloc>().add(const GetAllReturnsEvent());
                },
                onCreatePressed: () {
                  // Navigate to create return screen
                },
                createButtonText: 'Create Return',
                searchBar: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search returns...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon:
                        _searchQuery.isNotEmpty
                            ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                setState(() {
                                  _searchController.clear();
                                  _searchQuery = '';
                                });
                                context.read<ReturnBloc>().add(
                                  const GetAllReturnsEvent(),
                                );
                              },
                            )
                            : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              );
            }

            // Calculate total pages
            _totalPages = (returns.length / _itemsPerPage).ceil();
            if (_totalPages == 0) _totalPages = 1;

            // Paginate returns
            final startIndex = (_currentPage - 1) * _itemsPerPage;
            final endIndex =
                startIndex + _itemsPerPage > returns.length
                    ? returns.length
                    : startIndex + _itemsPerPage;

            final paginatedReturns =
                startIndex < returns.length
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
