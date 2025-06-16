import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/customer_data/domain/entity/customer_data_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/customer_data/domain/repo/customer_data_repo.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';
import 'package:xpro_delivery_admin_app/core/usecases/usecase.dart';

class GetAllCustomerData extends UsecaseWithoutParams<List<CustomerDataEntity>> {
  final CustomerDataRepo _repo;

  const GetAllCustomerData(this._repo);

  @override
  ResultFuture<List<CustomerDataEntity>> call() async {
    return _repo.getAllCustomerData();
  }
}
