import 'dart:async';

import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/customer/domain/entity/customer_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/customer/presentation/bloc/customer_bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/customer/presentation/bloc/customer_event.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/customer/presentation/bloc/customer_state.dart';

import 'package:xpro_delivery_admin_app/core/common/widgets/reusable_widgets/default_drawer.dart';
import 'package:xpro_delivery_admin_app/src/delivery_monitoring/presentation/widgets/customer_information_tile.dart';
import 'package:xpro_delivery_admin_app/src/delivery_monitoring/presentation/widgets/delivery_status_icon.dart';
import 'package:xpro_delivery_admin_app/src/delivery_monitoring/presentation/widgets/status_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DeliveryMonitoringScreen extends StatefulWidget {
  const DeliveryMonitoringScreen({super.key});

  @override
  State<DeliveryMonitoringScreen> createState() =>
      _DeliveryMonitoringScreenState();
}

class _DeliveryMonitoringScreenState extends State<DeliveryMonitoringScreen> {
  final List<DeliveryStatusData> statuses = getAllDeliveryStatuses();

  Timer? _autoRefreshTimer;

  // Auto-refresh duration - 5 minutes
  static const Duration autoRefreshDuration = Duration(minutes: 2);

  @override
  void initState() {
    super.initState();
    // Start watching all customers when the screen initializes
    // This will provide real-time updates
    context.read<CustomerBloc>().add(const WatchAllCustomersEvent());

    // Set up auto-refresh timer
    _setupAutoRefreshTimer();
  }

  @override
  void dispose() {
    // Stop watching when the screen is disposed
    context.read<CustomerBloc>().add(const StopWatchingEvent());

    // Cancel the timer when disposing the widget
    _autoRefreshTimer?.cancel();

    super.dispose();
  }

  // Set up the auto-refresh timer
  void _setupAutoRefreshTimer() {
    // Cancel any existing timer
    _autoRefreshTimer?.cancel();

    // Create a new timer that fires every 5 minutes
    _autoRefreshTimer = Timer.periodic(
      autoRefreshDuration,
      (_) => _refreshData(),
    );
  }

  // Refresh the data
  void _refreshData() {
    if (mounted) {
      // Show a snackbar to indicate refresh is happening
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Auto-refreshing delivery data...'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Restart the real-time subscription
      context.read<CustomerBloc>().add(const StopWatchingEvent());
      context.read<CustomerBloc>().add(const WatchAllCustomersEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.surface),
        title: Text(
          'Delivery Monitoring',
          style: TextStyle(color: Theme.of(context).colorScheme.surface),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Center(
              child: StreamBuilder<int>(
                stream: Stream.periodic(
                  const Duration(seconds: 1),
                  (count) =>
                      autoRefreshDuration.inSeconds -
                      (count % autoRefreshDuration.inSeconds),
                ),
                builder: (context, snapshot) {
                  final remainingSeconds =
                      snapshot.data ?? autoRefreshDuration.inSeconds;
                  final minutes = remainingSeconds ~/ 60;
                  final seconds = remainingSeconds % 60;
                  return Text(
                    'Auto-refresh in: ${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.surface,
                    ),
                  );
                },
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.sort_outlined,
              color: Theme.of(context).colorScheme.surface,
            ),
            tooltip: 'Filter',
            onPressed: () {
              // Manually refresh all customers if needed
              // context.read<CustomerBloc>().add(const GetAllCustomersEvent());
            },
          ),
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: Theme.of(context).colorScheme.surface,
            ),
            tooltip: 'Refresh',
            onPressed: () {
              // Manually refresh all customers if needed
              context.read<CustomerBloc>().add(const GetAllCustomersEvent());
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: const DefaultDrawer(),
      body: BlocBuilder<CustomerBloc, CustomerState>(
        builder: (context, state) {
          if (state is CustomerLoading || state is AllCustomersWatching) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CustomerError || state is CustomerStreamError) {
            final errorMessage =
                state is CustomerError
                    ? state.message
                    : (state as CustomerStreamError).message;

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading customers: $errorMessage',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      // Try watching again
                      context.read<CustomerBloc>().add(
                        const WatchAllCustomersEvent(),
                      );
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          List<CustomerEntity> customers = [];

          // Handle different loaded states
          if (state is AllCustomersLoaded) {
            customers = state.customers;
          } else if (state is CustomerLoaded) {
            customers = state.customer;
          }

          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(16.0),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, // 3 columns
                    childAspectRatio: 0.85, // Adjust for height
                    crossAxisSpacing: 16.0,
                    mainAxisSpacing: 16.0,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final status = statuses[index];
                    final statusCustomers = _filterCustomersByStatus(
                      customers,
                      status.name,
                    );

                    return SizedBox(
                      height: 500, // Fixed height for each status container
                      child: StatusContainer(
                        statusName: status.name,
                        statusIcon: status.icon,
                        statusColor: status.color,
                        customers: statusCustomers,
                        onCustomerTap: (customer) {
                          _showCustomerDetails(context, customer);
                        },
                        subtitle: status.subtitle,
                      ),
                    );
                  }, childCount: statuses.length),
                ),
              ),
            ],
          );
        },
      ),
      // Add a floating action button to manually refresh
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Restart the real-time subscription
          context.read<CustomerBloc>().add(const StopWatchingEvent());
          context.read<CustomerBloc>().add(const WatchAllCustomersEvent());
        },
        tooltip: 'Restart real-time updates',
        child: const Icon(Icons.sync),
      ),
    );
  }

  // Filter customers by their delivery status
  List<CustomerEntity> _filterCustomersByStatus(
    List<CustomerEntity> customers,
    String status,
  ) {
    // This is a simplified implementation - in a real app, you would need to
    // check the actual delivery status from the customer entity
    final statusLower = status.toLowerCase();

    return customers.where((customer) {
      // Get the most recent delivery status
      final deliveryStatus =
          customer.deliveryStatus.isNotEmpty
              ? customer.deliveryStatus.last.title?.toLowerCase() ?? ''
              : '';

      // Match status names (simplified)
      if (statusLower == 'pending' && deliveryStatus.isEmpty) {
        return true;
      }

      if (deliveryStatus.contains(statusLower)) {
        return true;
      }

      // Special cases
      if (statusLower == 'delivered' &&
          (deliveryStatus.contains('mark as received'))) {
        return true;
      }

      if (statusLower == 'mark as undelivered' &&
          deliveryStatus.contains('mark as undelivered')) {
        return true;
      }

      if (statusLower == 'completed' &&
          deliveryStatus.contains('end delivery')) {
        return true;
      }

      return false;
    }).toList();
  }

  // Show customer details in a dialog
  void _showCustomerDetails(BuildContext context, CustomerEntity customer) {
    if (customer.id != null) {
      // Start watching this specific customer's location for real-time updates
      context.read<CustomerBloc>().add(
        WatchCustomerLocationEvent(customer.id!),
      );
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.8,
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header with close button
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    color: Theme.of(context).colorScheme.primary,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Customer Details',
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.surface,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            // Stop watching this customer when dialog is closed
                            context.read<CustomerBloc>().add(
                              const StopWatchingEvent(),
                            );
                            // Resume watching all customers
                            context.read<CustomerBloc>().add(
                              const WatchAllCustomersEvent(),
                            );
                            Navigator.pop(context);
                          },
                          color: Theme.of(context).colorScheme.surface,
                        ),
                      ],
                    ),
                  ),

                  // Customer information content with real-time updates
                  Flexible(
                    child: BlocBuilder<CustomerBloc, CustomerState>(
                      builder: (context, state) {
                        // Show loading indicator when fetching location
                        if (state is CustomerLocationLoading ||
                            state is CustomerLocationWatching) {
                          return const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(),
                                SizedBox(height: 16),
                                Text('Loading customer details...'),
                              ],
                            ),
                          );
                        }

                        // Show updated customer data if available
                        if (state is CustomerLocationLoaded &&
                            state.customer.id == customer.id) {
                          return SingleChildScrollView(
                            child: CustomerInformationTile(
                              customer: state.customer,
                            ),
                          );
                        }

                        // Fallback to original customer data
                        return SingleChildScrollView(
                          child: CustomerInformationTile(customer: customer),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ).then((_) {
      // When dialog is closed, ensure we stop watching the specific customer
      context.read<CustomerBloc>().add(const StopWatchingEvent());
      // Resume watching all customers
      context.read<CustomerBloc>().add(const WatchAllCustomersEvent());
    });
  }
}
