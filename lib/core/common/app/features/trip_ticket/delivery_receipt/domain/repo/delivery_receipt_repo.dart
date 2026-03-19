import 'dart:typed_data';



import '../../../../../../../typedefs/typedefs.dart';
import '../../../delivery_data/domain/entity/delivery_data_entity.dart';
import '../entity/delivery_receipt_entity.dart';

abstract class DeliveryReceiptRepo {
  const DeliveryReceiptRepo();

  /// Get delivery receipt by trip ID from remote
  /// 
  /// Takes a trip ID and returns the delivery receipt entity associated with that trip
  ResultFuture<DeliveryReceiptEntity> getDeliveryReceiptByTripId(String tripId);

  /// Load delivery receipt by trip ID from local storage

  ResultFuture<DeliveryReceiptEntity> getDeliveryReceiptByDeliveryDataId(String deliveryDataId);




  /// Create delivery receipt by delivery data ID
  /// 
  /// Takes delivery data ID and receipt data to create a new delivery receipt
  ResultFuture<DeliveryReceiptEntity> createDeliveryReceiptByDeliveryDataId({
    required String deliveryDataId,
    required String? status,
    required DateTime? dateTimeCompleted,
    required List<String>? customerImages,
    required String? customerSignature,
    required String? receiptFile,
  });

  /// Delete delivery receipt by ID
  /// 
  /// Takes a delivery receipt ID and deletes it
  ResultFuture<bool> deleteDeliveryReceipt(String id);

    ResultFuture<Uint8List> generateDeliveryReceiptPdf(DeliveryDataEntity deliveryData);
}
