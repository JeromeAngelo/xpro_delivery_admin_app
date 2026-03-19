import '../../../../../../../typedefs/typedefs.dart';
import '../../../../../../../usecases/usecase.dart';
import '../entity/delivery_data_entity.dart';
import '../repo/delivery_data_repo.dart';

class SearchDeliveryData
    extends UsecaseWithParams<List<DeliveryDataEntity>, String> {
  const SearchDeliveryData(this._repo);

  final DeliveryDataRepo _repo;

  @override
  ResultFuture<List<DeliveryDataEntity>> call(String params) {
    return _repo.searchDeliveryData(params);
  }
}