import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/invoice_data/domain/entity/invoice_data_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/invoice_data/presentation/bloc/invoice_data_bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/invoice_data/presentation/bloc/invoice_data_event.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/invoice_data/presentation/bloc/invoice_data_state.dart';
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
  final int _itemsPerPage = 25; // 25 items per page
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load invoices when the screen initializes
    context.read<InvoiceDataBloc>().add(const GetAllInvoiceDataEvent());
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
      child: BlocBuilder<InvoiceDataBloc, InvoiceDataState>(
        builder: (context, state) {
          // Handle different states
          if (state is InvoiceDataInitial) {
            // Initial state, trigger loading
            context.read<InvoiceDataBloc>().add(const GetAllInvoiceDataEvent());
            return const Center(child: CircularProgressIndicator());
          }

          if (state is InvoiceDataLoading) {
            return SingleChildScrollView(
              child: InvoiceDataTable(
                invoices: const [],
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
              ),
            );
          }

          if (state is InvoiceDataError) {
            return InvoiceErrorWidget(errorMessage: state.message);
          }

          if (state is AllInvoiceDataLoaded) {
            List<InvoiceDataEntity> invoices = state.invoiceData;

            // Filter invoices based on search query
            if (_searchQuery.isNotEmpty) {
              invoices =
                  invoices.where((invoice) {
                    final query = _searchQuery.toLowerCase();
                    return (invoice.id?.toLowerCase().contains(query) ??
                            false) ||
                        (invoice.refId?.toLowerCase().contains(query) ??
                            false) ||
                        (invoice.name?.toLowerCase().contains(query) ??
                            false) ||
                        (invoice.customer?.name?.toLowerCase().contains(
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

            final List<InvoiceDataEntity> paginatedInvoices =
                startIndex < invoices.length
                    ? List<InvoiceDataEntity>.from(
                      invoices.sublist(startIndex, endIndex),
                    )
                    : <InvoiceDataEntity>[];

            return SingleChildScrollView(
              child: InvoiceDataTable(
                invoices: paginatedInvoices,
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
                  context.read<InvoiceDataBloc>().add(
                    const GetAllInvoiceDataEvent(),
                  );
                },
              ),
            );
          }

          // Handle other states like InvoiceDataByDeliveryLoaded or InvoiceDataByCustomerLoaded
          if (state is InvoiceDataByDeliveryLoaded) {
            List<InvoiceDataEntity> invoices = state.invoiceData;

            // Filter and paginate as above
            if (_searchQuery.isNotEmpty) {
              invoices =
                  invoices.where((invoice) {
                    final query = _searchQuery.toLowerCase();
                    return (invoice.id?.toLowerCase().contains(query) ??
                            false) ||
                        (invoice.refId?.toLowerCase().contains(query) ??
                            false) ||
                        (invoice.name?.toLowerCase().contains(query) ??
                            false) ||
                        (invoice.customer?.name?.toLowerCase().contains(
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

            final List<InvoiceDataEntity> paginatedInvoices =
                startIndex < invoices.length
                    ? List<InvoiceDataEntity>.from(
                      invoices.sublist(startIndex, endIndex),
                    )
                    : <InvoiceDataEntity>[];

            return SingleChildScrollView(
              child: InvoiceDataTable(
                invoices: paginatedInvoices,
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
                    _currentPage = 1;
                  });
                },
                errorMessage: null,
                onRetry: () {
                  context.read<InvoiceDataBloc>().add(
                    GetInvoiceDataByDeliveryIdEvent(state.deliveryId),
                  );
                },
              ),
            );
          }

          if (state is InvoiceDataByCustomerLoaded) {
            List<InvoiceDataEntity> invoices = state.invoiceData;

            // Filter and paginate as above
            if (_searchQuery.isNotEmpty) {
              invoices =
                  invoices.where((invoice) {
                    final query = _searchQuery.toLowerCase();
                    return (invoice.id?.toLowerCase().contains(query) ??
                            false) ||
                        (invoice.refId?.toLowerCase().contains(query) ??
                            false) ||
                        (invoice.name?.toLowerCase().contains(query) ?? false);
                  }).toList();
            }

            _totalPages = (invoices.length / _itemsPerPage).ceil();
            if (_totalPages == 0) _totalPages = 1;

            final startIndex = (_currentPage - 1) * _itemsPerPage;
            final endIndex =
                startIndex + _itemsPerPage > invoices.length
                    ? invoices.length
                    : startIndex + _itemsPerPage;

            final List<InvoiceDataEntity> paginatedInvoices =
                startIndex < invoices.length
                    ? List<InvoiceDataEntity>.from(
                      invoices.sublist(startIndex, endIndex),
                    )
                    : <InvoiceDataEntity>[];

            return SingleChildScrollView(
              child: InvoiceDataTable(
                invoices: paginatedInvoices,
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
                    _currentPage = 1;
                  });
                },
                errorMessage: null,
                onRetry: () {
                  context.read<InvoiceDataBloc>().add(
                    GetInvoiceDataByCustomerIdEvent(state.customerId),
                  );
                },
              ),
            );
          }

          // Default fallback
          return const Center(child: Text('Unknown state'));
        },
      ),
    );
  }
}
