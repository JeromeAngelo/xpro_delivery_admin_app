import 'package:equatable/equatable.dart';
import '../../domain/entity/province_entity.dart';

abstract class ProvinceState extends Equatable {
  const ProvinceState();

  @override
  List<Object?> get props => [];
}

class ProvinceInitial extends ProvinceState {
  const ProvinceInitial();
}

class ProvinceLoading extends ProvinceState {
  const ProvinceLoading();
}

class ProvincesLoaded extends ProvinceState {
  final List<ProvinceEntity> provinces;
  const ProvincesLoaded(this.provinces);

  @override
  List<Object?> get props => [provinces];
}

class ProvincesByRegionLoaded extends ProvinceState {
  final List<ProvinceEntity> provinces;
  final String regionId;
  const ProvincesByRegionLoaded(this.provinces, this.regionId);

  @override
  List<Object?> get props => [provinces, regionId];
}

class ProvinceLoaded extends ProvinceState {
  final ProvinceEntity province;
  const ProvinceLoaded(this.province);

  @override
  List<Object?> get props => [province];
}

class ProvinceCreated extends ProvinceState {
  final ProvinceEntity province;
  const ProvinceCreated(this.province);

  @override
  List<Object?> get props => [province];
}

class ProvinceUpdated extends ProvinceState {
  final ProvinceEntity province;
  const ProvinceUpdated(this.province);

  @override
  List<Object?> get props => [province];
}

class ProvinceDeleted extends ProvinceState {
  final String id;
  const ProvinceDeleted(this.id);

  @override
  List<Object?> get props => [id];
}

class ProvincesAssignedLoaded extends ProvinceState {
  final List<ProvinceEntity> provinces;
  const ProvincesAssignedLoaded(this.provinces);

  @override
  List<Object?> get props => [provinces];
}

class ProvinceError extends ProvinceState {
  final String message;
  const ProvinceError(this.message);

  @override
  List<Object?> get props => [message];
}
