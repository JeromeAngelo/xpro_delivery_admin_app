import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';
import 'package:xpro_delivery_admin_app/core/usecases/usecase.dart';
import '../entity/province_entity.dart';
import '../repo/province_repo.dart';

class GetAssignedProvincesByVehicleProfileId
    extends UsecaseWithParams<List<ProvinceEntity>, String> {
  GetAssignedProvincesByVehicleProfileId(this._repo);
  final ProvinceRepo _repo;

  @override
  ResultFuture<List<ProvinceEntity>> call(String vehicleProfileId) =>
      _repo.getAssignedProvincesByVehicleProfileId(vehicleProfileId);
}
