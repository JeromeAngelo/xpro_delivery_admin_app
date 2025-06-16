import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/customer_data/domain/entity/customer_data_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/customer_data/domain/repo/customer_data_repo.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';
import 'package:xpro_delivery_admin_app/core/usecases/usecase.dart';

class GetCustomersByDeliveryId extends UsecaseWithParams<List<CustomerDataEntity>, String> {
  final CustomerDataRepo _repo;

  const GetCustomersByDeliveryId(this._repo);

  @override
  ResultFuture<List<CustomerDataEntity>> call(String params) async {
    return _repo.getCustomersByDeliveryId(params);
  }
}
