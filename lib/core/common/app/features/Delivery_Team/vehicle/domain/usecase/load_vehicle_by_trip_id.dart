

import 'package:xpro_delivery_admin_app/core/common/app/features/Delivery_Team/vehicle/domain/entity/vehicle_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Delivery_Team/vehicle/domain/repo/vehicle_repo.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';
import 'package:xpro_delivery_admin_app/core/usecases/usecase.dart';

class LoadVehicleByTripId implements UsecaseWithParams<VehicleEntity, String> {
  final VehicleRepo _repo;

  const LoadVehicleByTripId(this._repo);

  @override
  ResultFuture<VehicleEntity> call(String tripId) async {
    return _repo.loadVehicleByTripId(tripId);
  }


}
