
import 'package:desktop_app/core/common/app/features/Delivery_Team/vehicle/domain/entity/vehicle_entity.dart';
import 'package:desktop_app/core/common/app/features/Delivery_Team/vehicle/domain/repo/vehicle_repo.dart';
import 'package:desktop_app/core/typedefs/typedefs.dart';
import 'package:desktop_app/core/usecases/usecase.dart';

class LoadVehicleByDeliveryTeam implements UsecaseWithParams<VehicleEntity, String> {
  final VehicleRepo _repo;

  const LoadVehicleByDeliveryTeam(this._repo);

  @override
  ResultFuture<VehicleEntity> call(String deliveryTeamId) async {
    return _repo.loadVehicleByDeliveryTeam(deliveryTeamId);
  }

  
}
