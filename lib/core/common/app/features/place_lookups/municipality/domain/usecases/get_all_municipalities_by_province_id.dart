import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';
import 'package:xpro_delivery_admin_app/core/usecases/usecase.dart';
import '../entity/municipality_entity.dart';
import '../repo/municipality_repo.dart';

class GetAllMunicipalitiesByProvinceId
    extends UsecaseWithParams<List<MunicipalityEntity>, String> {
  GetAllMunicipalitiesByProvinceId(this._repo);
  final MunicipalityRepo _repo;

  @override
  ResultFuture<List<MunicipalityEntity>> call(String provinceId) =>
      _repo.getAllMunicipalitiesByProvinceId(provinceId);
}
