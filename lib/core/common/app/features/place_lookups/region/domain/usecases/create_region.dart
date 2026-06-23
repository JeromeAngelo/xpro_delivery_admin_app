import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';
import 'package:xpro_delivery_admin_app/core/usecases/usecase.dart';
import '../entity/region_entity.dart';
import '../repo/region_repo.dart';

class CreateRegionParams {
  final String name;
  final String? alias;
  const CreateRegionParams({required this.name, this.alias});
}

class CreateRegion extends UsecaseWithParams<RegionEntity, CreateRegionParams> {
  CreateRegion(this._repo);
  final RegionRepo _repo;

  @override
  ResultFuture<RegionEntity> call(CreateRegionParams params) =>
      _repo.createRegion(name: params.name, alias: params.alias);
}
