import 'package:desktop_app/core/common/app/features/Delivery_Team/personels/domain/entity/personel_entity.dart';
import 'package:desktop_app/core/common/app/features/Delivery_Team/personels/domain/repo/personal_repo.dart';
import 'package:desktop_app/core/enums/user_role.dart';
import 'package:desktop_app/core/typedefs/typedefs.dart';
import 'package:desktop_app/core/usecases/usecase.dart';
import 'package:equatable/equatable.dart';

class CreatePersonel implements UsecaseWithParams<PersonelEntity, CreatePersonelParams> {
  final PersonelRepo _repo;

  const CreatePersonel(this._repo);

  @override
  ResultFuture<PersonelEntity> call(CreatePersonelParams params) => _repo.createPersonel(
    name: params.name,
    role: params.role,
    deliveryTeamId: params.deliveryTeamId,
    tripId: params.tripId,
  );
}

class CreatePersonelParams extends Equatable {
  final String name;
  final UserRole role;
  final String? deliveryTeamId;
  final String? tripId;

  const CreatePersonelParams({
    required this.name,
    required this.role,
    this.deliveryTeamId,
    this.tripId,
  });

  @override
  List<Object?> get props => [name, role, deliveryTeamId, tripId];
}
