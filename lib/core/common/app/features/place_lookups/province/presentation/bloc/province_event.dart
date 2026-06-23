import 'package:equatable/equatable.dart';

abstract class ProvinceEvent extends Equatable {
  const ProvinceEvent();

  @override
  List<Object?> get props => [];
}

class GetAllProvincesEvent extends ProvinceEvent {
  const GetAllProvincesEvent();
}

class GetAllProvincesByRegionIdEvent extends ProvinceEvent {
  final String regionId;
  const GetAllProvincesByRegionIdEvent(this.regionId);

  @override
  List<Object?> get props => [regionId];
}

class GetProvinceByIdEvent extends ProvinceEvent {
  final String id;
  const GetProvinceByIdEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class CreateProvinceEvent extends ProvinceEvent {
  final String name;
  final String regionId;
  const CreateProvinceEvent({required this.name, required this.regionId});

  @override
  List<Object?> get props => [name, regionId];
}

class UpdateProvinceEvent extends ProvinceEvent {
  final String id;
  final String name;
  final String regionId;
  const UpdateProvinceEvent({
    required this.id,
    required this.name,
    required this.regionId,
  });

  @override
  List<Object?> get props => [id, name, regionId];
}

class DeleteProvinceEvent extends ProvinceEvent {
  final String id;
  const DeleteProvinceEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class GetAssignedProvincesByVehicleProfileIdEvent extends ProvinceEvent {
  final String vehicleProfileId;
  const GetAssignedProvincesByVehicleProfileIdEvent(this.vehicleProfileId);

  @override
  List<Object?> get props => [vehicleProfileId];
}
