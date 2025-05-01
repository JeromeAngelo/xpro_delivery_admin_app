import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/customer/domain/repo/customer_repo.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';
import 'package:xpro_delivery_admin_app/core/usecases/usecase.dart';

class DeleteAllCustomers extends UsecaseWithParams<bool, List<String>> {
  final CustomerRepo _repo;
  const DeleteAllCustomers(this._repo);

  @override
  ResultFuture<bool> call(List<String> params) => _repo.deleteAllCustomers(params);
}
