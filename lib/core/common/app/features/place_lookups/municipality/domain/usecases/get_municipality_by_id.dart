import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';
import 'package:xpro_delivery_admin_app/core/usecases/usecase.dart';
import '../entity/municipality_entity.dart';
import '../repo/municipality_repo.dart';

class GetMunicipalityById
    extends UsecaseWithParams<MunicipalityEntity, String> {
  GetMunicipalityById(this._repo);
  final MunicipalityRepo _repo;

  @override
  ResultFuture<MunicipalityEntity> call(String id) =>
      _repo.getMunicipalityById(id);
}
