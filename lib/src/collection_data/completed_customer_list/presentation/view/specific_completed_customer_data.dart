import 'package:desktop_app/core/common/app/features/Trip_Ticket/completed_customer/presentation/bloc/completed_customer_bloc.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/completed_customer/presentation/bloc/completed_customer_event.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/completed_customer/presentation/bloc/completed_customer_state.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/invoice/domain/entity/invoice_entity.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/invoice/presentation/bloc/invoice_bloc.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/invoice/presentation/bloc/invoice_event.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/invoice/presentation/bloc/invoice_state.dart';
import 'package:desktop_app/core/common/widgets/app_structure/desktop_layout.dart';
import 'package:desktop_app/core/common/widgets/reusable_widgets/app_navigation_items.dart';
import 'package:desktop_app/src/collection_data/completed_customer_list/presentation/widgets/specific_customer_data_widgets/completed_customer_dashboard_widget.dart';
import 'package:desktop_app/src/collection_data/completed_customer_list/presentation/widgets/specific_customer_data_widgets/completed_customer_header.dart';
import 'package:desktop_app/src/collection_data/completed_customer_list/presentation/widgets/specific_customer_data_widgets/completed_customer_invoice_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class SpecificCompletedCustomerData extends StatefulWidget {
  final String customerId;

  const SpecificCompletedCustomerData({super.key, required this.customerId});

  @override
  State<SpecificCompletedCustomerData> createState() => _SpecificCompletedCustomerDataState();
}

class _SpecificCompletedCustomerDataState extends State<SpecificCompletedCustomerData> {
  int _currentPage = 1;
  int _totalPages = 1;
  final int _itemsPerPage = 10;

@override
void initState() {
  super.initState();
  
  // Extract the actual ID if needed
  String customerId = widget.customerId;
  if (customerId.contains('CompletedCustomerModel')) {
    // Extract just the ID
    final idMatch = RegExp(r'CompletedCustomerModel\(([^,]+)').firstMatch(customerId);
    if (idMatch != null && idMatch.groupCount >= 1) {
      customerId = idMatch.group(1)!;
    } else {
      // Fallback
      customerId = customerId.split(',').first.replaceAll('CompletedCustomerModel(', '').trim();
    }
  }
  
  // Load completed customer details
  context.read<CompletedCustomerBloc>().add(
    GetCompletedCustomerByIdEvent(customerId),
  );
  
  // Load invoices for this completed customer
  context.read<InvoiceBloc>().add(
    GetInvoicesByCompletedCustomerEvent(customerId),
  );
}


  @override
  Widget build(BuildContext context) {
    // Define navigation items
    final navigationItems = AppNavigationItems.collectionNavigationItems();

    return DesktopLayout(
      navigationItems: navigationItems,
      currentRoute: '/completed-customers',
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
      child: BlocBuilder<CompletedCustomerBloc, CompletedCustomerState>(
        builder: (context, state) {
          if (state is CompletedCustomerLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CompletedCustomerError) {
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
                      context.read<CompletedCustomerBloc>().add(
                        GetCompletedCustomerByIdEvent(widget.customerId),
                      );
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is CompletedCustomerByIdLoaded) {
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
                          context.go('/completed-customers');
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
                        context.read<CompletedCustomerBloc>().add(
                          GetCompletedCustomerByIdEvent(widget.customerId),
                        );
                        context.read<InvoiceBloc>().add(
                          GetInvoicesByCompletedCustomerEvent(widget.customerId),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.print),
                      tooltip: 'Print Receipt',
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Printing receipt...')),
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
                      CompletedCustomerHeaderWidget(
                        customer: customer,
                        onPrintReceipt: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Printing receipt...')),
                          );
                        },
                      ),

                      const SizedBox(height: 16),

                      // Customer Dashboard
                      CompletedCustomerDashboardWidget(customer: customer),

                      const SizedBox(height: 16),

                      // Trip Information Card
                      if (customer.trip != null)
                        Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Trip Information',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ListTile(
                                  leading: const Icon(Icons.receipt_long, color: Colors.blue),
                                  title: Text('Trip Number: ${customer.trip?.tripNumberId ?? 'N/A'}'),
                                  subtitle: Text(
                                    'View complete trip details including all collections',
                                  ),
                                  trailing: ElevatedButton(
                                    onPressed: () {
                                      if (customer.trip?.id != null) {
                                        context.go('/collections/${customer.trip!.id}');
                                      }
                                    },
                                    child: const Text('View Trip'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      // Invoices Table
                      Card(
                        margin: const EdgeInsets.symmetric(vertical: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Invoices',
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.print),
                                    tooltip: 'Print All Invoices',
                                    onPressed: () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Printing all invoices...')),
                                      );
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              BlocBuilder<InvoiceBloc, InvoiceState>(
  builder: (context, invoiceState) {
    debugPrint('🔄 Current invoice state: ${invoiceState.runtimeType}');
    
    if (invoiceState is InvoiceLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (invoiceState is InvoiceError) {
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
                'Error loading invoices: ${invoiceState.message}',
                style: TextStyle(color: Colors.red[700]),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  // Extract ID again to ensure we're using the correct format
                  String customerId = widget.customerId;
                  if (customerId.contains('CompletedCustomerModel')) {
                    final idMatch = RegExp(r'CompletedCustomerModel\(([^,]+)').firstMatch(customerId);
                    if (idMatch != null && idMatch.groupCount >= 1) {
                      customerId = idMatch.group(1)!;
                    } else {
                      customerId = customerId.split(',').first.replaceAll('CompletedCustomerModel(', '').trim();
                    }
                  }
                  
                  context.read<InvoiceBloc>().add(
                    GetInvoicesByCompletedCustomerEvent(customerId),
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

    if (invoiceState is CompletedCustomerInvoicesLoaded) {
      // Check if this state is for our customer
      String currentCustomerId = widget.customerId;
      if (currentCustomerId.contains('CompletedCustomerModel')) {
        final idMatch = RegExp(r'CompletedCustomerModel\(([^,]+)').firstMatch(currentCustomerId);
        if (idMatch != null && idMatch.groupCount >= 1) {
          currentCustomerId = idMatch.group(1)!;
        } else {
          currentCustomerId = currentCustomerId.split(',').first.replaceAll('CompletedCustomerModel(', '').trim();
        }
      }
      
      // If the state is for a different customer, request data for this customer
      if (invoiceState.completedCustomerId != currentCustomerId) {
        debugPrint('🔄 State is for a different customer, requesting data for current customer');
        // Request data for this customer
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.read<InvoiceBloc>().add(
            GetInvoicesByCompletedCustomerEvent(currentCustomerId),
          );
        });
        
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(32.0),
            child: CircularProgressIndicator(),
          ),
        );
      }
      
      final invoices = invoiceState.invoices;
      
      // Calculate total pages
      _totalPages = (invoices.length / _itemsPerPage).ceil();
      if (_totalPages == 0) _totalPages = 1;
      
      // Paginate invoices
      final startIndex = (_currentPage - 1) * _itemsPerPage;
      final endIndex = startIndex + _itemsPerPage > invoices.length 
          ? invoices.length 
          : startIndex + _itemsPerPage;
      
      final paginatedInvoices = startIndex < invoices.length 
          ? invoices.sublist(startIndex, endIndex) 
          : [];

      return CompletedCustomerInvoiceTable(
        invoices: paginatedInvoices as List<InvoiceEntity>,
        isLoading: false,
        currentPage: _currentPage,
        totalPages: _totalPages,
        onPageChanged: (page) {
          setState(() {
            _currentPage = page;
          });
        },
        completedCustomerId: currentCustomerId,
        onRetry: () {
          context.read<InvoiceBloc>().add(
            GetInvoicesByCompletedCustomerEvent(currentCustomerId),
          );
        },
      );
    }

    // Default case - no invoices loaded yet
    // Add a button to explicitly load invoices
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No invoices data available',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                // Extract ID again to ensure we're using the correct format
                String customerId = widget.customerId;
                if (customerId.contains('CompletedCustomerModel')) {
                  final idMatch = RegExp(r'CompletedCustomerModel\(([^,]+)').firstMatch(customerId);
                  if (idMatch != null && idMatch.groupCount >= 1) {
                    customerId = idMatch.group(1)!;
                  } else {
                    customerId = customerId.split(',').first.replaceAll('CompletedCustomerModel(', '').trim();
                  }
                }
                
                debugPrint('🔍 Manually loading invoices for customer ID: $customerId');
                context.read<InvoiceBloc>().add(
                  GetInvoicesByCompletedCustomerEvent(customerId),
                );
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Load Invoices'),
            ),
          ],
        ),
      ),
    );
  },
)

                            ],
                          ),
                        ),
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
