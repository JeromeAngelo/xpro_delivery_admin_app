import 'package:desktop_app/core/common/app/features/Delivery_Team/personels/domain/entity/personel_entity.dart';
import 'package:desktop_app/core/common/app/features/Delivery_Team/personels/domain/repo/personal_repo.dart';
import 'package:desktop_app/core/enums/user_role.dart';
import 'package:desktop_app/core/typedefs/typedefs.dart';
import 'package:desktop_app/core/usecases/usecase.dart';
import 'package:equatable/equatable.dart';

class UpdatePersonel implements UsecaseWithParams<PersonelEntity, UpdatePersonelParams> {
  final PersonelRepo _repo;

  const UpdatePersonel(this._repo);

  @override
  ResultFuture<PersonelEntity> call(UpdatePersonelParams params) => _repo.updatePersonel(
    personelId: params.personelId,
    name: params.name,
    role: params.role,
    deliveryTeamId: params.deliveryTeamId,
    tripId: params.tripId,
  );
}

class UpdatePersonelParams extends Equatable {
  final String personelId;
  final String? name;
  final UserRole? role;
  final String? deliveryTeamId;
  final String? tripId;

  const UpdatePersonelParams({
    required this.personelId,
    this.name,
    this.role,
    this.deliveryTeamId,
    this.tripId,
  });

  @override
  List<Object?> get props => [personelId, name, role, deliveryTeamId, tripId];
}
