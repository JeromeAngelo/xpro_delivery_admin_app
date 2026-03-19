

import '../../../../../../../typedefs/typedefs.dart';
import '../../../../../../../usecases/usecase.dart';
import '../entity/delivery_receipt_entity.dart';
import '../repo/delivery_receipt_repo.dart';

class GetDeliveryReceiptByDeliveryDataId
    extends UsecaseWithParams<DeliveryReceiptEntity, String> {
  const GetDeliveryReceiptByDeliveryDataId(this._repo);

  final DeliveryReceiptRepo _repo;

  @override
  ResultFuture<DeliveryReceiptEntity> call(String deliveryDataId) async {
    return _repo.getDeliveryReceiptByDeliveryDataId(deliveryDataId);
  }
}
