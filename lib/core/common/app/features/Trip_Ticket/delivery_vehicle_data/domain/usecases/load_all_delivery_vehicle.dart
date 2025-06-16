import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/delivery_vehicle_data/domain/enitity/delivery_vehicle_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/delivery_vehicle_data/domain/repo/delivery_vehicle_repo.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';
import 'package:xpro_delivery_admin_app/core/usecases/usecase.dart';

class LoadAllDeliveryVehicles extends UsecaseWithoutParams<List<DeliveryVehicleEntity>> {
  final DeliveryVehicleRepo _repo;

  const LoadAllDeliveryVehicles(this._repo);

  @override
  ResultFuture<List<DeliveryVehicleEntity>> call() {
    return _repo.loadAllDeliveryVehicles();
  }
}
