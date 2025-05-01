
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/trip/domain/usecase/create_tripticket.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/trip/domain/usecase/delete_all_tripticket.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/trip/domain/usecase/delete_trip_ticket.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/trip/domain/usecase/get_all_tripticket.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/trip/domain/usecase/get_tripticket_by_id.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/trip/domain/usecase/search_tripticket.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/trip/domain/usecase/update_tripticket.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/trip/presentation/bloc/trip_event.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/trip/presentation/bloc/trip_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TripBloc extends Bloc<TripEvent, TripState> {
  final GetAllTripTickets _getAllTripTickets;
  final CreateTripTicket _createTripTicket;
  final SearchTripTickets _searchTripTickets;
  final GetTripTicketById _getTripTicketById;
  final UpdateTripTicket _updateTripTicket;
  final DeleteTripTicket _deleteTripTicket;
  final DeleteAllTripTickets _deleteAllTripTickets;

  TripBloc({
    required GetAllTripTickets getAllTripTickets,
    required CreateTripTicket createTripTicket,
    required SearchTripTickets searchTripTickets,
    required GetTripTicketById getTripTicketById,
    required UpdateTripTicket updateTripTicket,
    required DeleteTripTicket deleteTripTicket,
    required DeleteAllTripTickets deleteAllTripTickets,
  })  : _getAllTripTickets = getAllTripTickets,
        _createTripTicket = createTripTicket,
        _searchTripTickets = searchTripTickets,
        _getTripTicketById = getTripTicketById,
        _updateTripTicket = updateTripTicket,
        _deleteTripTicket = deleteTripTicket,
        _deleteAllTripTickets = deleteAllTripTickets,
        super(TripInitial()) {
    on<GetAllTripTicketsEvent>(_onGetAllTripTickets);
    on<CreateTripTicketEvent>(_onCreateTripTicket);
    on<SearchTripTicketsEvent>(_onSearchTripTickets);
    on<GetTripTicketByIdEvent>(_onGetTripTicketById);
    on<UpdateTripTicketEvent>(_onUpdateTripTicket);
    on<DeleteTripTicketEvent>(_onDeleteTripTicket);
    on<DeleteAllTripTicketsEvent>(_onDeleteAllTripTickets);
  }

  Future<void> _onGetAllTripTickets(
    GetAllTripTicketsEvent event,
    Emitter<TripState> emit,
  ) async {
    debugPrint('🔄 BLOC: Fetching all trip tickets');
    emit(TripLoading());

    final result = await _getAllTripTickets();
    result.fold(
      (failure) {
        debugPrint('❌ BLOC: Failed to get all trip tickets: ${failure.message}');
        emit(TripError(failure.message));
      },
      (trips) {
        debugPrint('✅ BLOC: Successfully retrieved ${trips.length} trip tickets');
        emit(AllTripTicketsLoaded(trips));
      },
    );
  }

  Future<void> _onCreateTripTicket(
    CreateTripTicketEvent event,
    Emitter<TripState> emit,
  ) async {
    debugPrint('🔄 BLOC: Creating new trip ticket');
    emit(TripLoading());

    final result = await _createTripTicket(event.trip);
    result.fold(
      (failure) {
        debugPrint('❌ BLOC: Failed to create trip ticket: ${failure.message}');
        emit(TripError(failure.message));
      },
      (trip) {
        debugPrint('✅ BLOC: Trip ticket created successfully: ${trip.id}');
        emit(TripTicketCreated(trip));
        // Refresh the list
        add(const GetAllTripTicketsEvent());
      },
    );
  }

  Future<void> _onSearchTripTickets(
    SearchTripTicketsEvent event,
    Emitter<TripState> emit,
  ) async {
    debugPrint('🔍 BLOC: Searching for trip tickets');
    emit(TripLoading());

    final result = await _searchTripTickets(
      SearchTripTicketsParams(
        tripNumberId: event.tripNumberId,
        startDate: event.startDate,
        endDate: event.endDate,
        isAccepted: event.isAccepted,
        isEndTrip: event.isEndTrip,
        deliveryTeamId: event.deliveryTeamId,
        vehicleId: event.vehicleId,
        personnelId: event.personnelId,
      ),
    );
    
    result.fold(
      (failure) {
        debugPrint('❌ BLOC: Search failed: ${failure.message}');
        emit(TripError(failure.message));
      },
      (trips) {
        debugPrint('✅ BLOC: Found ${trips.length} matching trip tickets');
        emit(TripTicketsSearchResults(trips));
      },
    );
  }

  Future<void> _onGetTripTicketById(
    GetTripTicketByIdEvent event,
    Emitter<TripState> emit,
  ) async {
    debugPrint('🔄 BLOC: Fetching trip ticket by ID: ${event.tripId}');
    emit(TripLoading());

    final result = await _getTripTicketById(event.tripId);
    result.fold(
      (failure) {
        debugPrint('❌ BLOC: Failed to get trip ticket: ${failure.message}');
        emit(TripError(failure.message));
      },
      (trip) {
        debugPrint('✅ BLOC: Trip ticket found: ${trip.id}');
        emit(TripTicketLoaded(trip));
      },
    );
  }

  Future<void> _onUpdateTripTicket(
    UpdateTripTicketEvent event,
    Emitter<TripState> emit,
  ) async {
    debugPrint('🔄 BLOC: Updating trip ticket: ${event.trip.id}');
    emit(TripLoading());

    final result = await _updateTripTicket(event.trip);
    result.fold(
      (failure) {
        debugPrint('❌ BLOC: Failed to update trip ticket: ${failure.message}');
        emit(TripError(failure.message));
      },
      (trip) {
        debugPrint('✅ BLOC: Trip ticket updated successfully');
        emit(TripTicketUpdated(trip));
        // Refresh the details
        if (trip.id != null) {
          add(GetTripTicketByIdEvent(trip.id!));
        }
      },
    );
  }

  Future<void> _onDeleteTripTicket(
    DeleteTripTicketEvent event,
    Emitter<TripState> emit,
  ) async {
    debugPrint('🔄 BLOC: Deleting trip ticket: ${event.tripId}');
    emit(TripLoading());

    final result = await _deleteTripTicket(event.tripId);
    result.fold(
      (failure) {
        debugPrint('❌ BLOC: Failed to delete trip ticket: ${failure.message}');
        emit(TripError(failure.message));
      },
      (_) {
        debugPrint('✅ BLOC: Trip ticket deleted successfully');
        emit(TripTicketDeleted(event.tripId));
        // Refresh the list
        add(const GetAllTripTicketsEvent());
      },
    );
  }

  Future<void> _onDeleteAllTripTickets(
    DeleteAllTripTicketsEvent event,
    Emitter<TripState> emit,
  ) async {
    debugPrint('🔄 BLOC: Deleting all trip tickets');
    emit(TripLoading());

    final result = await _deleteAllTripTickets();
    result.fold(
      (failure) {
        debugPrint('❌ BLOC: Failed to delete all trip tickets: ${failure.message}');
        emit(TripError(failure.message));
      },
      (_) {
        debugPrint('✅ BLOC: All trip tickets deleted successfully');
        emit(AllTripTicketsDeleted());
        // Refresh to show empty list
        add(const GetAllTripTicketsEvent());
      },
    );
  }
}
