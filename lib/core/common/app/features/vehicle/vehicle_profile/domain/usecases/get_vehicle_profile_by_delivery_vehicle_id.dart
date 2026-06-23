import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';
import '../../../../../../../usecases/usecase.dart';
import '../entity/vehicle_profile_entity.dart';
import '../repo/vehicle_profile_repo.dart';

/// Fetches the [VehicleProfileEntity] that is associated with the given
/// `deliveryVehicleData` record id (the relation field on the
/// `vehicleProfile` PocketBase collection).
class GetVehicleProfileByDeliveryVehicleId
    extends UsecaseWithParams<VehicleProfileEntity, String> {
  final VehicleProfileRepo repository;

  const GetVehicleProfileByDeliveryVehicleId(this.repository);

  @override
  ResultFuture<VehicleProfileEntity> call(String deliveryVehicleDataId) {
    return repository.getVehicleProfileByDeliveryVehicleId(
      deliveryVehicleDataId,
    );
  }
}
