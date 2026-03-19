import 'package:equatable/equatable.dart';

import '../../../../../../../typedefs/typedefs.dart';
import '../../../../../../../usecases/usecase.dart';
import '../entity/delivery_receipt_entity.dart';
import '../repo/delivery_receipt_repo.dart';


class CreateDeliveryReceipt extends UsecaseWithParams<DeliveryReceiptEntity, CreateDeliveryReceiptParams> {
  const CreateDeliveryReceipt(this._repo);

  final DeliveryReceiptRepo _repo;

  @override
  ResultFuture<DeliveryReceiptEntity> call(CreateDeliveryReceiptParams params) async {
    return _repo.createDeliveryReceiptByDeliveryDataId(
      deliveryDataId: params.deliveryDataId,
      status: params.status,
      dateTimeCompleted: params.dateTimeCompleted,
      customerImages: params.customerImages,
      customerSignature: params.customerSignature,
      receiptFile: params.receiptFile,
    );
  }
}

class CreateDeliveryReceiptParams extends Equatable {
  final String deliveryDataId;
  final String? status;
  final DateTime? dateTimeCompleted;
  final List<String>? customerImages;
  final String? customerSignature;
  final String? receiptFile;

  const CreateDeliveryReceiptParams({
    required this.deliveryDataId,
    this.status,
    this.dateTimeCompleted,
    this.customerImages,
    this.customerSignature,
    this.receiptFile,
  });

  @override
  List<Object?> get props => [
    deliveryDataId,
    status,
    dateTimeCompleted,
    customerImages,
    customerSignature,
    receiptFile,
  ];

  @override
  String toString() {
    return 'CreateDeliveryReceiptParams(deliveryDataId: $deliveryDataId, status: $status, dateTimeCompleted: $dateTimeCompleted, customerImages: ${customerImages?.length ?? 0}, customerSignature: $customerSignature, receiptFile: $receiptFile)';
  }
}
