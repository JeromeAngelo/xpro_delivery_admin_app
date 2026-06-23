import 'package:equatable/equatable.dart';

import '../../domain/entity/region_entity.dart';

abstract class RegionState extends Equatable {
  const RegionState();

  @override
  List<Object?> get props => [];
}

class RegionInitial extends RegionState {
  const RegionInitial();
}

class RegionLoading extends RegionState {
  const RegionLoading();
}

class RegionsLoaded extends RegionState {
  final List<RegionEntity> regions;
  const RegionsLoaded(this.regions);

  @override
  List<Object?> get props => [regions];
}

class RegionLoaded extends RegionState {
  final RegionEntity region;
  const RegionLoaded(this.region);

  @override
  List<Object?> get props => [region];
}

class RegionCreated extends RegionState {
  final RegionEntity region;
  const RegionCreated(this.region);

  @override
  List<Object?> get props => [region];
}

class RegionUpdated extends RegionState {
  final RegionEntity region;
  const RegionUpdated(this.region);

  @override
  List<Object?> get props => [region];
}

class RegionDeleted extends RegionState {
  final String id;
  const RegionDeleted(this.id);

  @override
  List<Object?> get props => [id];
}

class RegionsAssignedLoaded extends RegionState {
  final List<RegionEntity> regions;
  const RegionsAssignedLoaded(this.regions);

  @override
  List<Object?> get props => [regions];
}

class RegionError extends RegionState {
  final String message;
  const RegionError(this.message);

  @override
  List<Object?> get props => [message];
}
