import '../../../../../../../typedefs/typedefs.dart';
import '../../../../../../../usecases/usecase.dart';
import '../entity/delivery_receipt_entity.dart';
import '../repo/delivery_receipt_repo.dart';

class GetAllDeliveryReceipts
    extends UsecaseWithoutParams<List<DeliveryReceiptEntity>> {
  const GetAllDeliveryReceipts(this._repo);

  final DeliveryReceiptRepo _repo;

  @override
  ResultFuture<List<DeliveryReceiptEntity>> call() =>
      _repo.getAllDeliveryReceipts();
}
