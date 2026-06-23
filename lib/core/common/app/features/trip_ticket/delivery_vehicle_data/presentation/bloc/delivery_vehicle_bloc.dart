import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/trip_ticket/delivery_vehicle_data/domain/usecases/create_delivery_vehicle.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/trip_ticket/delivery_vehicle_data/domain/usecases/load_delivery_vehicle_by_id.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/trip_ticket/delivery_vehicle_data/domain/usecases/update_delivery_vehicle.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/trip_ticket/delivery_vehicle_data/presentation/bloc/delivery_vehicle_event.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/trip_ticket/delivery_vehicle_data/presentation/bloc/delivery_vehicle_state.dart';

import '../../domain/usecases/load_all_delivery_vehicle.dart';
import '../../domain/usecases/load_delivery_vehicle_by_trip_id.dart';

class DeliveryVehicleBloc
    extends Bloc<DeliveryVehicleEvent, DeliveryVehicleState> {
  final LoadDeliveryVehicleById _loadDeliveryVehicleById;
  final LoadDeliveryVehiclesByTripId _loadDeliveryVehiclesByTripId;
  final LoadAllDeliveryVehicles _loadAllDeliveryVehicles;
  final CreateDeliveryVehicle _createDeliveryVehicle;
  final UpdateDeliveryVehicle _updateDeliveryVehicle;

  DeliveryVehicleBloc({
    required LoadDeliveryVehicleById loadDeliveryVehicleById,
    required LoadDeliveryVehiclesByTripId loadDeliveryVehiclesByTripId,
    required LoadAllDeliveryVehicles loadAllDeliveryVehicles,
    required CreateDeliveryVehicle createDeliveryVehicle,
    required UpdateDeliveryVehicle updateDeliveryVehicle,
  }) : _loadDeliveryVehicleById = loadDeliveryVehicleById,
       _loadDeliveryVehiclesByTripId = loadDeliveryVehiclesByTripId,
       _loadAllDeliveryVehicles = loadAllDeliveryVehicles,
       _createDeliveryVehicle = createDeliveryVehicle,
       _updateDeliveryVehicle = updateDeliveryVehicle,
       super(DeliveryVehicleInitial()) {
    on<LoadDeliveryVehicleByIdEvent>(_onLoadDeliveryVehicleById);
    on<LoadDeliveryVehiclesByTripIdEvent>(_onLoadDeliveryVehiclesByTripId);
    on<LoadAllDeliveryVehiclesEvent>(_onLoadAllDeliveryVehicles);
    on<CreateDeliveryVehicleEvent>(_onCreateDeliveryVehicle);
    on<UpdateDeliveryVehicleEvent>(_onUpdateDeliveryVehicle);
  }

  Future<void> _onLoadDeliveryVehicleById(
    LoadDeliveryVehicleByIdEvent event,
    Emitter<DeliveryVehicleState> emit,
  ) async {
    emit(DeliveryVehicleLoading());
    debugPrint('🔄 Loading delivery vehicle with ID: ${event.vehicleId}');

    final result = await _loadDeliveryVehicleById(event.vehicleId);
    result.fold(
      (failure) {
        debugPrint('❌ Failed to load delivery vehicle: ${failure.message}');
        emit(DeliveryVehicleError(failure.message));
      },
      (vehicle) {
        debugPrint('✅ Successfully loaded delivery vehicle: ${vehicle.id}');
        emit(DeliveryVehicleLoaded(vehicle));
      },
    );
  }

  Future<void> _onLoadDeliveryVehiclesByTripId(
    LoadDeliveryVehiclesByTripIdEvent event,
    Emitter<DeliveryVehicleState> emit,
  ) async {
    emit(DeliveryVehicleLoading());
    debugPrint('🔄 Loading delivery vehicles for trip: ${event.tripId}');

    final result = await _loadDeliveryVehiclesByTripId(event.tripId);
    result.fold(
      (failure) {
        debugPrint('❌ Failed to load delivery vehicles: ${failure.message}');
        emit(DeliveryVehicleError(failure.message));
      },
      (vehicles) {
        debugPrint(
          '✅ Successfully loaded ${vehicles.length} delivery vehicles',
        );
        emit(DeliveryVehiclesLoaded(vehicles));
      },
    );
  }

  Future<void> _onLoadAllDeliveryVehicles(
    LoadAllDeliveryVehiclesEvent event,
    Emitter<DeliveryVehicleState> emit,
  ) async {
    emit(DeliveryVehicleLoading());
    debugPrint('🔄 Loading all delivery vehicles');

    final result = await _loadAllDeliveryVehicles();
    result.fold(
      (failure) {
        debugPrint(
          '❌ Failed to load all delivery vehicles: ${failure.message}',
        );
        emit(DeliveryVehicleError(failure.message));
      },
      (vehicles) {
        debugPrint(
          '✅ Successfully loaded ${vehicles.length} delivery vehicles',
        );
        emit(DeliveryVehiclesLoaded(vehicles));
      },
    );
  }

  Future<void> _onCreateDeliveryVehicle(
    CreateDeliveryVehicleEvent event,
    Emitter<DeliveryVehicleState> emit,
  ) async {
    emit(DeliveryVehicleLoading());
    debugPrint('🆕 Creating delivery vehicle');

    final result = await _createDeliveryVehicle(event.vehicle);
    result.fold(
      (failure) {
        debugPrint('❌ Failed to create delivery vehicle: ${failure.message}');
        emit(DeliveryVehicleError(failure.message));
      },
      (vehicle) {
        debugPrint('✅ Successfully created delivery vehicle: ${vehicle.id}');
        emit(DeliveryVehicleCreated(vehicle));
      },
    );
  }

  Future<void> _onUpdateDeliveryVehicle(
    UpdateDeliveryVehicleEvent event,
    Emitter<DeliveryVehicleState> emit,
  ) async {
    emit(DeliveryVehicleLoading());
    debugPrint('🔄 Updating delivery vehicle with ID: ${event.id}');

    final result = await _updateDeliveryVehicle(
      UpdateDeliveryVehicleParams(id: event.id, vehicle: event.vehicle),
    );
    result.fold(
      (failure) {
        debugPrint('❌ Failed to update delivery vehicle: ${failure.message}');
        emit(DeliveryVehicleError(failure.message));
      },
      (vehicle) {
        debugPrint('✅ Successfully updated delivery vehicle: ${vehicle.id}');
        emit(DeliveryVehicleUpdated(vehicle));
      },
    );
  }
}
