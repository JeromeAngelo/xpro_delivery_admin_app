import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/create_region.dart';
import '../../domain/usecases/delete_region.dart';
import '../../domain/usecases/get_all_regions.dart';
import '../../domain/usecases/get_assigned_regions_by_vehicle_profile_id.dart';
import '../../domain/usecases/get_region_by_id.dart';
import '../../domain/usecases/update_region.dart';
import 'region_event.dart';
import 'region_state.dart';

class RegionBloc extends Bloc<RegionEvent, RegionState> {
  final GetAllRegions _getAllRegions;
  final GetRegionById _getRegionById;
  final CreateRegion _createRegion;
  final UpdateRegion _updateRegion;
  final DeleteRegion _deleteRegion;
  final GetAssignedRegionsByVehicleProfileId
  _getAssignedRegionsByVehicleProfileId;

  RegionBloc({
    required GetAllRegions getAllRegions,
    required GetRegionById getRegionById,
    required CreateRegion createRegion,
    required UpdateRegion updateRegion,
    required DeleteRegion deleteRegion,
    required GetAssignedRegionsByVehicleProfileId
    getAssignedRegionsByVehicleProfileId,
  }) : _getAllRegions = getAllRegions,
       _getRegionById = getRegionById,
       _createRegion = createRegion,
       _updateRegion = updateRegion,
       _deleteRegion = deleteRegion,
       _getAssignedRegionsByVehicleProfileId =
           getAssignedRegionsByVehicleProfileId,
       super(const RegionInitial()) {
    on<GetAllRegionsEvent>(_onGetAllRegions);
    on<GetRegionByIdEvent>(_onGetRegionById);
    on<CreateRegionEvent>(_onCreateRegion);
    on<UpdateRegionEvent>(_onUpdateRegion);
    on<DeleteRegionEvent>(_onDeleteRegion);
    on<GetAssignedRegionsByVehicleProfileIdEvent>(
      _onGetAssignedRegionsByVehicleProfileId,
    );
  }

  Future<void> _onGetAllRegions(
    GetAllRegionsEvent event,
    Emitter<RegionState> emit,
  ) async {
    emit(const RegionLoading());
    final result = await _getAllRegions();
    result.fold(
      (failure) {
        emit(RegionError(failure.message));
      },
      (regions) {
        emit(RegionsLoaded(regions));
      },
    );
  }

  Future<void> _onGetRegionById(
    GetRegionByIdEvent event,
    Emitter<RegionState> emit,
  ) async {
    emit(const RegionLoading());
    final result = await _getRegionById(event.id);
    result.fold(
      (failure) {
        emit(RegionError(failure.message));
      },
      (region) {
        emit(RegionLoaded(region));
      },
    );
  }

  Future<void> _onCreateRegion(
    CreateRegionEvent event,
    Emitter<RegionState> emit,
  ) async {
    emit(const RegionLoading());
    final result = await _createRegion(
      CreateRegionParams(name: event.name, alias: event.alias),
    );
    result.fold(
      (failure) {
        emit(RegionError(failure.message));
      },
      (region) {
        emit(RegionCreated(region));
      },
    );
  }

  Future<void> _onUpdateRegion(
    UpdateRegionEvent event,
    Emitter<RegionState> emit,
  ) async {
    emit(const RegionLoading());
    final result = await _updateRegion(
      UpdateRegionParams(id: event.id, name: event.name, alias: event.alias),
    );
    result.fold(
      (failure) {
        emit(RegionError(failure.message));
      },
      (region) {
        emit(RegionUpdated(region));
      },
    );
  }

  Future<void> _onDeleteRegion(
    DeleteRegionEvent event,
    Emitter<RegionState> emit,
  ) async {
    emit(const RegionLoading());
    final result = await _deleteRegion(event.id);
    result.fold(
      (failure) {
        emit(RegionError(failure.message));
      },
      (_) {
        emit(RegionDeleted(event.id));
      },
    );
  }

  Future<void> _onGetAssignedRegionsByVehicleProfileId(
    GetAssignedRegionsByVehicleProfileIdEvent event,
    Emitter<RegionState> emit,
  ) async {
    emit(const RegionLoading());
    final result = await _getAssignedRegionsByVehicleProfileId(
      event.vehicleProfileId,
    );
    result.fold(
      (failure) {
        emit(RegionError(failure.message));
      },
      (regions) {
        emit(RegionsAssignedLoaded(regions));
      },
    );
  }
}
