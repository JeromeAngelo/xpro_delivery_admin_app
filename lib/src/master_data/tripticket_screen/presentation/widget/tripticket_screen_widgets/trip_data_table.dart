import 'package:desktop_app/src/master_data/tripticket_screen/presentation/widget/tripticket_screen_widgets/trip_delete_dialog.dart';
import 'package:desktop_app/src/master_data/tripticket_screen/presentation/widget/tripticket_screen_widgets/trip_search_bar.dart';
import 'package:desktop_app/src/master_data/tripticket_screen/presentation/widget/tripticket_screen_widgets/trip_status_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/trip/data/models/trip_models.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/trip/domain/entity/trip_entity.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/trip/presentation/bloc/trip_bloc.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/trip/presentation/bloc/trip_event.dart';
import 'package:desktop_app/core/common/widgets/app_structure/data_table_layout.dart';
import 'package:go_router/go_router.dart';

import 'package:intl/intl.dart';

class TripDataTable extends StatelessWidget {
  final List<TripEntity> trips;
  final bool isLoading;
  final int currentPage;
  final int totalPages;
  final Function(int) onPageChanged;
  final TextEditingController searchController;
  final String searchQuery;
  final Function(String) onSearchChanged;

  const TripDataTable({
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
    final headerStyle = TextStyle(
      fontWeight: FontWeight.bold,
      color: Colors.black, // or any color you prefer
    );

    return DataTableLayout(
      title: 'Trip Tickets',
      searchBar: TripSearchBar(
        controller: searchController,
        searchQuery: searchQuery,
        onSearchChanged: onSearchChanged,
      ),
      onCreatePressed: () {
        context.go('/tripticket-create');
      },
      createButtonText: 'Create Trip Ticket',
      columns: [
        DataColumn(label: Text('ID', style: headerStyle)),
        DataColumn(label: Text('Trip Number', style: headerStyle)),
        DataColumn(label: Text('Start Date', style: headerStyle)),
        DataColumn(label: Text('End Date', style: headerStyle)),
        DataColumn(label: Text('User', style: headerStyle)),

        //invoices and others
        DataColumn(label: Text('Status', style: headerStyle)),

        //  DataColumn(label: Text('Customers', style: headerStyle)),
        DataColumn(label: Text('Actions', style: headerStyle)),
      ],
      rows:
          trips.map((trip) {
            // Debug print for each trip
            debugPrint('🔍 TABLE: Processing trip: ${trip.id}');

            return DataRow(
              cells: [
                DataCell(
                  Text(trip.id ?? 'N/A'),
                  onTap: () => _navigateToTripDetails(context, trip),
                ),
                DataCell(
                  Text(trip.tripNumberId ?? 'N/A'),
                  onTap: () => _navigateToTripDetails(context, trip),
                ),
                DataCell(
                  Text(_formatDate(trip.timeAccepted)),
                  onTap: () => _navigateToTripDetails(context, trip),
                ),
                DataCell(
                  Text(_formatDate(trip.timeEndTrip)),
                  onTap: () => _navigateToTripDetails(context, trip),
                ),
                DataCell(
                  Text(trip.user?.name ?? 'N/A'),
                  onTap: () => _navigateToTripDetails(context, trip),
                ),

                DataCell(
                  TripStatusChip(trip: trip),
                  onTap: () => _navigateToTripDetails(context, trip),
                ),

                // DataCell(
                //   Text(trip.customers.length.toString()),
                //   onTap: () => _navigateToTripDetails(context, trip),
                // ),
                DataCell(
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.visibility, color: Colors.blue),
                        tooltip: 'View Details',
                        onPressed: () => _navigateToTripDetails(context, trip),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.orange),
                        tooltip: 'Edit',
                        onPressed: () {
                          // Edit trip
                          if (trip.id != null) {
                            // Navigate to edit screen with trip data
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        tooltip: 'Delete',
                        onPressed: () {
                          // We need to check if trip is TripModel before showing delete dialog
                          if (trip is TripModel) {
                            showTripDeleteDialog(context, trip);
                          } else if (trip.id != null) {
                            // Alternative approach if it's not a TripModel
                            context.read<TripBloc>().add(
                              DeleteTripTicketEvent(trip.id!),
                            );
                          }
                        },
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
      enableSelection: false,
      onFiltered: () {}, // Keep selection disabled to avoid checkbox issues
    );
  }

  // Helper method to navigate to trip details
  void _navigateToTripDetails(BuildContext context, TripEntity trip) {
    if (trip.id != null) {
      // First load the trip data
      context.read<TripBloc>().add(GetTripTicketByIdEvent(trip.id!));

      // Then navigate to the specific trip view
      context.go('/tripticket/${trip.id}');
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    try {
      // Change the format from "MMM dd, yyyy hh:mm a" to "MM/dd/yyyy hh:mm a"
      return DateFormat('MM/dd/yyyy hh:mm a').format(date);
    } catch (e) {
      debugPrint('❌ Error formatting date: $e');
      return 'Invalid Date';
    }
  }
}
