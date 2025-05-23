import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/customer/domain/repo/customer_repo.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';
import 'package:xpro_delivery_admin_app/core/usecases/usecase.dart';

class DeleteCustomer extends UsecaseWithParams<bool, String> {
  final CustomerRepo _repo;
  const DeleteCustomer(this._repo);

  @override
  ResultFuture<bool> call(String params) => _repo.deleteCustomer(params);
}
