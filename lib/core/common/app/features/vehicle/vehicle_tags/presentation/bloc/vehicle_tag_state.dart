import 'package:equatable/equatable.dart';
import '../../domain/entity/vehicle_tag_entity.dart';

abstract class VehicleTagState extends Equatable {
  const VehicleTagState();

  @override
  List<Object?> get props => [];
}

class VehicleTagInitial extends VehicleTagState {
  const VehicleTagInitial();
}

class VehicleTagLoading extends VehicleTagState {
  const VehicleTagLoading();
}

class VehicleTagsLoaded extends VehicleTagState {
  final List<VehicleTagEntity> vehicleTags;
  final bool isFromCache;

  const VehicleTagsLoaded({
    required this.vehicleTags,
    this.isFromCache = false,
  });

  @override
  List<Object?> get props => [vehicleTags, isFromCache];
}

class VehicleTagLoaded extends VehicleTagState {
  final VehicleTagEntity vehicleTag;
  final bool isFromCache;

  const VehicleTagLoaded({required this.vehicleTag, this.isFromCache = false});

  @override
  List<Object?> get props => [vehicleTag, isFromCache];
}

class VehicleTagCreated extends VehicleTagState {
  final VehicleTagEntity vehicleTag;

  const VehicleTagCreated(this.vehicleTag);

  @override
  List<Object?> get props => [vehicleTag];
}

class VehicleTagUpdated extends VehicleTagState {
  final VehicleTagEntity vehicleTag;

  const VehicleTagUpdated(this.vehicleTag);

  @override
  List<Object?> get props => [vehicleTag];
}

class VehicleTagDeleted extends VehicleTagState {
  final String tagId;

  const VehicleTagDeleted(this.tagId);

  @override
  List<Object?> get props => [tagId];
}

class TagAssignedToVehicle extends VehicleTagState {
  final String vehicleId;
  final String tagId;

  const TagAssignedToVehicle({required this.vehicleId, required this.tagId});

  @override
  List<Object?> get props => [vehicleId, tagId];
}

class TagUnassignedFromVehicle extends VehicleTagState {
  final String vehicleId;
  final String tagId;

  const TagUnassignedFromVehicle({
    required this.vehicleId,
    required this.tagId,
  });

  @override
  List<Object?> get props => [vehicleId, tagId];
}

class VehicleTagError extends VehicleTagState {
  final String message;
  final String? errorCode;

  const VehicleTagError({required this.message, this.errorCode});

  @override
  List<Object?> get props => [message, errorCode];
}

class VehicleTagEmpty extends VehicleTagState {
  const VehicleTagEmpty();
}
