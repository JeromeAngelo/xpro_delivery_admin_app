import 'package:desktop_app/core/common/app/features/Trip_Ticket/undeliverable_customer/domain/entity/undeliverable_customer_entity.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/undeliverable_customer/domain/repo/undeliverable_repo.dart';
import 'package:desktop_app/core/typedefs/typedefs.dart';
import 'package:desktop_app/core/usecases/usecase.dart';

class GetUndeliverableCustomerById extends UsecaseWithParams<UndeliverableCustomerEntity, String> {
  final UndeliverableRepo _repo;

  const GetUndeliverableCustomerById(this._repo);

  @override
  ResultFuture<UndeliverableCustomerEntity> call(String customerId) {
    return _repo.getUndeliverableCustomerById(customerId);
  }
}
