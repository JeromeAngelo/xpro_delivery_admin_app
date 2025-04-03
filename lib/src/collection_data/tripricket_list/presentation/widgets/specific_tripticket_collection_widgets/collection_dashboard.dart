import 'package:desktop_app/core/common/app/features/Trip_Ticket/completed_customer/domain/entity/completed_customer_entity.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/trip/domain/entity/trip_entity.dart';
import 'package:desktop_app/core/common/widgets/app_structure/data_dashboard.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CollectionTripDashboardWidget extends StatelessWidget {
  final TripEntity trip;
  final List<CompletedCustomerEntity> completedCustomers;
  final bool isLoading;

  const CollectionTripDashboardWidget({
    super.key,
    required this.trip,
    required this.completedCustomers,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate total amount collected
    double totalAmountCollected = 0;
    for (var customer in completedCustomers) {
      if (customer.totalAmount != null) {
        totalAmountCollected += customer.totalAmount!;
      }
    }

    // Format currency
    final currencyFormatter = NumberFormat.currency(
      symbol: '₱',
      decimalDigits: 2,
    );

    return DashboardSummary(
      title: 'Collection Summary',
      isLoading: isLoading,
      crossAxisCount: 3,
      items: [
        DashboardInfoItem(
          icon: Icons.receipt_long,
          value: trip.tripNumberId ?? 'N/A',
          label: 'Trip Number',
          iconColor: Colors.blue,
        ),
        DashboardInfoItem(
          icon: Icons.people,
          value: completedCustomers.length.toString(),
          label: 'Completed Customers',
          iconColor: Colors.green,
        ),
        DashboardInfoItem(
          icon: Icons.payments,
          value: currencyFormatter.format(totalAmountCollected),
          label: 'Total Amount Collected',
          iconColor: Colors.purple,
        ),
        DashboardInfoItem(
          icon: Icons.calendar_today,
          value: trip.timeAccepted != null
              ? DateFormat('MMM dd, yyyy').format(trip.timeAccepted!)
              : 'N/A',
          label: 'Start Date',
          iconColor: Colors.orange,
        ),
        DashboardInfoItem(
          icon: Icons.done_all,
          value: trip.timeEndTrip != null
              ? DateFormat('MMM dd, yyyy').format(trip.timeEndTrip!)
              : 'N/A',
          label: 'End Date',
          iconColor: Colors.teal,
        ),
        DashboardInfoItem(
          icon: Icons.person,
          value: trip.user?.name ?? 'N/A',
          label: 'Assigned To',
          iconColor: Colors.indigo,
        ),
      ],
    );
  }
}
