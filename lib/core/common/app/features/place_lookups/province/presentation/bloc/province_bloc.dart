import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/create_province.dart';
import '../../domain/usecases/delete_province.dart';
import '../../domain/usecases/get_all_provinces.dart';
import '../../domain/usecases/get_all_provinces_by_region_id.dart';
import '../../domain/usecases/get_assigned_provinces_by_vehicle_profile_id.dart';
import '../../domain/usecases/get_province_by_id.dart';
import '../../domain/usecases/update_province.dart';
import 'province_event.dart';
import 'province_state.dart';

class ProvinceBloc extends Bloc<ProvinceEvent, ProvinceState> {
  final GetAllProvinces _getAllProvinces;
  final GetAllProvincesByRegionId _getAllProvincesByRegionId;
  final GetProvinceById _getProvinceById;
  final CreateProvince _createProvince;
  final UpdateProvince _updateProvince;
  final DeleteProvince _deleteProvince;
  final GetAssignedProvincesByVehicleProfileId
  _getAssignedProvincesByVehicleProfileId;

  ProvinceBloc({
    required GetAllProvinces getAllProvinces,
    required GetAllProvincesByRegionId getAllProvincesByRegionId,
    required GetProvinceById getProvinceById,
    required CreateProvince createProvince,
    required UpdateProvince updateProvince,
    required DeleteProvince deleteProvince,
    required GetAssignedProvincesByVehicleProfileId
    getAssignedProvincesByVehicleProfileId,
  }) : _getAllProvinces = getAllProvinces,
       _getAllProvincesByRegionId = getAllProvincesByRegionId,
       _getProvinceById = getProvinceById,
       _createProvince = createProvince,
       _updateProvince = updateProvince,
       _deleteProvince = deleteProvince,
       _getAssignedProvincesByVehicleProfileId =
           getAssignedProvincesByVehicleProfileId,
       super(const ProvinceInitial()) {
    on<GetAllProvincesEvent>(_onGetAllProvinces);
    on<GetAllProvincesByRegionIdEvent>(_onGetAllProvincesByRegionId);
    on<GetProvinceByIdEvent>(_onGetProvinceById);
    on<CreateProvinceEvent>(_onCreateProvince);
    on<UpdateProvinceEvent>(_onUpdateProvince);
    on<DeleteProvinceEvent>(_onDeleteProvince);
    on<GetAssignedProvincesByVehicleProfileIdEvent>(
      _onGetAssignedProvincesByVehicleProfileId,
    );
  }

  Future<void> _onGetAllProvinces(
    GetAllProvincesEvent event,
    Emitter<ProvinceState> emit,
  ) async {
    emit(const ProvinceLoading());
    final result = await _getAllProvinces();
    result.fold(
      (failure) => emit(ProvinceError(failure.message)),
      (provinces) => emit(ProvincesLoaded(provinces)),
    );
  }

  Future<void> _onGetAllProvincesByRegionId(
    GetAllProvincesByRegionIdEvent event,
    Emitter<ProvinceState> emit,
  ) async {
    emit(const ProvinceLoading());
    final result = await _getAllProvincesByRegionId(event.regionId);
    result.fold(
      (failure) => emit(ProvinceError(failure.message)),
      (provinces) => emit(ProvincesByRegionLoaded(provinces, event.regionId)),
    );
  }

  Future<void> _onGetProvinceById(
    GetProvinceByIdEvent event,
    Emitter<ProvinceState> emit,
  ) async {
    emit(const ProvinceLoading());
    final result = await _getProvinceById(event.id);
    result.fold(
      (failure) => emit(ProvinceError(failure.message)),
      (province) => emit(ProvinceLoaded(province)),
    );
  }

  Future<void> _onCreateProvince(
    CreateProvinceEvent event,
    Emitter<ProvinceState> emit,
  ) async {
    emit(const ProvinceLoading());
    final result = await _createProvince(
      CreateProvinceParams(name: event.name, regionId: event.regionId),
    );
    result.fold(
      (failure) => emit(ProvinceError(failure.message)),
      (province) => emit(ProvinceCreated(province)),
    );
  }

  Future<void> _onUpdateProvince(
    UpdateProvinceEvent event,
    Emitter<ProvinceState> emit,
  ) async {
    emit(const ProvinceLoading());
    final result = await _updateProvince(
      UpdateProvinceParams(
        id: event.id,
        name: event.name,
        regionId: event.regionId,
      ),
    );
    result.fold(
      (failure) => emit(ProvinceError(failure.message)),
      (province) => emit(ProvinceUpdated(province)),
    );
  }

  Future<void> _onDeleteProvince(
    DeleteProvinceEvent event,
    Emitter<ProvinceState> emit,
  ) async {
    emit(const ProvinceLoading());
    final result = await _deleteProvince(event.id);
    result.fold(
      (failure) => emit(ProvinceError(failure.message)),
      (_) => emit(ProvinceDeleted(event.id)),
    );
  }

  Future<void> _onGetAssignedProvincesByVehicleProfileId(
    GetAssignedProvincesByVehicleProfileIdEvent event,
    Emitter<ProvinceState> emit,
  ) async {
    emit(const ProvinceLoading());
    final result = await _getAssignedProvincesByVehicleProfileId(
      event.vehicleProfileId,
    );
    result.fold(
      (failure) => emit(ProvinceError(failure.message)),
      (provinces) => emit(ProvincesAssignedLoaded(provinces)),
    );
  }
}
