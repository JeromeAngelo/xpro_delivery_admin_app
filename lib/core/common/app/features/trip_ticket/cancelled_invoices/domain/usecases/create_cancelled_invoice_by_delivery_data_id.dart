import 'package:equatable/equatable.dart';

import '../../../../../../../enums/undeliverable_reason.dart';
import '../../../../../../../typedefs/typedefs.dart';
import '../../../../../../../usecases/usecase.dart';
import '../entity/cancelled_invoice_entity.dart';
import '../repo/cancelled_invoice_repo.dart';


class CreateCancelledInvoiceByDeliveryDataId extends UsecaseWithParams<CancelledInvoiceEntity, CreateCancelledInvoiceParams> {
  const CreateCancelledInvoiceByDeliveryDataId(this._repo);

  final CancelledInvoiceRepo _repo;

  @override
  ResultFuture<CancelledInvoiceEntity> call(CreateCancelledInvoiceParams params) {
    // Create the cancelled invoice entity
    final cancelledInvoice = CancelledInvoiceEntity(
      reason: params.reason,
      image: params.image,
      created: DateTime.now(),
      updated: DateTime.now(),
    );

    return _repo.createCancelledInvoice(
      cancelledInvoice,
      params.deliveryDataId,
    );
  }
}

class CreateCancelledInvoiceParams extends Equatable {
  final String deliveryDataId;
  final UndeliverableReason reason;
  final String? image;

  const CreateCancelledInvoiceParams({
    required this.deliveryDataId,
    required this.reason,
    this.image,
  });

  @override
  List<Object?> get props => [deliveryDataId, reason, image];
}
