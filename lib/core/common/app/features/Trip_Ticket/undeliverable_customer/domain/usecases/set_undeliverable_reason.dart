import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/undeliverable_customer/domain/entity/undeliverable_customer_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/undeliverable_customer/domain/repo/undeliverable_repo.dart';
import 'package:xpro_delivery_admin_app/core/enums/undeliverable_reason.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';
import 'package:xpro_delivery_admin_app/core/usecases/usecase.dart';
import 'package:equatable/equatable.dart';

class SetUndeliverableReason extends UsecaseWithParams<UndeliverableCustomerEntity, SetUndeliverableReasonParams> {
  final UndeliverableRepo _repo;

  const SetUndeliverableReason(this._repo);

  @override
  ResultFuture<UndeliverableCustomerEntity> call(SetUndeliverableReasonParams params) {
    return _repo.setUndeliverableReason(params.customerId, params.reason);
  }
}

class SetUndeliverableReasonParams extends Equatable {
  final String customerId;
  final UndeliverableReason reason;

  const SetUndeliverableReasonParams({
    required this.customerId,
    required this.reason,
  });

  @override
  List<Object?> get props => [customerId, reason];
}
