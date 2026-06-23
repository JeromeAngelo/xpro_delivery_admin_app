import 'package:xpro_delivery_admin_app/core/common/app/features/trip_ticket/delivery_vehicle_data/domain/enitity/delivery_vehicle_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/trip_ticket/delivery_vehicle_data/domain/repo/delivery_vehicle_repo.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';
import 'package:xpro_delivery_admin_app/core/usecases/usecase.dart';

/// Parameter object for [UpdateDeliveryVehicle].
class UpdateDeliveryVehicleParams {
  final String id;
  final DeliveryVehicleEntity vehicle;

  const UpdateDeliveryVehicleParams({required this.id, required this.vehicle});
}

class UpdateDeliveryVehicle
    extends
        UsecaseWithParams<DeliveryVehicleEntity, UpdateDeliveryVehicleParams> {
  final DeliveryVehicleRepo _repo;

  const UpdateDeliveryVehicle(this._repo);

  @override
  ResultFuture<DeliveryVehicleEntity> call(UpdateDeliveryVehicleParams params) {
    return _repo.updateDeliveryVehicle(params.id, params.vehicle);
  }
}
