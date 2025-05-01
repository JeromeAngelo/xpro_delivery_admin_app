
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/customer/domain/entity/customer_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/customer/domain/repo/customer_repo.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';
import 'package:xpro_delivery_admin_app/core/usecases/usecase.dart';

class GetCustomersLocation extends UsecaseWithParams<CustomerEntity, String> {
  const GetCustomersLocation(this._repo);
  final CustomerRepo _repo;

  @override
  ResultFuture<CustomerEntity> call(String params) => _repo.getCustomerLocation(params);
}
