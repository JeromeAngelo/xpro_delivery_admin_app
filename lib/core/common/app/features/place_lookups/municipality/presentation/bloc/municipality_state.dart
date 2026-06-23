import 'package:equatable/equatable.dart';
import '../../domain/entity/municipality_entity.dart';

abstract class MunicipalityState extends Equatable {
  const MunicipalityState();

  @override
  List<Object?> get props => [];
}

class MunicipalityInitial extends MunicipalityState {
  const MunicipalityInitial();
}

class MunicipalityLoading extends MunicipalityState {
  const MunicipalityLoading();
}

class MunicipalitiesLoaded extends MunicipalityState {
  final List<MunicipalityEntity> municipalities;
  const MunicipalitiesLoaded(this.municipalities);

  @override
  List<Object?> get props => [municipalities];
}

class MunicipalitiesByProvinceLoaded extends MunicipalityState {
  final List<MunicipalityEntity> municipalities;
  final String provinceId;
  const MunicipalitiesByProvinceLoaded(this.municipalities, this.provinceId);

  @override
  List<Object?> get props => [municipalities, provinceId];
}

class MunicipalityLoaded extends MunicipalityState {
  final MunicipalityEntity municipality;
  const MunicipalityLoaded(this.municipality);

  @override
  List<Object?> get props => [municipality];
}

class MunicipalityCreated extends MunicipalityState {
  final MunicipalityEntity municipality;
  const MunicipalityCreated(this.municipality);

  @override
  List<Object?> get props => [municipality];
}

class MunicipalityUpdated extends MunicipalityState {
  final MunicipalityEntity municipality;
  const MunicipalityUpdated(this.municipality);

  @override
  List<Object?> get props => [municipality];
}

class MunicipalityDeleted extends MunicipalityState {
  final String id;
  const MunicipalityDeleted(this.id);

  @override
  List<Object?> get props => [id];
}

class MunicipalitiesAssignedLoaded extends MunicipalityState {
  final List<MunicipalityEntity> municipalities;
  const MunicipalitiesAssignedLoaded(this.municipalities);

  @override
  List<Object?> get props => [municipalities];
}

class MunicipalityError extends MunicipalityState {
  final String message;
  const MunicipalityError(this.message);

  @override
  List<Object?> get props => [message];
}
