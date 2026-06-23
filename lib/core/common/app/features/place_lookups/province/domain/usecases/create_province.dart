import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';
import 'package:xpro_delivery_admin_app/core/usecases/usecase.dart';
import '../entity/province_entity.dart';
import '../repo/province_repo.dart';

class CreateProvinceParams {
  final String name;
  final String regionId;
  const CreateProvinceParams({required this.name, required this.regionId});
}

class CreateProvince
    extends UsecaseWithParams<ProvinceEntity, CreateProvinceParams> {
  CreateProvince(this._repo);
  final ProvinceRepo _repo;

  @override
  ResultFuture<ProvinceEntity> call(CreateProvinceParams params) =>
      _repo.createProvince(name: params.name, regionId: params.regionId);
}
