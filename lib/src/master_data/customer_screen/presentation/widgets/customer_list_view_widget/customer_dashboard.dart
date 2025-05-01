import 'package:flutter/material.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/customer/domain/entity/customer_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/widgets/app_structure/data_dashboard.dart';
import 'package:xpro_delivery_admin_app/core/common/widgets/app_structure/status_icons.dart';

class CustomerDashboard extends StatelessWidget {
  final List<CustomerEntity> customers;
  final bool isLoading;

  const CustomerDashboard({
    super.key,
    required this.customers,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    // Count total customers
    final totalCustomers = customers.length;
    
    // Count active customers (with statuses: pending, in transit, arrived, unloading, mark as received)
    final activeCustomers = customers.where((customer) {
      // Check if customer has delivery status updates
      if (customer.deliveryStatus.isEmpty) return false;
      
      // Get the latest status
      final latestStatus = customer.deliveryStatus.last.title?.toLowerCase() ?? '';
      
      // Check if the status is one of the active statuses
      return latestStatus == 'pending' || 
             latestStatus == 'in transit' || 
             latestStatus == 'arrived' || 
             latestStatus == 'unloading' || 
             latestStatus == 'mark as received';
    }).length;
    
    // Count completed customers (with status: end delivery)
    final completedCustomers = customers.where((customer) {
      // Check if customer has delivery status updates
      if (customer.deliveryStatus.isEmpty) return false;
      
      // Get the latest status
      final latestStatus = customer.deliveryStatus.last.title?.toLowerCase() ?? '';
      
      // Check if the status is "end delivery"
      return latestStatus == 'end delivery';
    }).length;
    
    // Count undelivered customers (with status: mark as undelivered)
    final undeliveredCustomers = customers.where((customer) {
      // Check if customer has delivery status updates
      if (customer.deliveryStatus.isEmpty) return false;
      
      // Get the latest status
      final latestStatus = customer.deliveryStatus.last.title?.toLowerCase() ?? '';
      
      // Check if the status is "mark as undelivered"
      return latestStatus == 'mark as undelivered';
    }).length;
    
  

    return DashboardSummary(
      title: 'Customer Status Summary',
      isLoading: isLoading,
      crossAxisCount: 4, // Show 4 items in a row
      childAspectRatio: 3.0, // Make cards wider than tall
      items: [
        // Total Customers
        DashboardInfoItem(
          icon: Icons.people,
          value: totalCustomers.toString(),
          label: 'Total Customers',
          iconColor: Colors.purple,
        ),
        
        // Active Customers
        DashboardInfoItem(
          icon: StatusIcons.getStatusIcon('in transit'),
          value: activeCustomers.toString(),
          label: 'Active Customers',
          iconColor: Colors.blue,
        ),
        
        // Completed Customers
        DashboardInfoItem(
          icon: StatusIcons.getStatusIcon('end delivery'),
          value: completedCustomers.toString(),
          label: 'Completed Deliveries',
          iconColor: Colors.green,
        ),
        
        // Undelivered Customers
        DashboardInfoItem(
          icon: StatusIcons.getStatusIcon('mark as undelivered'),
          value: undeliveredCustomers.toString(),
          label: 'Undelivered',
          iconColor: Colors.red,
        ),
      ],
    );
  }
}
