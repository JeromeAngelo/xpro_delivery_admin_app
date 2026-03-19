import '../../../../../../../typedefs/typedefs.dart';
import '../../../../../../../usecases/usecase.dart';
import '../entity/customer_data_entity.dart';
import '../repo/customer_data_repo.dart';


class GetAllUnassignedCustomerData extends UsecaseWithoutParams<List<CustomerDataEntity>> {
  const GetAllUnassignedCustomerData(this._repository);

  final CustomerDataRepo _repository;

  @override
  ResultFuture<List<CustomerDataEntity>> call() async {
    return _repository.getAllUnassignedCustomerData();
  }
}
