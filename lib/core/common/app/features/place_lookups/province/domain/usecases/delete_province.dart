import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';
import 'package:xpro_delivery_admin_app/core/usecases/usecase.dart';
import '../repo/province_repo.dart';

class DeleteProvince extends UsecaseWithParams<bool, String> {
  DeleteProvince(this._repo);
  final ProvinceRepo _repo;

  @override
  ResultFuture<bool> call(String id) => _repo.deleteProvince(id);
}
