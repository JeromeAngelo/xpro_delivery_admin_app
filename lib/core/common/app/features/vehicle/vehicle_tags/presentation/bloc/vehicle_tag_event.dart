import 'package:equatable/equatable.dart';

abstract class VehicleTagEvent extends Equatable {
  const VehicleTagEvent();

  @override
  List<Object?> get props => [];
}

class GetVehicleTagsEvent extends VehicleTagEvent {
  const GetVehicleTagsEvent();
}

class LoadVehicleTagByIdEvent extends VehicleTagEvent {
  final String tagId;

  const LoadVehicleTagByIdEvent(this.tagId);

  @override
  List<Object?> get props => [tagId];
}

class CreateVehicleTagEvent extends VehicleTagEvent {
  final String label;
  final List<String> tagType;
  final String? description;

  const CreateVehicleTagEvent({
    required this.label,
    required this.tagType,
    this.description,
  });

  @override
  List<Object?> get props => [label, tagType, description];
}

class UpdateVehicleTagEvent extends VehicleTagEvent {
  final String tagId;
  final String? label;
  final List<String>? tagType;
  final String? description;

  const UpdateVehicleTagEvent({
    required this.tagId,
    this.label,
    this.tagType,
    this.description,
  });

  @override
  List<Object?> get props => [tagId, label, tagType, description];
}

class DeleteVehicleTagEvent extends VehicleTagEvent {
  final String tagId;

  const DeleteVehicleTagEvent(this.tagId);

  @override
  List<Object?> get props => [tagId];
}

class AssignTagToVehicleEvent extends VehicleTagEvent {
  final String vehicleId;
  final String tagId;

  const AssignTagToVehicleEvent({required this.vehicleId, required this.tagId});

  @override
  List<Object?> get props => [vehicleId, tagId];
}

class UnassignTagFromVehicleEvent extends VehicleTagEvent {
  final String vehicleId;
  final String tagId;

  const UnassignTagFromVehicleEvent({
    required this.vehicleId,
    required this.tagId,
  });

  @override
  List<Object?> get props => [vehicleId, tagId];
}

class RefreshVehicleTagsEvent extends VehicleTagEvent {
  const RefreshVehicleTagsEvent();
}
