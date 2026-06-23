import 'package:equatable/equatable.dart';

abstract class MunicipalityEvent extends Equatable {
  const MunicipalityEvent();

  @override
  List<Object?> get props => [];
}

class GetAllMunicipalitiesEvent extends MunicipalityEvent {
  const GetAllMunicipalitiesEvent();
}

class GetAllMunicipalitiesByProvinceIdEvent extends MunicipalityEvent {
  final String provinceId;
  const GetAllMunicipalitiesByProvinceIdEvent(this.provinceId);

  @override
  List<Object?> get props => [provinceId];
}

class GetMunicipalityByIdEvent extends MunicipalityEvent {
  final String id;
  const GetMunicipalityByIdEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class CreateMunicipalityEvent extends MunicipalityEvent {
  final String name;
  final String provinceId;
  const CreateMunicipalityEvent({required this.name, required this.provinceId});

  @override
  List<Object?> get props => [name, provinceId];
}

class UpdateMunicipalityEvent extends MunicipalityEvent {
  final String id;
  final String name;
  final String provinceId;
  const UpdateMunicipalityEvent({
    required this.id,
    required this.name,
    required this.provinceId,
  });

  @override
  List<Object?> get props => [id, name, provinceId];
}

class DeleteMunicipalityEvent extends MunicipalityEvent {
  final String id;
  const DeleteMunicipalityEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class GetAssignedMunicipalitiesByVehicleProfileIdEvent
    extends MunicipalityEvent {
  final String vehicleProfileId;
  const GetAssignedMunicipalitiesByVehicleProfileIdEvent(this.vehicleProfileId);

  @override
  List<Object?> get props => [vehicleProfileId];
}
