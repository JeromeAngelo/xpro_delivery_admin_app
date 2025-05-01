import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/delivery_update/domain/repo/delivery_update_repo.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';
import 'package:xpro_delivery_admin_app/core/usecases/usecase.dart';
import 'package:equatable/equatable.dart';

class UpdateDeliveryStatus implements UsecaseWithParams<void, UpdateDeliveryStatusParams> {
  const UpdateDeliveryStatus(this._repo);

  final DeliveryUpdateRepo _repo;

  @override
  ResultFuture<void> call(UpdateDeliveryStatusParams params) async {
    return _repo.updateDeliveryStatus(params.customerId, params.statusId);
  }
}

class UpdateDeliveryStatusParams extends Equatable {
  const UpdateDeliveryStatusParams({
    required this.customerId,
    required this.statusId,
  });

  final String customerId;
  final String statusId;

  @override
  List<Object?> get props => [customerId, statusId];
}
