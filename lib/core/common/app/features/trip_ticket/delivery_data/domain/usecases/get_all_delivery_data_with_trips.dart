import 'package:xpro_delivery_admin_app/core/common/app/features/trip_ticket/delivery_data/domain/entity/delivery_data_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/trip_ticket/delivery_data/domain/repo/delivery_data_repo.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';
import 'package:xpro_delivery_admin_app/core/usecases/usecase.dart';

class GetAllDeliveryDataWithTripsParams {
  final DateTime? startDate;
  final DateTime? endDate;

  const GetAllDeliveryDataWithTripsParams({this.startDate, this.endDate});
}

class GetAllDeliveryDataWithTrips
    extends
        UsecaseWithParams<
          List<DeliveryDataEntity>,
          GetAllDeliveryDataWithTripsParams
        > {
  const GetAllDeliveryDataWithTrips(this._repo);

  final DeliveryDataRepo _repo;

  @override
  ResultFuture<List<DeliveryDataEntity>> call(
    GetAllDeliveryDataWithTripsParams params,
  ) => _repo.getAllDeliveryDataWithTrips(
    startDate: params.startDate,
    endDate: params.endDate,
  );
}
