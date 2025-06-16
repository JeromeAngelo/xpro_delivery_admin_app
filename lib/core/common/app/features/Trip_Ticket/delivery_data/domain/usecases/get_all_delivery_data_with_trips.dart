import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/delivery_data/domain/entity/delivery_data_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/delivery_data/domain/repo/delivery_data_repo.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';
import 'package:xpro_delivery_admin_app/core/usecases/usecase.dart';

class GetAllDeliveryDataWithTrips extends UsecaseWithoutParams<List<DeliveryDataEntity>> {
  const GetAllDeliveryDataWithTrips(this._repo);

  final DeliveryDataRepo _repo;

  @override
  ResultFuture<List<DeliveryDataEntity>> call() => _repo.getAllDeliveryDataWithTrips();
}
