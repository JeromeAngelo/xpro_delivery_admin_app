

import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/undeliverable_customer/domain/entity/undeliverable_customer_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/undeliverable_customer/domain/repo/undeliverable_repo.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';
import 'package:xpro_delivery_admin_app/core/usecases/usecase.dart';

class GetUndeliverableCustomerById extends UsecaseWithParams<UndeliverableCustomerEntity, String> {
  const GetUndeliverableCustomerById(this._repo);

  final UndeliverableRepo _repo;

  @override
  ResultFuture<UndeliverableCustomerEntity> call(String params) {
    return _repo.getUndeliverableCustomerById(params);
  }
}
