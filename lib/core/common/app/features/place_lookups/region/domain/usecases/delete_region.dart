import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';
import 'package:xpro_delivery_admin_app/core/usecases/usecase.dart';
import '../repo/region_repo.dart';

class DeleteRegion extends UsecaseWithParams<bool, String> {
  DeleteRegion(this._repo);
  final RegionRepo _repo;

  @override
  ResultFuture<bool> call(String id) => _repo.deleteRegion(id);
}
