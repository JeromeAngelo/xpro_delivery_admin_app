import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';
import 'package:xpro_delivery_admin_app/core/usecases/usecase.dart';
import '../entity/province_entity.dart';
import '../repo/province_repo.dart';

class GetProvinceById extends UsecaseWithParams<ProvinceEntity, String> {
  GetProvinceById(this._repo);
  final ProvinceRepo _repo;

  @override
  ResultFuture<ProvinceEntity> call(String id) => _repo.getProvinceById(id);
}
