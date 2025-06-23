import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/collection/domain/entity/collection_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/collection/presentation/bloc/collections_bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/collection/presentation/bloc/collections_state.dart';
import 'package:xpro_delivery_admin_app/core/common/widgets/app_structure/desktop_layout.dart';
import 'package:xpro_delivery_admin_app/core/common/widgets/reusable_widgets/app_navigation_items.dart';
import 'package:xpro_delivery_admin_app/src/collection_data/completed_customer_list/presentation/widgets/completed_customer_overview_widgets/cc_overview_quick_access_tools.dart';
import 'package:xpro_delivery_admin_app/src/collection_data/completed_customer_list/presentation/widgets/completed_customer_overview_widgets/cc_recent_customers.dart';
import 'package:xpro_delivery_admin_app/src/collection_data/completed_customer_list/presentation/widgets/completed_customer_overview_widgets/completed_customer_ov_dashboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../../core/common/app/features/Trip_Ticket/collection/presentation/bloc/collections_event.dart';

class CompletedCustomerOverview extends StatefulWidget {
  const CompletedCustomerOverview({super.key});

  @override
  State<CompletedCustomerOverview> createState() =>
      _CompletedCustomerOverviewState();
}

class _CompletedCustomerOverviewState extends State<CompletedCustomerOverview> {
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;
  bool _isDateFiltered = false;

  @override
  void initState() {
    super.initState();
    // Load all collections when the screen initializes
    _loadAllCollections();
  }

  void _loadAllCollections() {
    context.read<CollectionsBloc>().add(
      const GetAllCollectionsEvent(),
    );
    setState(() {
      _isDateFiltered = false;
      _selectedStartDate = null;
      _selectedEndDate = null;
    });
  }

  void _showDateRangePickerDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        DateTime? tempStartDate = _selectedStartDate;
        DateTime? tempEndDate = _selectedEndDate;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.date_range, color: Colors.blue),
                  SizedBox(width: 8),
                  Text('Filter by Date Range'),
                ],
              ),
              content: SizedBox(
                width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Select date range to filter collections:',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 20),

                    // Start Date Picker
                    Row(
                      children: [
                        const SizedBox(
                          width: 80,
                          child: Text(
                            'From:',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: tempStartDate ?? DateTime.now(),
                                firstDate: DateTime(2020),
                                lastDate: DateTime.now(),
                              );
                              if (date != null) {
                                setDialogState(() {
                                  tempStartDate = date;
                                  // Reset end date if it's before start date
                                  if (tempEndDate != null && tempEndDate!.isBefore(date)) {
                                    tempEndDate = null;
                                  }
                                });
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    tempStartDate != null
                                        ? DateFormat('MMM dd, yyyy').format(tempStartDate!)
                                        : 'Select start date',
                                    style: TextStyle(
                                      color: tempStartDate != null
                                          ? Colors.black
                                          : Colors.grey,
                                    ),
                                  ),
                                  const Icon(Icons.calendar_today, size: 16),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // End Date Picker
                    Row(
                      children: [
                        const SizedBox(
                          width: 80,
                          child: Text(
                            'To:',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: tempStartDate == null
                                ? null
                                : () async {
                                    final date = await showDatePicker(
                                      context: context,
                                      initialDate: tempEndDate ?? tempStartDate!,
                                      firstDate: tempStartDate!,
                                      lastDate: DateTime.now(),
                                    );
                                    if (date != null) {
                                      setDialogState(() {
                                        tempEndDate = date;
                                      });
                                    }
                                  },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: tempStartDate == null
                                      ? Colors.grey.shade200
                                      : Colors.grey.shade300,
                                ),
                                borderRadius: BorderRadius.circular(4),
                                color: tempStartDate == null
                                    ? Colors.grey.shade50
                                    : Colors.white,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    tempEndDate != null
                                        ? DateFormat('MMM dd, yyyy').format(tempEndDate!)
                                        : 'Select end date',
                                    style: TextStyle(
                                      color: tempStartDate == null
                                          ? Colors.grey.shade400
                                          : tempEndDate != null
                                              ? Colors.black
                                              : Colors.grey,
                                    ),
                                  ),
                                  Icon(
                                    Icons.calendar_today,
                                    size: 16,
                                    color: tempStartDate == null
                                        ? Colors.grey.shade400
                                        : Colors.grey,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    if (tempStartDate != null && tempEndDate != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline, 
                                color: Colors.blue.shade700, size: 16),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Date range: ${DateFormat('MMM dd').format(tempStartDate!)} - ${DateFormat('MMM dd, yyyy').format(tempEndDate!)}',
                                  style: TextStyle(
                                    color: Colors.blue.shade700,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                if (_isDateFiltered)
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _loadAllCollections();
                    },
                    child: const Text('View All'),
                  ),
                ElevatedButton(
                  onPressed: tempStartDate == null || tempEndDate == null
                      ? null
                      : () {
                          Navigator.of(context).pop();
                          _filterByDateRange(tempStartDate!, tempEndDate!);
                        },
                  child: const Text('Apply Filter'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _filterByDateRange(DateTime startDate, DateTime endDate) {
    // Set end date to end of day to include full day
    final endOfDay = DateTime(
      endDate.year,
      endDate.month,
      endDate.day,
      23,
      59,
      59,
      999,
    );

    setState(() {
      _selectedStartDate = startDate;
      _selectedEndDate = endOfDay;
      _isDateFiltered = true;
    });

    // Dispatch filter event
    context.read<CollectionsBloc>().add(
      FilterCollectionsByDateEvent(
        startDate: startDate,
        endDate: endOfDay,
      ),
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
      child: BlocBuilder<CollectionsBloc, CollectionsState>(
        builder: (context, state) {
          // Handle different states
          if (state is CollectionsInitial) {
            // Initial state, trigger loading
            context.read<CollectionsBloc>().add(
              const GetAllCollectionsEvent(),
            );
            return const Center(child: CircularProgressIndicator());
          }

          final bool isLoading = state is CollectionsLoading;
          List<CollectionEntity> customers = [];
          String pageTitle = 'Completed Customers Overview';
          String pageSubtitle = 'View and manage all completed customer transactions';

          // Handle different state types
          if (state is AllCollectionsLoaded) {
            customers = state.collections;
          } else if (state is CollectionsFilteredByDate) {
            customers = state.collections;
            pageTitle = 'Filtered Collections';
            pageSubtitle = 'Collections from ${DateFormat('MMM dd').format(state.startDate)} to ${DateFormat('MMM dd, yyyy').format(state.endDate)}';
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Page Title with Filter Status
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pageTitle,
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            pageSubtitle,
                            style: Theme.of(
                              context,
                            ).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                    
                    // Filter Status and Actions
                    if (_isDateFiltered)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.filter_alt, size: 16, color: Colors.blue.shade700),
                            const SizedBox(width: 4),
                            Text(
                              'Date Filtered',
                              style: TextStyle(
                                color: Colors.blue.shade700,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 8),
                            InkWell(
                              onTap: _loadAllCollections,
                              child: Icon(
                                Icons.close,
                                size: 16,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 24),

                // Dashboard Summary
                CompletedCustomerDashboard(
                  collections: customers,
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
                  onFilterData: _showDateRangePickerDialog, // Updated to use date picker
                  onSearchCustomers: () {
                    // Handle search customers
                    _showSearchDialog(context);
                  },
                ),
                                const SizedBox(height: 24),

                // Recent Customers List
                RecentCompletedCustomers(
                  collections: customers,
                  isLoading: isLoading,
                ),

                // Loading overlay
                if (isLoading)
                  Container(
                    margin: const EdgeInsets.only(top: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _isDateFiltered 
                              ? 'Filtering collections by date...' 
                              : 'Loading collections...',
                          style: TextStyle(
                            color: Colors.blue.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                // Error handling
                if (state is CollectionsError)
                  Container(
                    margin: const EdgeInsets.only(top: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.error_outline, color: Colors.red.shade700),
                            const SizedBox(width: 8),
                            Text(
                              'Error Loading Collections',
                              style: TextStyle(
                                color: Colors.red.shade700,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          state.message,
                          style: TextStyle(color: Colors.red.shade600),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            ElevatedButton.icon(
                              onPressed: _loadAllCollections,
                              icon: const Icon(Icons.refresh, size: 16),
                              label: const Text('Retry'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red.shade600,
                                foregroundColor: Colors.white,
                              ),
                            ),
                            if (_isDateFiltered) ...[
                              const SizedBox(width: 8),
                              TextButton(
                                onPressed: _loadAllCollections,
                                child: const Text('View All Collections'),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),

                // Empty state
                if (!isLoading && customers.isEmpty && state is! CollectionsError)
                  Container(
                    margin: const EdgeInsets.only(top: 32),
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            _isDateFiltered ? Icons.date_range : Icons.inbox_outlined,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _isDateFiltered 
                                ? 'No collections found for selected date range'
                                : 'No collections available',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _isDateFiltered
                                ? 'Try selecting a different date range or view all collections'
                                : 'Collections will appear here once they are created',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey.shade500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          if (_isDateFiltered)
                            ElevatedButton.icon(
                              onPressed: _loadAllCollections,
                              icon: const Icon(Icons.view_list),
                              label: const Text('View All Collections'),
                            ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showSearchDialog(BuildContext context) {
    final searchController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.search, color: Colors.blue),
              SizedBox(width: 8),
              Text('Search Collections'),
            ],
          ),
          content: SizedBox(
            width: 300,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search by customer name, invoice number...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  autofocus: true,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Search functionality will be implemented in future updates.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // TODO: Implement search functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Search functionality coming soon!'),
                  ),
                );
              },
              child: const Text('Search'),
            ),
          ],
        );
      },
    );
  }
}

