
import 'package:desktop_app/core/common/app/features/Delivery_Team/vehicle/domain/entity/vehicle_entity.dart';
import 'package:desktop_app/core/common/app/features/Delivery_Team/vehicle/domain/repo/vehicle_repo.dart';
import 'package:desktop_app/core/typedefs/typedefs.dart';
import 'package:desktop_app/core/usecases/usecase.dart';

class GetVehicle extends UsecaseWithoutParams<List<VehicleEntity>> {
  const GetVehicle(this._repo);

  final VehicleRepo _repo;

  @override
  ResultFuture<List<VehicleEntity>> call() => _repo.getVehicles();
}