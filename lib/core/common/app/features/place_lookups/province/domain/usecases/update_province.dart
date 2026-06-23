import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';
import 'package:xpro_delivery_admin_app/core/usecases/usecase.dart';
import '../entity/province_entity.dart';
import '../repo/province_repo.dart';

class UpdateProvinceParams {
  final String id;
  final String name;
  final String regionId;
  const UpdateProvinceParams({
    required this.id,
    required this.name,
    required this.regionId,
  });
}

class UpdateProvince
    extends UsecaseWithParams<ProvinceEntity, UpdateProvinceParams> {
  UpdateProvince(this._repo);
  final ProvinceRepo _repo;

  @override
  ResultFuture<ProvinceEntity> call(UpdateProvinceParams params) =>
      _repo.updateProvince(
        id: params.id,
        name: params.name,
        regionId: params.regionId,
      );
}
