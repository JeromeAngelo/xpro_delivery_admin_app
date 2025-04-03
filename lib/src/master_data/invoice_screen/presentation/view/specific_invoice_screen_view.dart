import 'package:desktop_app/core/common/app/features/Trip_Ticket/invoice/presentation/bloc/invoice_bloc.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/invoice/presentation/bloc/invoice_event.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/invoice/presentation/bloc/invoice_state.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/products/domain/entity/product_entity.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/products/presentation/bloc/products_bloc.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/products/presentation/bloc/products_event.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/products/presentation/bloc/products_state.dart';
import 'package:desktop_app/core/common/widgets/app_structure/desktop_layout.dart';
import 'package:desktop_app/core/common/widgets/reusable_widgets/app_navigation_items.dart';
import 'package:desktop_app/src/master_data/invoice_screen/presentation/widgets/invoice_specific_widgets/invoice_dashboard.dart';
import 'package:desktop_app/src/master_data/invoice_screen/presentation/widgets/invoice_specific_widgets/invoice_header.dart';
import 'package:desktop_app/src/master_data/invoice_screen/presentation/widgets/invoice_specific_widgets/invoice_products_data_table.dart';
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
    context.read<InvoiceBloc>().add(GetInvoiceByIdEvent(widget.invoiceId));
    // Load products for this invoice
    context.read<ProductsBloc>().add(
      GetProductsByInvoiceIdEvent(widget.invoiceId),
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
    final navigationItems = AppNavigationItems.tripticketNavigationItems();

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
      child: BlocBuilder<InvoiceBloc, InvoiceState>(
        builder: (context, state) {
          if (state is InvoiceLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is InvoiceError) {
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
                      context.read<InvoiceBloc>().add(
                        GetInvoiceByIdEvent(widget.invoiceId),
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
          if (state is SingleInvoiceLoaded) {
            final invoice = state.invoice;

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
                      Text('Invoice: ${invoice.invoiceNumber ?? 'N/A'}'),
                    ],
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      tooltip: 'Refresh',
                      onPressed: () {
                        context.read<InvoiceBloc>().add(
                          GetInvoiceByIdEvent(widget.invoiceId),
                        );
                        context.read<ProductsBloc>().add(
                          GetProductsByInvoiceIdEvent(widget.invoiceId),
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
                      BlocBuilder<ProductsBloc, ProductsState>(
                        builder: (context, state) {
                          if (state is ProductsLoading) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(32.0),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }

                          if (state is ProductsError) {
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
                                        context.read<ProductsBloc>().add(
                                          GetProductsByInvoiceIdEvent(
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

                          if (state is InvoiceProductsLoaded &&
                              state.invoiceId == widget.invoiceId) {
                            final products = state.products;

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
                                        (product.description
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
                                  paginatedProducts as List<ProductEntity>,
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

          // Handle InvoiceLoaded state as a fallback (if we get a list of invoices instead of a single one)
          if (state is InvoiceLoaded) {
            // Find the specific invoice in the loaded invoices
            state.invoices.firstWhere(
              (inv) => inv.id == widget.invoiceId,
              orElse: () => throw Exception('Invoice not found'),
            );

            // Rest of the code is the same as for SingleInvoiceLoaded...
            // (For brevity, I'm not duplicating the entire UI code here)

            // Instead, trigger the GetInvoiceByIdEvent to get the proper state
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.read<InvoiceBloc>().add(
                GetInvoiceByIdEvent(widget.invoiceId),
              );
            });

            return const Center(child: CircularProgressIndicator());
          }

          return const Center(child: Text('Select an invoice to view details'));
        },
      ),
    );
  }
}
