
import 'package:desktop_app/core/common/app/features/Trip_Ticket/delivery_update/domain/repo/delivery_update_repo.dart';
import 'package:desktop_app/core/typedefs/typedefs.dart';
import 'package:desktop_app/core/usecases/usecase.dart';
import 'package:equatable/equatable.dart';

class UpdateQueueRemarks extends UsecaseWithParams<void, UpdateQueueRemarksParams> {
  const UpdateQueueRemarks(this._repo);

  final DeliveryUpdateRepo _repo;

  @override
  ResultFuture<void> call(UpdateQueueRemarksParams params) => 
    _repo.updateQueueRemarks(
      params.customerId,
      params.queueCount,
    );
}

class UpdateQueueRemarksParams extends Equatable {
  final String customerId;
  final String queueCount;

  const UpdateQueueRemarksParams({
    required this.customerId,
    required this.queueCount,
  });

  @override
  List<Object?> get props => [customerId,  queueCount];
}
