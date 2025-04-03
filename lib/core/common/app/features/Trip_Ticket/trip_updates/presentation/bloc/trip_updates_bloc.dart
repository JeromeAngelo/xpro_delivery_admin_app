import 'package:desktop_app/core/common/app/features/Trip_Ticket/trip_updates/domain/usecases/create_trip_updates.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/trip_updates/domain/usecases/delete_all_trip_updates.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/trip_updates/domain/usecases/delete_trip_update.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/trip_updates/domain/usecases/get_all_trip_updates.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/trip_updates/domain/usecases/get_trip_updates.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/trip_updates/domain/usecases/update_trip_update.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/trip_updates/presentation/bloc/trip_updates_event.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/trip_updates/presentation/bloc/trip_updates_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TripUpdatesBloc extends Bloc<TripUpdatesEvent, TripUpdatesState> {
  final GetTripUpdates _getTripUpdates;
  final GetAllTripUpdates _getAllTripUpdates;
  final CreateTripUpdate _createTripUpdate;
  final UpdateTripUpdate _updateTripUpdate;
  final DeleteTripUpdate _deleteTripUpdate;
  final DeleteAllTripUpdates _deleteAllTripUpdates;
  
  TripUpdatesState? _cachedState;

  TripUpdatesBloc({
    required GetTripUpdates getTripUpdates,
    required GetAllTripUpdates getAllTripUpdates,
    required CreateTripUpdate createTripUpdate,
    required UpdateTripUpdate updateTripUpdate,
    required DeleteTripUpdate deleteTripUpdate,
    required DeleteAllTripUpdates deleteAllTripUpdates,
  })  : _getTripUpdates = getTripUpdates,
        _getAllTripUpdates = getAllTripUpdates,
        _createTripUpdate = createTripUpdate,
        _updateTripUpdate = updateTripUpdate,
        _deleteTripUpdate = deleteTripUpdate,
        _deleteAllTripUpdates = deleteAllTripUpdates,
        super(TripUpdatesInitial()) {
    on<GetTripUpdatesEvent>(_onGetTripUpdates);
    on<GetAllTripUpdatesEvent>(_onGetAllTripUpdates);
    on<CreateTripUpdateEvent>(_onCreateTripUpdate);
    on<UpdateTripUpdateEvent>(_onUpdateTripUpdate);
    on<DeleteTripUpdateEvent>(_onDeleteTripUpdate);
    on<DeleteAllTripUpdatesEvent>(_onDeleteAllTripUpdates);
  }

Future<void> _onGetTripUpdates(
  GetTripUpdatesEvent event,
  Emitter<TripUpdatesState> emit,
) async {
  debugPrint('🔄 Getting trip updates for trip: ${event.tripId}');

  // Only use cache if it's for the same trip ID
  final shouldUseCache = _cachedState is TripUpdatesLoaded && 
                         (_cachedState as TripUpdatesLoaded).updates.isNotEmpty && 
                         (_cachedState as TripUpdatesLoaded).updates.first.trip?.id == event.tripId;
  
  if (shouldUseCache) {
    emit(_cachedState!);
  } else {
    emit(TripUpdatesLoading());
  }

  final result = await _getTripUpdates(event.tripId);
  result.fold(
    (failure) {
      debugPrint('❌ Failed to get trip updates: ${failure.message}');
      emit(TripUpdatesError(failure.message));
    },
    (updates) {
      debugPrint('✅ Successfully retrieved ${updates.length} trip updates');
      final newState = TripUpdatesLoaded(updates);
      _cachedState = newState;
      emit(newState);
    },
  );
}



  Future<void> _onGetAllTripUpdates(
    GetAllTripUpdatesEvent event,
    Emitter<TripUpdatesState> emit,
  ) async {
    debugPrint('🔄 Getting all trip updates');
    emit(TripUpdatesLoading());

    final result = await _getAllTripUpdates();
    result.fold(
      (failure) {
        debugPrint('❌ Failed to get all trip updates: ${failure.message}');
        emit(TripUpdatesError(failure.message));
      },
      (updates) {
        debugPrint('✅ Successfully retrieved ${updates.length} trip updates');
        emit(AllTripUpdatesLoaded(updates));
      },
    );
  }

  Future<void> _onCreateTripUpdate(
    CreateTripUpdateEvent event,
    Emitter<TripUpdatesState> emit,
  ) async {
    debugPrint('🔄 Creating trip update');
    emit(TripUpdatesLoading());

    final result = await _createTripUpdate(
      CreateTripUpdateParams(
        tripId: event.tripId,
        description: event.description,
        image: event.image,
        latitude: event.latitude,
        longitude: event.longitude,
        status: event.status,
      ),
    );

    result.fold(
      (failure) {
        debugPrint('❌ Failed to create trip update: ${failure.message}');
        emit(TripUpdatesError(failure.message));
      },
      (update) {
        debugPrint('✅ Trip update created successfully');
        emit(TripUpdateCreated(update));
        // Refresh the trip updates list
        add(GetTripUpdatesEvent(event.tripId));
      },
    );
  }

  Future<void> _onUpdateTripUpdate(
    UpdateTripUpdateEvent event,
    Emitter<TripUpdatesState> emit,
  ) async {
    debugPrint('🔄 Updating trip update: ${event.updateId}');
    emit(TripUpdatesLoading());

    final result = await _updateTripUpdate(
      UpdateTripUpdateParams(
        updateId: event.updateId,
        description: event.description,
        image: event.image,
        latitude: event.latitude,
        longitude: event.longitude,
        status: event.status,
      ),
    );

    result.fold(
      (failure) {
        debugPrint('❌ Failed to update trip update: ${failure.message}');
        emit(TripUpdatesError(failure.message));
      },
      (update) {
        debugPrint('✅ Trip update updated successfully');
        emit(TripUpdateUpdated(update));
        
        // If we have a cached state with trip updates, refresh it
        if (_cachedState is TripUpdatesLoaded) {
          final tripId = update.trip?.id;
          if (tripId != null) {
            add(GetTripUpdatesEvent(tripId));
          } else {
            add(const GetAllTripUpdatesEvent());
          }
        }
      },
    );
  }

  Future<void> _onDeleteTripUpdate(
    DeleteTripUpdateEvent event,
    Emitter<TripUpdatesState> emit,
  ) async {
    debugPrint('🔄 Deleting trip update: ${event.updateId}');
    emit(TripUpdatesLoading());

    final result = await _deleteTripUpdate(event.updateId);
    result.fold(
      (failure) {
        debugPrint('❌ Failed to delete trip update: ${failure.message}');
        emit(TripUpdatesError(failure.message));
      },
      (success) {
        debugPrint('✅ Trip update deleted successfully');
        emit(TripUpdateDeleted(event.updateId));
        
        // Refresh the list after deletion
        if (_cachedState is TripUpdatesLoaded) {
          final updates = (_cachedState as TripUpdatesLoaded).updates;
          if (updates.isNotEmpty && updates.first.trip?.id != null) {
            add(GetTripUpdatesEvent(updates.first.trip!.id!));
          } else {
            add(const GetAllTripUpdatesEvent());
          }
        }
      },
    );
  }

  Future<void> _onDeleteAllTripUpdates(
    DeleteAllTripUpdatesEvent event,
    Emitter<TripUpdatesState> emit,
  ) async {
    debugPrint('🔄 Deleting all trip updates');
    emit(TripUpdatesLoading());

    final result = await _deleteAllTripUpdates();
    result.fold(
      (failure) {
        debugPrint('❌ Failed to delete all trip updates: ${failure.message}');
        emit(TripUpdatesError(failure.message));
      },
      (success) {
        debugPrint('✅ All trip updates deleted successfully');
        _cachedState = null;
        emit(AllTripUpdatesDeleted());
      },
    );
  }

  @override
  Future<void> close() {
    _cachedState = null;
    return super.close();
  }
}
