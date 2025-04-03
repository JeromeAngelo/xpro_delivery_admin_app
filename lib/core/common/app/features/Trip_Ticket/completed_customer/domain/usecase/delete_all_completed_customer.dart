import 'package:desktop_app/core/common/app/features/Trip_Ticket/completed_customer/domain/repo/completed_customer_repo.dart';
import 'package:desktop_app/core/typedefs/typedefs.dart';
import 'package:desktop_app/core/usecases/usecase.dart';

class DeleteAllCompletedCustomers extends UsecaseWithParams<bool, List<String>> {
  final CompletedCustomerRepo _repo;
  const DeleteAllCompletedCustomers(this._repo);

  @override
  ResultFuture<bool> call(List<String> params) => 
      _repo.deleteAllCompletedCustomers(params);
}
