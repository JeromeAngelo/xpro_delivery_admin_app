import 'package:equatable/equatable.dart';

import '../../../../../../typedefs/typedefs.dart';
import '../../../../../../usecases/usecase.dart';
import '../entity/delivery_status_choices_entity.dart';
import '../repo/delivery_status_choices_repo.dart';

class UpdateCustomerStatus
    implements UsecaseWithParams<void, UpdateDeliveryStatusParams> {
  const UpdateCustomerStatus(this._repo);

  final DeliveryStatusChoicesRepo _repo;

  @override
  ResultFuture<void> call(UpdateDeliveryStatusParams params) {
    return _repo.updateDeliveryStatus(
      params.deliveryDataId,
      params.status,
    );
  }
}

class UpdateDeliveryStatusParams extends Equatable {
  const UpdateDeliveryStatusParams({
    required this.deliveryDataId,
    required this.status,
  });

  final String deliveryDataId;
  final DeliveryStatusChoicesEntity status;

  @override
  List<Object?> get props => [deliveryDataId, status];
}