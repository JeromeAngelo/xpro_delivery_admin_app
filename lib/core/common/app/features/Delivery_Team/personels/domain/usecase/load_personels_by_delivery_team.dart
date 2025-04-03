

import 'package:desktop_app/core/common/app/features/Delivery_Team/personels/domain/entity/personel_entity.dart';
import 'package:desktop_app/core/common/app/features/Delivery_Team/personels/domain/repo/personal_repo.dart';
import 'package:desktop_app/core/typedefs/typedefs.dart';
import 'package:desktop_app/core/usecases/usecase.dart';

class LoadPersonelsByDeliveryTeam implements UsecaseWithParams<List<PersonelEntity>, String> {
  final PersonelRepo _repo;

  const LoadPersonelsByDeliveryTeam(this._repo);

  @override
  ResultFuture<List<PersonelEntity>> call(String deliveryTeamId) async {
    return _repo.loadPersonelsByDeliveryTeam(deliveryTeamId);
  }


}
