import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/completed_customer/domain/repo/completed_customer_repo.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';
import 'package:xpro_delivery_admin_app/core/usecases/usecase.dart';

class DeleteCompletedCustomer extends UsecaseWithParams<bool, String> {
  final CompletedCustomerRepo _repo;
  const DeleteCompletedCustomer(this._repo);

  @override
  ResultFuture<bool> call(String params) => 
      _repo.deleteCompletedCustomer(params);
}
