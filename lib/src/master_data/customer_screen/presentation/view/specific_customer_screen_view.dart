import 'package:desktop_app/core/common/app/features/Trip_Ticket/customer/presentation/bloc/customer_bloc.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/customer/presentation/bloc/customer_event.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/customer/presentation/bloc/customer_state.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/invoice/presentation/bloc/invoice_bloc.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/invoice/presentation/bloc/invoice_event.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/invoice/presentation/bloc/invoice_state.dart';
import 'package:desktop_app/core/common/widgets/app_structure/desktop_layout.dart';
import 'package:desktop_app/core/common/widgets/reusable_widgets/app_navigation_items.dart';
import 'package:desktop_app/src/master_data/customer_screen/presentation/widgets/specific_customer_widget/customer_dashboard_widget.dart';
import 'package:desktop_app/src/master_data/customer_screen/presentation/widgets/specific_customer_widget/customer_header_widget.dart';
import 'package:desktop_app/src/master_data/customer_screen/presentation/widgets/specific_customer_widget/customer_invoices_table.dart';
import 'package:desktop_app/src/master_data/customer_screen/presentation/widgets/specific_customer_widget/customer_map.dart';
import 'package:desktop_app/src/master_data/customer_screen/presentation/widgets/specific_customer_widget/customer_option_dialog.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class SpecificCustomerScreenView extends StatefulWidget {
  final String customerId;

  const SpecificCustomerScreenView({super.key, required this.customerId});

  @override
  State<SpecificCustomerScreenView> createState() =>
      _SpecificCustomerScreenViewState();
}

class _SpecificCustomerScreenViewState
    extends State<SpecificCustomerScreenView> {
  @override
  void initState() {
    super.initState();
    // Load customer details
    context.read<CustomerBloc>().add(
      GetCustomerLocationEvent(widget.customerId),
    );
    // Load invoices for this customer
    context.read<InvoiceBloc>().add(
      GetInvoicesByCustomerEvent(widget.customerId),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Define navigation items
    final navigationItems = AppNavigationItems.tripticketNavigationItems();

    return DesktopLayout(
      navigationItems: navigationItems,
      currentRoute: '/customer-list',
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
      child: BlocBuilder<CustomerBloc, CustomerState>(
        builder: (context, state) {
          if (state is CustomerLoading || state is CustomerLocationLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CustomerError) {
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
                      context.read<CustomerBloc>().add(
                        GetCustomerLocationEvent(widget.customerId),
                      );
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is CustomerLocationLoaded) {
            final customer = state.customer;

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
                          context.go('/customers');
                        },
                      ),
                      Text('Customer: ${customer.storeName ?? 'N/A'}'),
                    ],
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      tooltip: 'Refresh',
                      onPressed: () {
                        context.read<CustomerBloc>().add(
                          GetCustomerLocationEvent(widget.customerId),
                        );
                        context.read<InvoiceBloc>().add(
                          GetInvoicesByCustomerEvent(widget.customerId),
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
                      // Customer Header
                      CustomerHeaderWidget(
                        customer: customer,
                        onEditPressed: () {
                          // Navigate to edit customer screen
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Edit customer feature coming soon',
                              ),
                            ),
                          );
                        },
                        onOptionsPressed: () {
                          showCustomerOptionsDialog(context, customer);
                        },
                      ),

                      const SizedBox(height: 16),

                      // Customer Dashboard
                      CustomerDashboardWidget(customer: customer),

                      const SizedBox(height: 16),

                      // Map Section
                      CustomerMapScreen(
                        selectedCustomer: state.customer,
                        height: 300.0,
                      ),

                      const SizedBox(height: 16),

                      // Invoices Table
                      // In the BlocBuilder for InvoiceBloc
                      BlocBuilder<InvoiceBloc, InvoiceState>(
                        builder: (context, state) {
                          if (state is InvoiceLoading) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(32.0),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }

                          if (state is InvoiceError) {
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
                                      'Error loading invoices: ${state.message}',
                                      style: TextStyle(color: Colors.red[700]),
                                    ),
                                    const SizedBox(height: 16),
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        context.read<InvoiceBloc>().add(
                                          GetInvoicesByCustomerEvent(
                                            widget.customerId,
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

                          // Check for CustomerInvoicesLoaded state specifically
                          if (state is CustomerInvoicesLoaded &&
                              state.customerId == widget.customerId) {
                            debugPrint(
                              '✅ Found ${state.invoices.length} invoices for customer ${widget.customerId}',
                            );
                            return CustomerInvoicesTable(
                              customer: customer,
                              invoices: state.invoices,
                              onAddInvoice: () {
                                // Navigate to add invoice screen
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Add invoice feature coming soon',
                                    ),
                                  ),
                                );
                              },
                            );
                          }

                          // Default case when invoices aren't loaded yet
                          debugPrint(
                            '⚠️ No invoices loaded yet for customer ${widget.customerId}',
                          );
                          return CustomerInvoicesTable(
                            customer: customer,
                            invoices: [], // Empty list as fallback
                            onAddInvoice: () {
                              // Navigate to add invoice screen
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Add invoice feature coming soon',
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

          return const Center(child: Text('Select a customer to view details'));
        },
      ),
    );
  }
}
