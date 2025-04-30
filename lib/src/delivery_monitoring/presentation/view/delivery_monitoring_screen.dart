import 'package:desktop_app/core/common/app/features/Trip_Ticket/customer/domain/entity/customer_entity.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/customer/presentation/bloc/customer_bloc.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/customer/presentation/bloc/customer_event.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/customer/presentation/bloc/customer_state.dart';

import 'package:desktop_app/core/common/widgets/reusable_widgets/default_drawer.dart';
import 'package:desktop_app/src/delivery_monitoring/presentation/widgets/customer_information_tile.dart';
import 'package:desktop_app/src/delivery_monitoring/presentation/widgets/delivery_status_icon.dart';
import 'package:desktop_app/src/delivery_monitoring/presentation/widgets/status_container.dart';
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

  // void _fetchCustomerLocation(String customerId) {
  //   context.read<CustomerBloc>().add(GetCustomerLocationEvent(customerId));
  // }

  void _fetchCustomerLocation(String customerId) {
    context.read<CustomerBloc>().add(GetCustomerLocationEvent(customerId));
  }

  @override
  void initState() {
    super.initState();
    // Load all customers when the screen initializes
    context.read<CustomerBloc>().add(const GetAllCustomersEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        iconTheme: IconThemeData(
          color:
              Theme.of(
                context,
              ).colorScheme.surface, // This sets the drawer icon color
        ),
        title: Text(
          'Delivery Monitoring',
          style: TextStyle(color: Theme.of(context).colorScheme.surface),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: Theme.of(context).colorScheme.surface,
            ),
            tooltip: 'Refresh',
            onPressed: () {
              context.read<CustomerBloc>().add(const GetAllCustomersEvent());
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: const DefaultDrawer(),
      body: BlocBuilder<CustomerBloc, CustomerState>(
        builder: (context, state) {
          if (state is CustomerLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CustomerError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading customers: ${state.message}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<CustomerBloc>().add(
                        const GetAllCustomersEvent(),
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

          if (state is AllCustomersLoaded) {
            customers = state.customers;
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
      _fetchCustomerLocation(customer.id!);
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
                          onPressed: () => Navigator.pop(context),
                          color: Theme.of(context).colorScheme.surface,
                        ),
                      ],
                    ),
                  ),

                  // Customer information content
                  Flexible(
                    child: SingleChildScrollView(
                      child: CustomerInformationTile(customer: customer),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
