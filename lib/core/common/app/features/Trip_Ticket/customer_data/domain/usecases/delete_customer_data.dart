import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/customer_data/domain/repo/customer_data_repo.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';
import 'package:xpro_delivery_admin_app/core/usecases/usecase.dart';

class DeleteCustomerData extends UsecaseWithParams<bool, String> {
  final CustomerDataRepo _repo;

  const DeleteCustomerData(this._repo);

  @override
  ResultFuture<bool> call(String params) async {
    return _repo.deleteCustomerData(params);
  }
}
