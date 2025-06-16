import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/customer_data/domain/repo/customer_data_repo.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';
import 'package:xpro_delivery_admin_app/core/usecases/usecase.dart';

class DeleteAllCustomerData extends UsecaseWithParams<bool, List<String>> {
  final CustomerDataRepo _repo;

  const DeleteAllCustomerData(this._repo);

  @override
  ResultFuture<bool> call(List<String> params) async {
    return _repo.deleteAllCustomerData(params);
  }
}
