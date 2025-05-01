import 'package:xpro_delivery_admin_app/core/common/widgets/app_structure/desktop_layout.dart';
import 'package:xpro_delivery_admin_app/core/common/widgets/reusable_widgets/app_navigation_items.dart';
import 'package:xpro_delivery_admin_app/src/collection_data/completed_customer_list/presentation/widgets/completed_customer_overview_widgets/cc_overview_quick_access_tools.dart';
import 'package:xpro_delivery_admin_app/src/collection_data/completed_customer_list/presentation/widgets/completed_customer_overview_widgets/cc_recent_customers.dart';
import 'package:xpro_delivery_admin_app/src/collection_data/completed_customer_list/presentation/widgets/completed_customer_overview_widgets/completed_customer_ov_dashboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/completed_customer/domain/entity/completed_customer_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/completed_customer/presentation/bloc/completed_customer_bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/completed_customer/presentation/bloc/completed_customer_event.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/completed_customer/presentation/bloc/completed_customer_state.dart';
import 'package:go_router/go_router.dart';

class CompletedCustomerOverview extends StatefulWidget {
  const CompletedCustomerOverview({super.key});

  @override
  State<CompletedCustomerOverview> createState() =>
      _CompletedCustomerOverviewState();
}

class _CompletedCustomerOverviewState extends State<CompletedCustomerOverview> {
  @override
  void initState() {
    super.initState();
    // Load completed customers when the screen initializes
    context.read<CompletedCustomerBloc>().add(
      const GetAllCompletedCustomersEvent(),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Define navigation items
    final navigationItems = AppNavigationItems.collectionNavigationItems();

    return DesktopLayout(
      navigationItems: navigationItems,
      currentRoute: '/collections-overview',
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
      child: BlocBuilder<CompletedCustomerBloc, CompletedCustomerState>(
        builder: (context, state) {
          // Handle different states
          if (state is CompletedCustomerInitial) {
            // Initial state, trigger loading
            context.read<CompletedCustomerBloc>().add(
              const GetAllCompletedCustomersEvent(),
            );
            return const Center(child: CircularProgressIndicator());
          }

          final bool isLoading = state is CompletedCustomerLoading;
          final List<CompletedCustomerEntity> customers =
              state is AllCompletedCustomersLoaded ? state.customers : [];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Page Title
                Text(
                  'Completed Customers Overview',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'View and manage all completed customer transactions',
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
                ),
                const SizedBox(height: 24),

                // Dashboard Summary
                CompletedCustomerDashboard(
                  customers: customers,
                  isLoading: isLoading,
                ),
                const SizedBox(height: 24),

                // Quick Access Tools
                QuickAccessTools(
                  onExportData: () {
                    // Handle export data
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Exporting data...')),
                    );
                  },
                  onGenerateReport: () {
                    // Handle generate report
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Generating report...')),
                    );
                  },
                  onFilterData: () {
                    // Handle filter data
                    _showFilterDialog(context);
                  },
                  onSearchCustomers: () {
                    // Handle search customers
                    _showSearchDialog(context);
                  },
                ),
                const SizedBox(height: 24),

                // Recent Completed Customers
                RecentCompletedCustomers(
                  customers: customers,
                  isLoading: isLoading,
                ),

                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Filter Completed Customers'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Date range picker
                ListTile(
                  leading: const Icon(Icons.date_range),
                  title: const Text('Date Range'),
                  subtitle: const Text('Filter by completion date'),
                  onTap: () {
                    Navigator.pop(context);
                    // Show date range picker
                  },
                ),

                // Payment mode filter
                ListTile(
                  leading: const Icon(Icons.payments),
                  title: const Text('Payment Mode'),
                  subtitle: const Text('Filter by payment method'),
                  onTap: () {
                    Navigator.pop(context);
                    // Show payment mode filter options
                  },
                ),

                // Amount range filter
                ListTile(
                  leading: const Icon(Icons.monetization_on),
                  title: const Text('Amount Range'),
                  subtitle: const Text('Filter by transaction amount'),
                  onTap: () {
                    Navigator.pop(context);
                    // Show amount range filter
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _showSearchDialog(BuildContext context) {
    final TextEditingController searchController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Search Completed Customers'),
          content: TextField(
            controller: searchController,
            decoration: const InputDecoration(
              hintText: 'Enter store name, address, or ID',
              prefixIcon: Icon(Icons.search),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final query = searchController.text.trim();
                if (query.isNotEmpty) {
                  Navigator.pop(context);
                  // Trigger search event
                  // context.read<CompletedCustomerBloc>().add(
                  //   SearchCompletedCustomersEvent(query),
                  // );
                }
              },
              child: const Text('Search'),
            ),
          ],
        );
      },
    );
  }
}
