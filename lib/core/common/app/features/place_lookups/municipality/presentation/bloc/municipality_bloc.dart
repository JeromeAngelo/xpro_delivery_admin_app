import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/create_municipality.dart';
import '../../domain/usecases/delete_municipality.dart';
import '../../domain/usecases/get_all_municipalities.dart';
import '../../domain/usecases/get_all_municipalities_by_province_id.dart';
import '../../domain/usecases/get_assigned_municipalities_by_vehicle_profile_id.dart';
import '../../domain/usecases/get_municipality_by_id.dart';
import '../../domain/usecases/update_municipality.dart';
import 'municipality_event.dart';
import 'municipality_state.dart';

class MunicipalityBloc extends Bloc<MunicipalityEvent, MunicipalityState> {
  final GetAllMunicipalities _getAllMunicipalities;
  final GetAllMunicipalitiesByProvinceId _getAllMunicipalitiesByProvinceId;
  final GetMunicipalityById _getMunicipalityById;
  final CreateMunicipality _createMunicipality;
  final UpdateMunicipality _updateMunicipality;
  final DeleteMunicipality _deleteMunicipality;
  final GetAssignedMunicipalitiesByVehicleProfileId
  _getAssignedMunicipalitiesByVehicleProfileId;

  MunicipalityBloc({
    required GetAllMunicipalities getAllMunicipalities,
    required GetAllMunicipalitiesByProvinceId getAllMunicipalitiesByProvinceId,
    required GetMunicipalityById getMunicipalityById,
    required CreateMunicipality createMunicipality,
    required UpdateMunicipality updateMunicipality,
    required DeleteMunicipality deleteMunicipality,
    required GetAssignedMunicipalitiesByVehicleProfileId
    getAssignedMunicipalitiesByVehicleProfileId,
  }) : _getAllMunicipalities = getAllMunicipalities,
       _getAllMunicipalitiesByProvinceId = getAllMunicipalitiesByProvinceId,
       _getMunicipalityById = getMunicipalityById,
       _createMunicipality = createMunicipality,
       _updateMunicipality = updateMunicipality,
       _deleteMunicipality = deleteMunicipality,
       _getAssignedMunicipalitiesByVehicleProfileId =
           getAssignedMunicipalitiesByVehicleProfileId,
       super(const MunicipalityInitial()) {
    on<GetAllMunicipalitiesEvent>(_onGetAllMunicipalities);
    on<GetAllMunicipalitiesByProvinceIdEvent>(
      _onGetAllMunicipalitiesByProvinceId,
    );
    on<GetMunicipalityByIdEvent>(_onGetMunicipalityById);
    on<CreateMunicipalityEvent>(_onCreateMunicipality);
    on<UpdateMunicipalityEvent>(_onUpdateMunicipality);
    on<DeleteMunicipalityEvent>(_onDeleteMunicipality);
    on<GetAssignedMunicipalitiesByVehicleProfileIdEvent>(
      _onGetAssignedMunicipalitiesByVehicleProfileId,
    );
  }

  Future<void> _onGetAllMunicipalities(
    GetAllMunicipalitiesEvent event,
    Emitter<MunicipalityState> emit,
  ) async {
    emit(const MunicipalityLoading());
    final result = await _getAllMunicipalities();
    result.fold(
      (failure) => emit(MunicipalityError(failure.message)),
      (municipalities) => emit(MunicipalitiesLoaded(municipalities)),
    );
  }

  Future<void> _onGetAllMunicipalitiesByProvinceId(
    GetAllMunicipalitiesByProvinceIdEvent event,
    Emitter<MunicipalityState> emit,
  ) async {
    emit(const MunicipalityLoading());
    final result = await _getAllMunicipalitiesByProvinceId(event.provinceId);
    result.fold(
      (failure) => emit(MunicipalityError(failure.message)),
      (municipalities) => emit(
        MunicipalitiesByProvinceLoaded(municipalities, event.provinceId),
      ),
    );
  }

  Future<void> _onGetMunicipalityById(
    GetMunicipalityByIdEvent event,
    Emitter<MunicipalityState> emit,
  ) async {
    emit(const MunicipalityLoading());
    final result = await _getMunicipalityById(event.id);
    result.fold(
      (failure) => emit(MunicipalityError(failure.message)),
      (municipality) => emit(MunicipalityLoaded(municipality)),
    );
  }

  Future<void> _onCreateMunicipality(
    CreateMunicipalityEvent event,
    Emitter<MunicipalityState> emit,
  ) async {
    emit(const MunicipalityLoading());
    final result = await _createMunicipality(
      CreateMunicipalityParams(name: event.name, provinceId: event.provinceId),
    );
    result.fold(
      (failure) => emit(MunicipalityError(failure.message)),
      (municipality) => emit(MunicipalityCreated(municipality)),
    );
  }

  Future<void> _onUpdateMunicipality(
    UpdateMunicipalityEvent event,
    Emitter<MunicipalityState> emit,
  ) async {
    emit(const MunicipalityLoading());
    final result = await _updateMunicipality(
      UpdateMunicipalityParams(
        id: event.id,
        name: event.name,
        provinceId: event.provinceId,
      ),
    );
    result.fold(
      (failure) => emit(MunicipalityError(failure.message)),
      (municipality) => emit(MunicipalityUpdated(municipality)),
    );
  }

  Future<void> _onDeleteMunicipality(
    DeleteMunicipalityEvent event,
    Emitter<MunicipalityState> emit,
  ) async {
    emit(const MunicipalityLoading());
    final result = await _deleteMunicipality(event.id);
    result.fold(
      (failure) => emit(MunicipalityError(failure.message)),
      (_) => emit(MunicipalityDeleted(event.id)),
    );
  }

  Future<void> _onGetAssignedMunicipalitiesByVehicleProfileId(
    GetAssignedMunicipalitiesByVehicleProfileIdEvent event,
    Emitter<MunicipalityState> emit,
  ) async {
    emit(const MunicipalityLoading());
    final result = await _getAssignedMunicipalitiesByVehicleProfileId(
      event.vehicleProfileId,
    );
    result.fold(
      (failure) => emit(MunicipalityError(failure.message)),
      (municipalities) => emit(MunicipalitiesAssignedLoaded(municipalities)),
    );
  }
}
