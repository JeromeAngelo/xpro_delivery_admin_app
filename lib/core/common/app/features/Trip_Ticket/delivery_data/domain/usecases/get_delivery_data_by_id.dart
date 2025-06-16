import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/delivery_data/domain/entity/delivery_data_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/delivery_data/domain/repo/delivery_data_repo.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';
import 'package:xpro_delivery_admin_app/core/usecases/usecase.dart';

class GetDeliveryDataById extends UsecaseWithParams<DeliveryDataEntity, String> {
  const GetDeliveryDataById(this._repo);

  final DeliveryDataRepo _repo;

  @override
  ResultFuture<DeliveryDataEntity> call(String params) async {
    return _repo.getDeliveryDataById(params);
  }
}
