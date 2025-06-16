import '../../../../../../../typedefs/typedefs.dart';
import '../../../../../../../usecases/usecase.dart';
import '../entity/delivery_receipt_entity.dart';
import '../repo/delivery_receipt_repo.dart';

class GetDeliveryReceiptByTripId
    extends UsecaseWithParams<DeliveryReceiptEntity, String> {
  const GetDeliveryReceiptByTripId(this._repo);

  final DeliveryReceiptRepo _repo;

  @override
  ResultFuture<DeliveryReceiptEntity> call(String tripId) async {
    return _repo.getDeliveryReceiptByTripId(tripId);
  }
}
