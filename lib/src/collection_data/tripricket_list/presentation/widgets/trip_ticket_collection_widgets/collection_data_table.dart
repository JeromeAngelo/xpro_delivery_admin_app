import 'package:desktop_app/core/common/app/features/Trip_Ticket/trip/domain/entity/trip_entity.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/trip/presentation/bloc/trip_bloc.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/trip/presentation/bloc/trip_event.dart';
import 'package:desktop_app/core/common/widgets/app_structure/data_table_layout.dart';
import 'package:desktop_app/core/enums/mode_of_payment.dart';
import 'package:desktop_app/src/collection_data/tripricket_list/presentation/widgets/trip_ticket_collection_widgets/collection_searchbar.dart';
import 'package:desktop_app/src/collection_data/tripricket_list/presentation/widgets/trip_ticket_collection_widgets/payment_mode_chip.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class CollectionDataTable extends StatelessWidget {
  final List<TripEntity> trips;
  final bool isLoading;
  final int currentPage;
  final int totalPages;
  final Function(int) onPageChanged;
  final TextEditingController searchController;
  final String searchQuery;
  final Function(String) onSearchChanged;

  const CollectionDataTable({
    super.key,
    required this.trips,
    required this.isLoading,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
    required this.searchController,
    required this.searchQuery,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DataTableLayout(
      title: 'Trip Tickets for Collection',
      searchBar: CollectionSearchBar(
        controller: searchController,
        searchQuery: searchQuery,
        onSearchChanged: onSearchChanged,
      ),
      onCreatePressed: null, // No create button for collections view
      columns: const [
        DataColumn(label: Text('ID')),
        DataColumn(label: Text('Trip Number')),
        DataColumn(label: Text('Start Date')),
        DataColumn(label: Text('End Date')),
        DataColumn(label: Text('Payment Modes')),
        DataColumn(label: Text('Status')),
        DataColumn(label: Text('Actions')),
      ],
      rows:
          trips.map((trip) {
            return DataRow(
              cells: [
                DataCell(
                  Text(trip.id ?? 'N/A'),
                  onTap: () => _navigateToTripData(context, trip),
                ),
                DataCell(
                  Text(trip.tripNumberId ?? 'N/A'),
                  onTap: () => _navigateToTripData(context, trip),
                ),
                DataCell(
                  Text(_formatDate(trip.timeAccepted)),
                  onTap: () => _navigateToTripData(context, trip),
                ),
                DataCell(
                  Text(_formatDate(trip.timeEndTrip)),
                  onTap: () => _navigateToTripData(context, trip),
                ),
                DataCell(
                  _buildPaymentModesCell(trip),
                  onTap: () => _navigateToTripData(context, trip),
                ),
                DataCell(
                  _buildStatusChip(trip),
                  onTap: () => _navigateToTripData(context, trip),
                ),
                DataCell(
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.visibility, color: Colors.blue),
                        tooltip: 'View Collections',
                        onPressed: () => _navigateToTripData(context, trip),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
      currentPage: currentPage,
      totalPages: totalPages,
      onPageChanged: onPageChanged,
      isLoading: isLoading,
      onFiltered: () {
        // Show filter options
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Filter options coming soon')),
        );
      },
    );
  }

  void _navigateToTripData(BuildContext context, TripEntity trip) {
    if (trip.id != null) {
      context.read<TripBloc>().add(GetTripTicketByIdEvent(trip.id!));
      context.go('/collections/${trip.id}');
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('MMM dd, yyyy').format(date);
  }

  Widget _buildStatusChip(TripEntity trip) {
    Color color;
    String status;

    if (trip.isEndTrip == true) {
      color = Colors.green;
      status = 'Completed';
    } else if (trip.isAccepted == true) {
      color = Colors.blue;
      status = 'In Progress';
    } else {
      color = Colors.orange;
      status = 'Pending';
    }

    return Chip(
      label: Text(
        status,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: color,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      visualDensity: VisualDensity.compact,
    );
  }

  // New method to build payment modes cell
  Widget _buildPaymentModesCell(TripEntity trip) {
    // Get all completed customers from the trip
    final completedCustomers = trip.completedCustomers;
    
    if (completedCustomers.isEmpty) {
      return const Text('No collections');
    }
    
    // Count payment modes
    final Map<ModeOfPayment, int> paymentModeCounts = {};
    
    for (final customer in completedCustomers) {
      ModeOfPayment paymentMode = _determinePaymentMode(customer);
      paymentModeCounts[paymentMode] = (paymentModeCounts[paymentMode] ?? 0) + 1;
    }
    
    // If we have too many payment modes, just show a summary
    if (paymentModeCounts.length > 2) {
      return Wrap(
        spacing: 4,
        runSpacing: 4,
        children: [
          PaymentModeChip(
            mode: ModeOfPayment.cashOnDelivery,
            count: paymentModeCounts[ModeOfPayment.cashOnDelivery] ?? 0,
          ),
          PaymentModeChip(
            mode: ModeOfPayment.bankTransfer,
            count: paymentModeCounts[ModeOfPayment.bankTransfer] ?? 0,
          ),
          PaymentModeChip(
            mode: ModeOfPayment.cheque,
            count: paymentModeCounts[ModeOfPayment.cheque] ?? 0,
          ),
          PaymentModeChip(
            mode: ModeOfPayment.eWallet,
            count: paymentModeCounts[ModeOfPayment.eWallet] ?? 0,
          ),
        ],
      );
    }
    
    // Otherwise, show each payment mode with its count
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: paymentModeCounts.entries.map((entry) {
        return PaymentModeChip(
          mode: entry.key,
          count: entry.value,
        );
      }).toList(),
    );
  }
  
  // Helper method to determine payment mode from a completed customer
  ModeOfPayment _determinePaymentMode(dynamic customer) {
    // Check if we have the enum string representation
    if (customer.modeOfPaymentString != null) {
      return ModeOfPayment.values.firstWhere(
        (mode) => mode.toString() == customer.modeOfPaymentString,
        orElse: () => ModeOfPayment.cashOnDelivery,
      );
    } 
    
    // If we have a string representation
    if (customer.modeOfPayment != null) {
      final modeOfPaymentStr = customer.modeOfPayment.toString().toLowerCase();
      
      if (modeOfPaymentStr.contains('cash')) {
        return ModeOfPayment.cashOnDelivery;
      } else if (modeOfPaymentStr.contains('bank')) {
        return ModeOfPayment.bankTransfer;
      } else if (modeOfPaymentStr.contains('cheque') || 
                modeOfPaymentStr.contains('check')) {
        return ModeOfPayment.cheque;
      } else if (modeOfPaymentStr.contains('wallet') || 
                modeOfPaymentStr.contains('e-wallet') ||
                modeOfPaymentStr.contains('ewallet')) {
        return ModeOfPayment.eWallet;
      }
    }
    
    return ModeOfPayment.cashOnDelivery; // Default
  }
}
