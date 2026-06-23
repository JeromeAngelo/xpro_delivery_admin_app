import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';
import 'package:xpro_delivery_admin_app/core/usecases/usecase.dart';
import '../entity/region_entity.dart';
import '../repo/region_repo.dart';

class GetAllRegions extends UsecaseWithoutParams<List<RegionEntity>> {
  GetAllRegions(this._repo);
  final RegionRepo _repo;

  @override
  ResultFuture<List<RegionEntity>> call() => _repo.getAllRegions();
}
