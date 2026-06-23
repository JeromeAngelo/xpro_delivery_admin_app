import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';
import 'package:xpro_delivery_admin_app/core/usecases/usecase.dart';
import '../entity/region_entity.dart';
import '../repo/region_repo.dart';

class UpdateRegionParams {
  final String id;
  final String name;
  final String? alias;
  const UpdateRegionParams({required this.id, required this.name, this.alias});
}

class UpdateRegion extends UsecaseWithParams<RegionEntity, UpdateRegionParams> {
  UpdateRegion(this._repo);
  final RegionRepo _repo;

  @override
  ResultFuture<RegionEntity> call(UpdateRegionParams params) =>
      _repo.updateRegion(id: params.id, name: params.name, alias: params.alias);
}
