import 'package:xpro_delivery_admin_app/core/common/app/features/Delivery_Team/vehicle/domain/repo/vehicle_repo.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';
import 'package:xpro_delivery_admin_app/core/usecases/usecase.dart';

class DeleteVehicle implements UsecaseWithParams<bool, String> {
  final VehicleRepo _repo;

  const DeleteVehicle(this._repo);

  @override
  ResultFuture<bool> call(String vehicleId) => _repo.deleteVehicle(vehicleId);
}
