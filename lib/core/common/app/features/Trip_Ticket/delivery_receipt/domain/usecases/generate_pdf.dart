import 'dart:typed_data';

import '../../../../../../../typedefs/typedefs.dart';
import '../../../../../../../usecases/usecase.dart';
import '../../../delivery_data/domain/entity/delivery_data_entity.dart';
import '../repo/delivery_receipt_repo.dart';


class GenerateDeliveryReceiptPdf extends UsecaseWithParams<Uint8List, DeliveryDataEntity> {
  const GenerateDeliveryReceiptPdf(this._repo);

  final DeliveryReceiptRepo _repo;

  @override
  ResultFuture<Uint8List> call(DeliveryDataEntity params) => 
      _repo.generateDeliveryReceiptPdf(params);
}
