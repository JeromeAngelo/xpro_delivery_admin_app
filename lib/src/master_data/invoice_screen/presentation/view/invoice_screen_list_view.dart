import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/invoice/domain/entity/invoice_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/invoice/presentation/bloc/invoice_bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/invoice/presentation/bloc/invoice_event.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/invoice/presentation/bloc/invoice_state.dart';
import 'package:xpro_delivery_admin_app/core/common/widgets/app_structure/desktop_layout.dart';
import 'package:xpro_delivery_admin_app/core/common/widgets/reusable_widgets/app_navigation_items.dart';
import 'package:xpro_delivery_admin_app/src/master_data/invoice_screen/presentation/widgets/invoice_list_widget/invoice_error_widget.dart';
import 'package:xpro_delivery_admin_app/src/master_data/invoice_screen/presentation/widgets/invoice_list_widget/invoice_data_table.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class InvoiceScreenListView extends StatefulWidget {
  const InvoiceScreenListView({super.key});

  @override
  State<InvoiceScreenListView> createState() => _InvoiceScreenListViewState();
}

class _InvoiceScreenListViewState extends State<InvoiceScreenListView> {
  int _currentPage = 1;
  int _totalPages = 1;
  final int _itemsPerPage = 25; // Same as in tripticket_screen_view.dart
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load invoices when the screen initializes
    context.read<InvoiceBloc>().add(const GetInvoiceEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Define navigation items
    final navigationItems = AppNavigationItems.generalTripItems();

    return DesktopLayout(
      navigationItems: navigationItems,
      currentRoute: '/invoice-list', // Match the route in router.dart
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
      child: BlocBuilder<InvoiceBloc, InvoiceState>(
        builder: (context, state) {
          // Handle different states
          if (state is InvoiceInitial) {
            // Initial state, trigger loading
            context.read<InvoiceBloc>().add(const GetInvoiceEvent());
            return const Center(child: CircularProgressIndicator());
          }

          if (state is InvoiceLoading) {
            return InvoiceDataTable(
              invoices: [],
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
                // Search function will be implemented later
              },
            );
          }

          if (state is InvoiceError) {
            return InvoiceErrorWidget(errorMessage: state.message);
          }

          if (state is InvoiceLoaded) {
            List<InvoiceEntity> invoices = state.invoices;

            // Filter invoices based on search query
            if (_searchQuery.isNotEmpty) {
              invoices =
                  invoices.where((invoice) {
                    final query = _searchQuery.toLowerCase();
                    return (invoice.id?.toLowerCase().contains(query) ??
                            false) ||
                        (invoice.invoiceNumber?.toLowerCase().contains(query) ??
                            false) ||
                        (invoice.customer?.storeName?.toLowerCase().contains(
                              query,
                            ) ??
                            false) ||
                        (invoice.trip?.tripNumberId?.toLowerCase().contains(
                              query,
                            ) ??
                            false);
                  }).toList();
            }

            // Calculate total pages
            _totalPages = (invoices.length / _itemsPerPage).ceil();
            if (_totalPages == 0) _totalPages = 1;

            // Paginate invoices
            final startIndex = (_currentPage - 1) * _itemsPerPage;
            final endIndex =
                startIndex + _itemsPerPage > invoices.length
                    ? invoices.length
                    : startIndex + _itemsPerPage;

            final paginatedInvoices =
                startIndex < invoices.length
                    ? invoices.sublist(startIndex, endIndex)
                    : [];

            return InvoiceDataTable(
              invoices: paginatedInvoices as List<InvoiceEntity>,
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

                // If search query is empty, get all invoices
                if (value.isEmpty) {
                  context.read<InvoiceBloc>().add(const GetInvoiceEvent());
                }
                // Search function will be implemented later
              },
              onRetry: () {
                context.read<InvoiceBloc>().add(const GetInvoiceEvent());
              },
            );
          }

          // Handle other states like TripInvoicesLoaded or CustomerInvoicesLoaded
          if (state is TripInvoicesLoaded) {
            List<InvoiceEntity> invoices = state.invoices;

            // Filter and paginate as above
            if (_searchQuery.isNotEmpty) {
              invoices =
                  invoices.where((invoice) {
                    final query = _searchQuery.toLowerCase();
                    return (invoice.id?.toLowerCase().contains(query) ??
                            false) ||
                        (invoice.invoiceNumber?.toLowerCase().contains(query) ??
                            false) ||
                        (invoice.customer?.storeName?.toLowerCase().contains(
                              query,
                            ) ??
                            false);
                  }).toList();
            }

            _totalPages = (invoices.length / _itemsPerPage).ceil();
            if (_totalPages == 0) _totalPages = 1;

            final startIndex = (_currentPage - 1) * _itemsPerPage;
            final endIndex =
                startIndex + _itemsPerPage > invoices.length
                    ? invoices.length
                    : startIndex + _itemsPerPage;

            final paginatedInvoices =
                startIndex < invoices.length
                    ? invoices.sublist(startIndex, endIndex)
                    : [];

            return InvoiceDataTable(
              invoices: paginatedInvoices as List<InvoiceEntity>,

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
              },
            );
          }

          if (state is CustomerInvoicesLoaded) {
            List<InvoiceEntity> invoices = state.invoices;

            // Filter and paginate as above
            if (_searchQuery.isNotEmpty) {
              invoices =
                  invoices.where((invoice) {
                    final query = _searchQuery.toLowerCase();
                    return (invoice.id?.toLowerCase().contains(query) ??
                            false) ||
                        (invoice.invoiceNumber?.toLowerCase().contains(query) ??
                            false) ||
                        (invoice.trip?.tripNumberId?.toLowerCase().contains(
                              query,
                            ) ??
                            false);
                  }).toList();
            }

            _totalPages = (invoices.length / _itemsPerPage).ceil();
            if (_totalPages == 0) _totalPages = 1;

            final startIndex = (_currentPage - 1) * _itemsPerPage;
            final endIndex =
                startIndex + _itemsPerPage > invoices.length
                    ? invoices.length
                    : startIndex + _itemsPerPage;

            final paginatedInvoices =
                startIndex < invoices.length
                    ? invoices.sublist(startIndex, endIndex)
                    : [];

            return InvoiceDataTable(
              invoices: paginatedInvoices as List<InvoiceEntity>,
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
