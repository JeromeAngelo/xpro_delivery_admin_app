
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/cancelled_invoices/domain/entity/cancelled_invoice_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/cancelled_invoices/presentation/bloc/cancelled_invoice_bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/cancelled_invoices/presentation/bloc/cancelled_invoice_state.dart';
import 'package:xpro_delivery_admin_app/core/common/widgets/app_structure/desktop_layout.dart';
import 'package:xpro_delivery_admin_app/core/common/widgets/app_structure/empty_data_table.dart';
import 'package:xpro_delivery_admin_app/core/common/widgets/reusable_widgets/app_navigation_items.dart';
import 'package:xpro_delivery_admin_app/src/return_data/undelivered_customer_data/presentation/widgets/undelivered_screen_list_widgets/undeliverable_customer_table.dart';
import 'package:xpro_delivery_admin_app/src/return_data/undelivered_customer_data/presentation/widgets/undelivered_screen_list_widgets/undelivered_customer_error_wigdet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/common/app/features/Trip_Ticket/cancelled_invoices/presentation/bloc/cancelled_invoice_event.dart';

class UndeliveredCustomerListView extends StatefulWidget {
  const UndeliveredCustomerListView({super.key});

  @override
  State<UndeliveredCustomerListView> createState() =>
      _UndeliveredCustomerListViewState();
}

class _UndeliveredCustomerListViewState
    extends State<UndeliveredCustomerListView> {
  int _currentPage = 1;
  int _totalPages = 1;
  final int _itemsPerPage = 25; // 25 items per page
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load undeliverable customers when the screen initializes
    context.read<CancelledInvoiceBloc>().add(
      const GetAllCancelledInvoicesEvent(),
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
      child: BlocBuilder<CancelledInvoiceBloc, CancelledInvoiceState>(
        builder: (context, state) {
          // Handle different states
          if (state is CancelledInvoiceInitial) {
            // Initial state, trigger loading
            context.read<CancelledInvoiceBloc>().add(
              const GetAllCancelledInvoicesEvent(),
            );
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CancelledInvoiceLoading) {
            return UndeliveredCustomerTable(
              cancelledInvoices: [],
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

          if (state is CancelledInvoiceError) {
            return UndeliveredCustomerErrorWidget(errorMessage: state.message);
          }

          if (state is AllCancelledInvoicesLoaded) {
            // Check if customers list is null or empty
            if (state.cancelledInvoices.isEmpty) {
              return EmptyDataTable(
                title: 'Undeliverable Customers',
                errorMessage: 'No undeliverable customers found',
                columns: const [
                  DataColumn(label: Text('ID')),
                  DataColumn(label: Text('Store Name')),
                  DataColumn(label: Text('Delivery Number')),
                  DataColumn(label: Text('Address')),
                  DataColumn(label: Text('Municipality')),
                  DataColumn(label: Text('Province')),
                  DataColumn(label: Text('Actions')),
                ],
                onRetry: () {
                  context.read<CancelledInvoiceBloc>().add(
                    const GetAllCancelledInvoicesEvent(),
                  );
                },
                onCreatePressed: () {
                  // Navigate to create undeliverable customer screen
                  // Implement this based on your navigation requirements
                },
                createButtonText: 'Add Undeliverable Customer',
                searchBar: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by ID, Store Name, or Address...',
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
              );
            }

            List<CancelledInvoiceEntity> cancelledInvoice =
                state.cancelledInvoices;

            // Filter customers based on search query
            if (_searchQuery.isNotEmpty) {
              cancelledInvoice =
                  cancelledInvoice.where((cancelledInvoice) {
                    final query = _searchQuery.toLowerCase();
                    return (cancelledInvoice.id?.toLowerCase().contains(
                              query,
                            ) ??
                            false) ||
                        (cancelledInvoice.customer!.name
                                ?.toLowerCase()
                                .contains(query) ??
                            false) ||
                        (cancelledInvoice.deliveryData!.deliveryNumber
                                ?.toLowerCase()
                                .contains(query) ??
                            false) ||
                        (cancelledInvoice.trip!.tripNumberId
                                ?.toLowerCase()
                                .contains(query) ??
                            false);
                  }).toList();
            }

            // If filtered customers is empty, show EmptyDataTable
            if (cancelledInvoice.isEmpty) {
              return EmptyDataTable(
                title: 'Undeliverable Customers',
                errorMessage: 'No customers match your search criteria',
                columns: const [
                  DataColumn(label: Text('ID')),
                  DataColumn(label: Text('Store Name')),
                  DataColumn(label: Text('Delivery Number')),
                  DataColumn(label: Text('Address')),
                  DataColumn(label: Text('Municipality')),
                  DataColumn(label: Text('Province')),
                  DataColumn(label: Text('Actions')),
                ],
                onRetry: () {
                  setState(() {
                    _searchQuery = '';
                    _searchController.clear();
                  });
                  context.read<CancelledInvoiceBloc>().add(
                    const GetAllCancelledInvoicesEvent(),
                  );
                },
                onCreatePressed: () {
                  // Navigate to create undeliverable customer screen
                },
                createButtonText: 'Add Undeliverable Customer',
                searchBar: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by ID, Store Name, or Address...',
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
                                context.read<CancelledInvoiceBloc>().add(
                                  const GetAllCancelledInvoicesEvent(),
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
            _totalPages = (cancelledInvoice.length / _itemsPerPage).ceil();
            if (_totalPages == 0) _totalPages = 1;

            // Paginate customers
            final startIndex = (_currentPage - 1) * _itemsPerPage;
            final endIndex =
                startIndex + _itemsPerPage > cancelledInvoice.length
                    ? cancelledInvoice.length
                    : startIndex + _itemsPerPage;

            final paginatedCustomers =
                startIndex < cancelledInvoice.length
                    ? cancelledInvoice.sublist(startIndex, endIndex)
                    : [];

            return UndeliveredCustomerTable(
              cancelledInvoices:
                  paginatedCustomers as List<CancelledInvoiceEntity>,
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
                  context.read<CancelledInvoiceBloc>().add(
                    const GetAllCancelledInvoicesEvent(),
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
