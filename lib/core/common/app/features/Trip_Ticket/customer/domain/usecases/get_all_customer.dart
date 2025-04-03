import 'package:desktop_app/core/common/app/features/Trip_Ticket/customer/domain/entity/customer_entity.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/customer/domain/repo/customer_repo.dart';
import 'package:desktop_app/core/typedefs/typedefs.dart';
import 'package:desktop_app/core/usecases/usecase.dart';

class GetAllCustomers extends UsecaseWithoutParams<List<CustomerEntity>> {
  final CustomerRepo _repo;
  const GetAllCustomers(this._repo);

  @override
  ResultFuture<List<CustomerEntity>> call() => _repo.getAllCustomers();
}
