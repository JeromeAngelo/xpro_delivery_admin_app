import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';
import 'package:xpro_delivery_admin_app/core/usecases/usecase.dart';
import '../repo/municipality_repo.dart';

class DeleteMunicipality extends UsecaseWithParams<bool, String> {
  DeleteMunicipality(this._repo);
  final MunicipalityRepo _repo;

  @override
  ResultFuture<bool> call(String id) => _repo.deleteMunicipality(id);
}
