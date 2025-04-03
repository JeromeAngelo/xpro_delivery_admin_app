
import 'package:desktop_app/core/common/app/features/Trip_Ticket/customer/domain/entity/customer_entity.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/customer/domain/repo/customer_repo.dart';
import 'package:desktop_app/core/typedefs/typedefs.dart';
import 'package:desktop_app/core/usecases/usecase.dart';

class GetCustomersLocation extends UsecaseWithParams<CustomerEntity, String> {
  const GetCustomersLocation(this._repo);
  final CustomerRepo _repo;

  @override
  ResultFuture<CustomerEntity> call(String params) => _repo.getCustomerLocation(params);
}
