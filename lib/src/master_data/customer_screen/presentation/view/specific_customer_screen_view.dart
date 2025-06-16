import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/customer_data/presentation/bloc/customer_data_bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/customer_data/presentation/bloc/customer_data_event.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/customer_data/presentation/bloc/customer_data_state.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/invoice_data/presentation/bloc/invoice_data_bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/invoice_data/presentation/bloc/invoice_data_event.dart';
import 'package:xpro_delivery_admin_app/core/common/widgets/app_structure/desktop_layout.dart';
import 'package:xpro_delivery_admin_app/core/common/widgets/reusable_widgets/app_navigation_items.dart';
import 'package:xpro_delivery_admin_app/src/master_data/customer_screen/presentation/widgets/specific_customer_widget/customer_dashboard_widget.dart';
import 'package:xpro_delivery_admin_app/src/master_data/customer_screen/presentation/widgets/specific_customer_widget/customer_header_widget.dart';
import 'package:xpro_delivery_admin_app/src/master_data/customer_screen/presentation/widgets/specific_customer_widget/customer_invoices_table.dart';
import 'package:xpro_delivery_admin_app/src/master_data/customer_screen/presentation/widgets/specific_customer_widget/customer_map.dart';
import 'package:xpro_delivery_admin_app/src/master_data/customer_screen/presentation/widgets/specific_customer_widget/customer_option_dialog.dart';

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
    context.read<CustomerDataBloc>().add(
      GetCustomerDataByIdEvent(widget.customerId),
    );
    // Load invoices for this customer
    context.read<InvoiceDataBloc>().add(
      GetInvoiceDataByCustomerIdEvent(widget.customerId),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Define navigation items
    final navigationItems = AppNavigationItems.generalTripItems();

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
      child: BlocBuilder<CustomerDataBloc, CustomerDataState>(
        builder: (context, state) {
          if (state is CustomerDataLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CustomerDataError) {
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
                      context.read<CustomerDataBloc>().add(
                        GetCustomerDataByIdEvent(widget.customerId),
                      );
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is CustomerDataLoaded) {
            final customer = state.customerData;

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
                      Text('Customer: ${customer.name ?? 'N/A'}'),
                    ],
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      tooltip: 'Refresh',
                      onPressed: () {
                        context.read<CustomerDataBloc>().add(
                          GetCustomerDataByIdEvent(widget.customerId),
                        );
                        context.read<InvoiceDataBloc>().add(
                          GetInvoiceDataByCustomerIdEvent(widget.customerId),
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
                      if (customer.latitude != null &&
                          customer.longitude != null)
                        CustomerMapScreen(
                          selectedCustomer: customer,
                          height: 300.0,
                        ),

                      const SizedBox(height: 16),

                      // Invoices Table
                      CustomerInvoicesTable(
                        customer: customer,
                        onAddInvoice: () {
                          // Navigate to add invoice screen
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Add invoice feature coming soon'),
                            ),
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
