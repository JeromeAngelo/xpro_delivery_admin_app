import 'package:desktop_app/core/common/app/features/Trip_Ticket/completed_customer/domain/entity/completed_customer_entity.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/completed_customer/domain/repo/completed_customer_repo.dart';
import 'package:desktop_app/core/typedefs/typedefs.dart';
import 'package:desktop_app/core/usecases/usecase.dart';

class GetAllCompletedCustomers extends UsecaseWithoutParams<List<CompletedCustomerEntity>> {
  final CompletedCustomerRepo _repo;
  const GetAllCompletedCustomers(this._repo);

  @override
  ResultFuture<List<CompletedCustomerEntity>> call() => 
      _repo.getAllCompletedCustomers();
}
