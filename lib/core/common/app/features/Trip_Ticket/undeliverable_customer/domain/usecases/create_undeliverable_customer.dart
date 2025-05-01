

import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/undeliverable_customer/domain/entity/undeliverable_customer_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/undeliverable_customer/domain/repo/undeliverable_repo.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';
import 'package:xpro_delivery_admin_app/core/usecases/usecase.dart';

class CreateUndeliverableCustomerParams {
  final UndeliverableCustomerEntity undeliverableCustomer;
  final String customerId;

  const CreateUndeliverableCustomerParams({
    required this.undeliverableCustomer,
    required this.customerId,
  });
}

class CreateUndeliverableCustomer extends UsecaseWithParams<UndeliverableCustomerEntity, CreateUndeliverableCustomerParams> {
  const CreateUndeliverableCustomer(this._repo);

  final UndeliverableRepo _repo;

  @override
  ResultFuture<UndeliverableCustomerEntity> call(CreateUndeliverableCustomerParams params) async {
    return _repo.createUndeliverableCustomer(params.undeliverableCustomer, params.customerId);
  }
}
