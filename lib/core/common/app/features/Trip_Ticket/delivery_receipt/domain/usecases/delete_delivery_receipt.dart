

import '../../../../../../../typedefs/typedefs.dart';
import '../../../../../../../usecases/usecase.dart';
import '../repo/delivery_receipt_repo.dart';

class DeleteDeliveryReceipt extends UsecaseWithParams<bool, String> {
  const DeleteDeliveryReceipt(this._repo);

  final DeliveryReceiptRepo _repo;

  @override
  ResultFuture<bool> call(String receiptId) async {
    return _repo.deleteDeliveryReceipt(receiptId);
  }
}
