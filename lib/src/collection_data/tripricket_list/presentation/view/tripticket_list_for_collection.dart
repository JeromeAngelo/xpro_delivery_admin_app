import 'package:desktop_app/core/common/app/features/Trip_Ticket/trip/domain/entity/trip_entity.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/trip/presentation/bloc/trip_bloc.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/trip/presentation/bloc/trip_event.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/trip/presentation/bloc/trip_state.dart';
import 'package:desktop_app/core/common/widgets/app_structure/desktop_layout.dart';
import 'package:desktop_app/core/common/widgets/reusable_widgets/app_navigation_items.dart';
import 'package:desktop_app/src/collection_data/tripricket_list/presentation/widgets/trip_ticket_collection_widgets/collection_data_table.dart';
import 'package:desktop_app/src/collection_data/tripricket_list/presentation/widgets/trip_ticket_collection_widgets/collection_error_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class TripTicketListForCollection extends StatefulWidget {
  const TripTicketListForCollection({super.key});

  @override
  State<TripTicketListForCollection> createState() => _TripTicketListForCollectionState();
}

class _TripTicketListForCollectionState extends State<TripTicketListForCollection> {
  int _currentPage = 1;
  int _totalPages = 1;
  final int _itemsPerPage = 25;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load trip tickets when the screen initializes
    context.read<TripBloc>().add(const GetAllTripTicketsEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Define navigation items
    final navigationItems = AppNavigationItems.collectionNavigationItems();

    return DesktopLayout(
      navigationItems: navigationItems,
      currentRoute: '/collections', // Match the route in router.dart
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
      child: BlocBuilder<TripBloc, TripState>(
        builder: (context, state) {
          // Handle different states
          if (state is TripInitial) {
            // Initial state, trigger loading
            context.read<TripBloc>().add(const GetAllTripTicketsEvent());
            return const Center(child: CircularProgressIndicator());
          }

          if (state is TripLoading) {
            return CollectionDataTable(
              trips: [],
              isLoading: true,
              currentPage: _currentPage,
              totalPages: _totalPages,
              onPageChanged: (page) {
                setState(() {
                  _currentPage = page;
                });
              },
              searchController: _searchController,
              searchQuery: _searchQuery,
              onSearchChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            );
          }

          if (state is TripError) {
            return CollectionErrorWidget(errorMessage: state.message);
          }

          if (state is AllTripTicketsLoaded || state is TripTicketsSearchResults) {
            List<TripEntity> trips = [];

            if (state is AllTripTicketsLoaded) {
              trips = state.trips;
            } else if (state is TripTicketsSearchResults) {
              trips = state.trips;
            }

            // Filter trips based on search query
            if (_searchQuery.isNotEmpty) {
              trips = trips.where((trip) {
                final query = _searchQuery.toLowerCase();
                return (trip.id?.toLowerCase().contains(query) ?? false) ||
                       (trip.tripNumberId?.toLowerCase().contains(query) ?? false);
              }).toList();
            }

            // Filter trips to only show completed trips (for collections)
            trips = trips.where((trip) => trip.isEndTrip == true).toList();

            // Calculate total pages
            _totalPages = (trips.length / _itemsPerPage).ceil();
            if (_totalPages == 0) _totalPages = 1;

            // Paginate trips
            final startIndex = (_currentPage - 1) * _itemsPerPage;
            final endIndex = startIndex + _itemsPerPage > trips.length 
                ? trips.length 
                : startIndex + _itemsPerPage;
            
            final paginatedTrips = startIndex < trips.length 
                ? trips.sublist(startIndex, endIndex) 
                : [];

            return CollectionDataTable(
              trips: paginatedTrips as List<TripEntity>,
              isLoading: false,
              currentPage: _currentPage,
              totalPages: _totalPages,
              onPageChanged: (page) {
                setState(() {
                  _currentPage = page;
                });
              },
              searchController: _searchController,
              searchQuery: _searchQuery,
              onSearchChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
                // If search query is empty, refresh the trips list
                if (value.isEmpty) {
                  context.read<TripBloc>().add(const GetAllTripTicketsEvent());
                }
              },
            );
          }

          // Default fallback
          return const Center(child: Text('Unknown state'));
        },
      ),
    );
  }
}
