import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';
import 'package:xpro_delivery_admin_app/core/usecases/usecase.dart';
import '../entity/region_entity.dart';
import '../repo/region_repo.dart';

class GetRegionById extends UsecaseWithParams<RegionEntity, String> {
  GetRegionById(this._repo);
  final RegionRepo _repo;

  @override
  ResultFuture<RegionEntity> call(String id) => _repo.getRegionById(id);
}
