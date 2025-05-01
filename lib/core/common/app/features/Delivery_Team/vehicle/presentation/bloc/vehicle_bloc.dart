import 'package:xpro_delivery_admin_app/core/common/app/features/Delivery_Team/vehicle/domain/usecase/create_vehicle.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Delivery_Team/vehicle/domain/usecase/delete_all_vehicle.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Delivery_Team/vehicle/domain/usecase/delete_vehicle.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Delivery_Team/vehicle/domain/usecase/get_vehicle.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Delivery_Team/vehicle/domain/usecase/load_vehicle_by_delivery_team_id.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Delivery_Team/vehicle/domain/usecase/load_vehicle_by_trip_id.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Delivery_Team/vehicle/domain/usecase/update_vehicle.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Delivery_Team/vehicle/presentation/bloc/vehicle_event.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Delivery_Team/vehicle/presentation/bloc/vehicle_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class VehicleBloc extends Bloc<VehicleEvent, VehicleState> {
  final GetVehicle _getVehicles;
  final LoadVehicleByTripId _loadVehicleByTripId;
  final LoadVehicleByDeliveryTeam _loadVehicleByDeliveryTeam;
  final CreateVehicle _createVehicle;
  final UpdateVehicle _updateVehicle;
  final DeleteVehicle _deleteVehicle;
  final DeleteAllVehicles _deleteAllVehicles;

  VehicleBloc({
    required GetVehicle getVehicles,
    required LoadVehicleByTripId loadVehicleByTripId,
    required LoadVehicleByDeliveryTeam loadVehicleByDeliveryTeam,
    required CreateVehicle createVehicle,
    required UpdateVehicle updateVehicle,
    required DeleteVehicle deleteVehicle,
    required DeleteAllVehicles deleteAllVehicles,
  }) : _getVehicles = getVehicles,
       _loadVehicleByTripId = loadVehicleByTripId,
       _loadVehicleByDeliveryTeam = loadVehicleByDeliveryTeam,
       _createVehicle = createVehicle,
       _updateVehicle = updateVehicle,
       _deleteVehicle = deleteVehicle,
       _deleteAllVehicles = deleteAllVehicles,
       super(const VehicleInitial()) {
    on<GetVehiclesEvent>(_onGetVehiclesHandler);
    on<LoadVehicleByTripIdEvent>(_onLoadVehicleByTripId);
    on<LoadVehicleByDeliveryTeamEvent>(_onLoadVehicleByDeliveryTeam);
    on<CreateVehicleEvent>(_onCreateVehicle);
    on<UpdateVehicleEvent>(_onUpdateVehicle);
    on<DeleteVehicleEvent>(_onDeleteVehicle);
    on<DeleteAllVehiclesEvent>(_onDeleteAllVehicles);
  }

  Future<void> _onGetVehiclesHandler(
    GetVehiclesEvent event,
    Emitter<VehicleState> emit,
  ) async {
    emit(const VehicleLoading());
    debugPrint('🔄 Getting all vehicles');
    
    final result = await _getVehicles();
    result.fold(
      (failure) {
        debugPrint('❌ Error getting vehicles: ${failure.message}');
        emit(VehicleError(failure.message));
      },
      (vehicles) {
        debugPrint('✅ Successfully retrieved ${vehicles.length} vehicles');
        emit(VehiclesLoaded(vehicles));
      },
    );
  }

  Future<void> _onLoadVehicleByTripId(
    LoadVehicleByTripIdEvent event,
    Emitter<VehicleState> emit,
  ) async {
    emit(const VehicleLoading());
    debugPrint('🔄 Loading vehicle for trip: ${event.tripId}');
    
    final result = await _loadVehicleByTripId(event.tripId);
    result.fold(
      (failure) {
        debugPrint('❌ Error loading vehicle by trip: ${failure.message}');
        emit(VehicleError(failure.message));
      },
      (vehicle) {
        debugPrint('✅ Successfully loaded vehicle for trip');
        emit(VehicleByTripLoaded(vehicle));
      },
    );
  }

  Future<void> _onLoadVehicleByDeliveryTeam(
    LoadVehicleByDeliveryTeamEvent event,
    Emitter<VehicleState> emit,
  ) async {
    emit(const VehicleLoading());
    debugPrint('🔄 Loading vehicle for delivery team: ${event.deliveryTeamId}');
    
    final result = await _loadVehicleByDeliveryTeam(event.deliveryTeamId);
    result.fold(
      (failure) {
        debugPrint('❌ Error loading vehicle by delivery team: ${failure.message}');
        emit(VehicleError(failure.message));
      },
      (vehicle) {
        debugPrint('✅ Successfully loaded vehicle for delivery team');
        emit(VehicleByDeliveryTeamLoaded(vehicle));
      },
    );
  }

  Future<void> _onCreateVehicle(
    CreateVehicleEvent event,
    Emitter<VehicleState> emit,
  ) async {
    emit(const VehicleLoading());
    debugPrint('🔄 Creating new vehicle: ${event.vehicleName}');
    
    final result = await _createVehicle(
      CreateVehicleParams(
        vehicleName: event.vehicleName,
        vehiclePlateNumber: event.vehiclePlateNumber,
        vehicleType: event.vehicleType,
        deliveryTeamId: event.deliveryTeamId,
        tripId: event.tripId,
      ),
    );
    
    result.fold(
      (failure) {
        debugPrint('❌ Error creating vehicle: ${failure.message}');
        emit(VehicleError(failure.message));
      },
      (vehicle) {
        debugPrint('✅ Successfully created vehicle with ID: ${vehicle.id}');
        emit(VehicleCreated(vehicle));
      },
    );
  }

  Future<void> _onUpdateVehicle(
    UpdateVehicleEvent event,
    Emitter<VehicleState> emit,
  ) async {
    emit(const VehicleLoading());
    debugPrint('🔄 Updating vehicle: ${event.vehicleId}');
    
    final result = await _updateVehicle(
      UpdateVehicleParams(
        vehicleId: event.vehicleId,
        vehicleName: event.vehicleName,
        vehiclePlateNumber: event.vehiclePlateNumber,
        vehicleType: event.vehicleType,
        deliveryTeamId: event.deliveryTeamId,
        tripId: event.tripId,
      ),
    );
    
    result.fold(
      (failure) {
        debugPrint('❌ Error updating vehicle: ${failure.message}');
        emit(VehicleError(failure.message));
      },
      (vehicle) {
        debugPrint('✅ Successfully updated vehicle: ${vehicle.id}');
        emit(VehicleUpdated(vehicle));
      },
    );
  }

  Future<void> _onDeleteVehicle(
    DeleteVehicleEvent event,
    Emitter<VehicleState> emit,
  ) async {
    emit(const VehicleLoading());
    debugPrint('🔄 Deleting vehicle: ${event.vehicleId}');
    
    final result = await _deleteVehicle(event.vehicleId);
    
    result.fold(
      (failure) {
        debugPrint('❌ Error deleting vehicle: ${failure.message}');
        emit(VehicleError(failure.message));
      },
      (_) {
        debugPrint('✅ Successfully deleted vehicle');
        emit(VehicleDeleted(event.vehicleId));
      },
    );
  }

  Future<void> _onDeleteAllVehicles(
    DeleteAllVehiclesEvent event,
    Emitter<VehicleState> emit,
  ) async {
    emit(const VehicleLoading());
    debugPrint('🔄 Deleting multiple vehicles: ${event.vehicleIds.length} items');
    
    final result = await _deleteAllVehicles(
      DeleteAllVehiclesParams(vehicleIds: event.vehicleIds),
    );
    
    result.fold(
      (failure) {
        debugPrint('❌ Error deleting multiple vehicles: ${failure.message}');
        emit(VehicleError(failure.message));
      },
      (_) {
        debugPrint('✅ Successfully deleted all vehicles');
        emit(AllVehiclesDeleted(event.vehicleIds));
      },
    );
  }
}
