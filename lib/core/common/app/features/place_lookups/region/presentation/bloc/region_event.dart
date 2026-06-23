import 'package:equatable/equatable.dart';

abstract class RegionEvent extends Equatable {
  const RegionEvent();

  @override
  List<Object?> get props => [];
}

class GetAllRegionsEvent extends RegionEvent {
  const GetAllRegionsEvent();
}

class GetRegionByIdEvent extends RegionEvent {
  final String id;
  const GetRegionByIdEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class CreateRegionEvent extends RegionEvent {
  final String name;
  final String? alias;
  const CreateRegionEvent({required this.name, this.alias});

  @override
  List<Object?> get props => [name, alias];
}

class UpdateRegionEvent extends RegionEvent {
  final String id;
  final String name;
  final String? alias;
  const UpdateRegionEvent({required this.id, required this.name, this.alias});

  @override
  List<Object?> get props => [id, name, alias];
}

class DeleteRegionEvent extends RegionEvent {
  final String id;
  const DeleteRegionEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class GetAssignedRegionsByVehicleProfileIdEvent extends RegionEvent {
  final String vehicleProfileId;
  const GetAssignedRegionsByVehicleProfileIdEvent(this.vehicleProfileId);

  @override
  List<Object?> get props => [vehicleProfileId];
}
