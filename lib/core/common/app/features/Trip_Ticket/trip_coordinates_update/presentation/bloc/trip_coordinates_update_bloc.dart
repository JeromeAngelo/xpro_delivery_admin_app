import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/trip_coordinates_update/domain/usecase/get_trip_coordinates_by_trip_id_usecase.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/trip_coordinates_update/presentation/bloc/trip_coordinates_update_event.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/trip_coordinates_update/presentation/bloc/trip_coordinates_update_state.dart';

class TripCoordinatesUpdateBloc
    extends Bloc<TripCoordinatesUpdateEvent, TripCoordinatesUpdateState> {
  final GetTripCoordinatesByTripId _getTripCoordinatesByTripId;

  TripCoordinatesUpdateState? _cachedState;

  TripCoordinatesUpdateBloc({
    required GetTripCoordinatesByTripId getTripCoordinatesByTripId,
  })  : _getTripCoordinatesByTripId = getTripCoordinatesByTripId,
        super(TripCoordinatesUpdateInitial()) {
    on<GetTripCoordinatesByTripIdEvent>(_onGetTripCoordinatesByTripId);
    on<RefreshTripCoordinatesEvent>(_onRefreshTripCoordinates);
    on<TripCoordinatesErrorEvent>(_onTripCoordinatesError);
  }

  Future<void> _onGetTripCoordinatesByTripId(
    GetTripCoordinatesByTripIdEvent event,
    Emitter<TripCoordinatesUpdateState> emit,
  ) async {
    emit(TripCoordinatesUpdateLoading());
    debugPrint('🔄 Getting trip coordinates for trip ID: ${event.tripId}');

    final result = await _getTripCoordinatesByTripId(event.tripId);

    result.fold(
      (failure) {
        debugPrint('❌ Failed to get trip coordinates: ${failure.message}');
        emit(TripCoordinatesUpdateError(failure.message));
      },
      (coordinates) {
        if (coordinates.isEmpty) {
          debugPrint('ℹ️ No coordinates found for trip ID: ${event.tripId}');
          emit(TripCoordinatesUpdateEmpty());
        } else {
          debugPrint('✅ Retrieved ${coordinates.length} coordinates for trip ID: ${event.tripId}');
          final newState = TripCoordinatesUpdateLoaded(coordinates);
          _cachedState = newState;
          emit(newState);
        }
      },
    );
  }

  Future<void> _onRefreshTripCoordinates(
    RefreshTripCoordinatesEvent event,
    Emitter<TripCoordinatesUpdateState> emit,
  ) async {
    emit(TripCoordinatesUpdateRefreshing());
    debugPrint('🔄 Refreshing trip coordinates for trip ID: ${event.tripId}');
    
    add(GetTripCoordinatesByTripIdEvent(event.tripId));
  }

  Future<void> _onTripCoordinatesError(
    TripCoordinatesErrorEvent event,
    Emitter<TripCoordinatesUpdateState> emit,
  ) async {
    debugPrint('❌ Trip coordinates error: ${event.message}');
    emit(TripCoordinatesUpdateError(event.message));
  }

  @override
  Future<void> close() {
    _cachedState = null;
    return super.close();
  }
}
