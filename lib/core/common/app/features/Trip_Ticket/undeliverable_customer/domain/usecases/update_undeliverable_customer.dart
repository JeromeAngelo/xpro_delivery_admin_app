import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/undeliverable_customer/domain/entity/undeliverable_customer_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/undeliverable_customer/domain/repo/undeliverable_repo.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';
import 'package:xpro_delivery_admin_app/core/usecases/usecase.dart';
import 'package:equatable/equatable.dart';

class UpdateUndeliverableCustomer extends UsecaseWithParams<UndeliverableCustomerEntity, UpdateUndeliverableCustomerParams> {
  final UndeliverableRepo _repo;

  const UpdateUndeliverableCustomer(this._repo);

  @override
  ResultFuture<UndeliverableCustomerEntity> call(UpdateUndeliverableCustomerParams params) {
    return _repo.updateUndeliverableCustomer(params.undeliverableCustomer, params.customerId);
  }
}

class UpdateUndeliverableCustomerParams extends Equatable {
  final UndeliverableCustomerEntity undeliverableCustomer;
  final String customerId;

  const UpdateUndeliverableCustomerParams({
    required this.undeliverableCustomer,
    required this.customerId,
  });

  @override
  List<Object?> get props => [undeliverableCustomer, customerId];
}
