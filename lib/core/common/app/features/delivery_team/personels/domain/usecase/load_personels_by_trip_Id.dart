

import 'package:xpro_delivery_admin_app/core/common/app/features/delivery_team/personels/domain/entity/personel_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/delivery_team/personels/domain/repo/personal_repo.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';
import 'package:xpro_delivery_admin_app/core/usecases/usecase.dart';

class LoadPersonelsByTripId implements UsecaseWithParams<List<PersonelEntity>, String> {
  final PersonelRepo _repo;

  const LoadPersonelsByTripId(this._repo);

  @override
  ResultFuture<List<PersonelEntity>> call(String tripId) async {
    return _repo.loadPersonelsByTripId(tripId);
  }


}
