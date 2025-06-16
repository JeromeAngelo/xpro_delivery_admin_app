import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/invoice_items/domain/entity/invoice_items_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/invoice_items/presentation/bloc/invoice_items_bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/invoice_items/presentation/bloc/invoice_items_event.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/invoice_items/presentation/bloc/invoice_items_state.dart';
import 'package:xpro_delivery_admin_app/core/common/widgets/app_structure/desktop_layout.dart';
import 'package:xpro_delivery_admin_app/core/common/widgets/reusable_widgets/app_navigation_items.dart';
import 'package:xpro_delivery_admin_app/src/master_data/product_list_screen/presentation/widgets/product_list_widget/product_table.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ProductListScreenView extends StatefulWidget {
  const ProductListScreenView({super.key});

  @override
  State<ProductListScreenView> createState() => _ProductListScreenViewState();
}

class _ProductListScreenViewState extends State<ProductListScreenView> {
  int _currentPage = 1;
  int _totalPages = 1;
  final int _itemsPerPage = 25; // 25 items per page
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load products when the screen initializes
    context.read<InvoiceItemsBloc>().add(const GetAllInvoiceItemsEvent());
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
      currentRoute:
          '/product-list', // Match the route in app_navigation_items.dart
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
      child: BlocBuilder<InvoiceItemsBloc, InvoiceItemsState>(
        builder: (context, state) {
          // Handle different states
          if (state is InvoiceItemsInitial) {
            // Initial state, trigger loading
            context.read<InvoiceItemsBloc>().add(
              const GetAllInvoiceItemsEvent(),
            );
            return const Center(child: CircularProgressIndicator());
          }

          if (state is InvoiceItemsLoading) {
            return ProductDataTable(
              products: const [],
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

          if (state is InvoiceItemsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${state.message}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<InvoiceItemsBloc>().add(
                        const GetAllInvoiceItemsEvent(),
                      );
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is AllInvoiceItemsLoaded) {
            List<InvoiceItemsEntity> products = state.invoiceItems;

            // Filter products based on search query
            if (_searchQuery.isNotEmpty) {
              products =
                  products.where((product) {
                    final query = _searchQuery.toLowerCase();
                    return (product.name?.toLowerCase().contains(query) ??
                            false) ||
                        (product.brand?.toLowerCase().contains(query) ??
                            false) ||
                        (product.refId?.toLowerCase().contains(query) ??
                            false) ||
                        (product.uom?.toLowerCase().contains(query) ?? false);
                  }).toList();
            }

            // Calculate total pages
            _totalPages = (products.length / _itemsPerPage).ceil();
            if (_totalPages == 0) _totalPages = 1;

            // Paginate products
            final startIndex = (_currentPage - 1) * _itemsPerPage;
            final endIndex =
                startIndex + _itemsPerPage > products.length
                    ? products.length
                    : startIndex + _itemsPerPage;

            final List<InvoiceItemsEntity> paginatedProducts =
                startIndex < products.length
                    ? products.sublist(startIndex, endIndex)
                    : [];

            return ProductDataTable(
              products: paginatedProducts,
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
                // If search query is empty, refresh the products list
                if (value.isEmpty) {
                  context.read<InvoiceItemsBloc>().add(
                    const GetAllInvoiceItemsEvent(),
                  );
                }
              },
              errorMessage: null,
              onRetry: () {
                context.read<InvoiceItemsBloc>().add(
                  const GetAllInvoiceItemsEvent(),
                );
              },
            );
          }

          // Handle InvoiceItemsByInvoiceDataIdLoaded state
          if (state is InvoiceItemsByInvoiceDataIdLoaded) {
            List<InvoiceItemsEntity> products = state.invoiceItems;

            // Filter products based on search query
            if (_searchQuery.isNotEmpty) {
              products =
                  products.where((product) {
                    final query = _searchQuery.toLowerCase();
                    return (product.name?.toLowerCase().contains(query) ??
                            false) ||
                        (product.brand?.toLowerCase().contains(query) ??
                            false) ||
                        (product.refId?.toLowerCase().contains(query) ??
                            false) ||
                        (product.uom?.toLowerCase().contains(query) ?? false);
                  }).toList();
            }

            // Calculate total pages
            _totalPages = (products.length / _itemsPerPage).ceil();
            if (_totalPages == 0) _totalPages = 1;

            // Paginate products
            final startIndex = (_currentPage - 1) * _itemsPerPage;
            final endIndex =
                startIndex + _itemsPerPage > products.length
                    ? products.length
                    : startIndex + _itemsPerPage;

            final List<InvoiceItemsEntity> paginatedProducts =
                startIndex < products.length
                    ? products.sublist(startIndex, endIndex)
                    : [];

            return ProductDataTable(
              products: paginatedProducts,
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
                context.read<InvoiceItemsBloc>().add(
                  GetInvoiceItemsByInvoiceDataIdEvent(state.invoiceDataId),
                );
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
