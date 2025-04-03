

import 'package:desktop_app/core/common/app/features/Delivery_Team/personels/domain/entity/personel_entity.dart';
import 'package:desktop_app/core/common/app/features/Delivery_Team/personels/domain/repo/personal_repo.dart';
import 'package:desktop_app/core/typedefs/typedefs.dart';
import 'package:desktop_app/core/usecases/usecase.dart';

class GetPersonels implements UsecaseWithoutParams<List<PersonelEntity>> {
  const GetPersonels(this._repo);
  final PersonelRepo _repo;

  @override
  ResultFuture<List<PersonelEntity>> call() => _repo.getPersonels();
}
