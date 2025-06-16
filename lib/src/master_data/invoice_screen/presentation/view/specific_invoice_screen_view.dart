
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/invoice_data/presentation/bloc/invoice_data_bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/invoice_data/presentation/bloc/invoice_data_event.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/invoice_data/presentation/bloc/invoice_data_state.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/invoice_items/domain/entity/invoice_items_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/invoice_items/presentation/bloc/invoice_items_bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/invoice_items/presentation/bloc/invoice_items_event.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/invoice_items/presentation/bloc/invoice_items_state.dart';
import 'package:xpro_delivery_admin_app/core/common/widgets/app_structure/desktop_layout.dart';
import 'package:xpro_delivery_admin_app/core/common/widgets/reusable_widgets/app_navigation_items.dart';
import 'package:xpro_delivery_admin_app/src/master_data/invoice_screen/presentation/widgets/invoice_specific_widgets/invoice_dashboard.dart';
import 'package:xpro_delivery_admin_app/src/master_data/invoice_screen/presentation/widgets/invoice_specific_widgets/invoice_header.dart';
import 'package:xpro_delivery_admin_app/src/master_data/invoice_screen/presentation/widgets/invoice_specific_widgets/invoice_products_data_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class SpecificInvoiceScreenView extends StatefulWidget {
  final String invoiceId;

  const SpecificInvoiceScreenView({super.key, required this.invoiceId});

  @override
  State<SpecificInvoiceScreenView> createState() =>
      _SpecificInvoiceScreenViewState();
}

class _SpecificInvoiceScreenViewState extends State<SpecificInvoiceScreenView> {
  int _currentPage = 1;
  int _totalPages = 1;
  final int _itemsPerPage = 10;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load invoice details using the new GetInvoiceByIdEvent
    context.read<InvoiceDataBloc>().add(GetInvoiceDataByIdEvent(widget.invoiceId));
    // Load products for this invoice
    context.read<InvoiceItemsBloc>().add(
      GetInvoiceItemsByInvoiceDataIdEvent(widget.invoiceId),
    );
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
      currentRoute: '/invoice-list',
      onNavigate: (route) {
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
      disableScrolling: true,
      child: BlocBuilder<InvoiceDataBloc, InvoiceDataState>(
        builder: (context, state) {
          if (state is InvoiceDataLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is InvoiceDataError) {
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
                      context.read<InvoiceDataBloc>().add(
                        GetInvoiceDataByIdEvent(widget.invoiceId),
                      );
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          // Use the new SingleInvoiceLoaded state to display invoice details
          if (state is InvoiceDataLoaded) {
            final invoice = state.invoiceData;

            return CustomScrollView(
              slivers: [
                // App Bar
                SliverAppBar(
                  automaticallyImplyLeading: false,
                  floating: true,
                  snap: true,
                  title: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () {
                          context.go('/invoices');
                        },
                      ),
                      Text('Invoice: ${invoice.name ?? 'N/A'}'),
                    ],
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      tooltip: 'Refresh',
                      onPressed: () {
                        context.read<InvoiceDataBloc>().add(
                          GetInvoiceDataByIdEvent(widget.invoiceId),
                        );
                        context.read<InvoiceItemsBloc>().add(
                          GetInvoiceItemsByInvoiceDataIdEvent(widget.invoiceId),
                        );
                      },
                    ),
                  ],
                ),

                // Content
                SliverPadding(
                  padding: const EdgeInsets.all(16.0),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Invoice Header
                      InvoiceHeaderWidget(
                        invoice: invoice,
                        onEditPressed: () {
                          // Navigate to edit invoice screen
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Edit invoice feature coming soon'),
                            ),
                          );
                        },
                        onOptionsPressed: () {
                          // Show options menu
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Invoice options coming soon'),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 16),

                      // Invoice Dashboard
                      InvoiceDashboardWidget(invoice: invoice),

                      const SizedBox(height: 16),

                      // Products Table
                      BlocBuilder<InvoiceItemsBloc, InvoiceItemsState>(
                        builder: (context, state) {
                          if (state is InvoiceItemsLoading) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(32.0),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }

                          if (state is InvoiceItemsError) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.all(32.0),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.error_outline,
                                      size: 48,
                                      color: Colors.red[300],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Error loading products: ${state.message}',
                                      style: TextStyle(color: Colors.red[700]),
                                    ),
                                    const SizedBox(height: 16),
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        context.read<InvoiceItemsBloc>().add(
                                          GetInvoiceItemsByInvoiceDataIdEvent(
                                            widget.invoiceId,
                                          ),
                                        );
                                      },
                                      icon: const Icon(Icons.refresh),
                                      label: const Text('Retry'),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          if (state is InvoiceItemsByInvoiceDataIdLoaded &&
                              state.invoiceDataId == widget.invoiceId) {
                            final products = state.invoiceItems;

                            // Filter products based on search query
                            var filteredProducts = products;
                            if (_searchQuery.isNotEmpty) {
                              filteredProducts =
                                  products.where((product) {
                                    final query = _searchQuery.toLowerCase();
                                    return (product.name
                                                ?.toLowerCase()
                                                .contains(query) ??
                                            false) ||
                                        (product.brand
                                                ?.toLowerCase()
                                                .contains(query) ??
                                            false);
                                  }).toList();
                            }

                            // Calculate total pages
                            _totalPages =
                                (filteredProducts.length / _itemsPerPage)
                                    .ceil();
                            if (_totalPages == 0) _totalPages = 1;

                            // Paginate products
                            final startIndex =
                                (_currentPage - 1) * _itemsPerPage;
                            final endIndex =
                                startIndex + _itemsPerPage >
                                        filteredProducts.length
                                    ? filteredProducts.length
                                    : startIndex + _itemsPerPage;

                            final paginatedProducts =
                                startIndex < filteredProducts.length
                                    ? filteredProducts.sublist(
                                      startIndex,
                                      endIndex,
                                    )
                                    : [];

                            return InvoiceProductsDataTable(
                              products:
                                  paginatedProducts as List<InvoiceItemsEntity>,
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
                                // Search function will be implemented later
                              },
                              onAddProduct: () {
                                // Navigate to add product screen
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Add product feature coming soon',
                                    ),
                                  ),
                                );
                              },
                            );
                          }

                          // Default case when products aren't loaded yet
                          return InvoiceProductsDataTable(
                            products: [],
                            isLoading: true,
                            currentPage: 1,
                            totalPages: 1,
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
                            onAddProduct: () {
                              // Navigate to add product screen
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Add product feature coming soon',
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),

                      // Add some bottom padding
                      const SizedBox(height: 32),
                    ]),
                  ),
                ),
              ],
            );
          }

         

          return const Center(child: Text('Select an invoice to view details'));
        },
      ),
    );
  }
}
