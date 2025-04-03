import 'package:desktop_app/core/common/app/features/Trip_Ticket/undeliverable_customer/domain/entity/undeliverable_customer_entity.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/undeliverable_customer/domain/repo/undeliverable_repo.dart';
import 'package:desktop_app/core/typedefs/typedefs.dart';
import 'package:desktop_app/core/usecases/usecase.dart';

class GetAllUndeliverableCustomers extends UsecaseWithoutParams<List<UndeliverableCustomerEntity>> {
  final UndeliverableRepo _repo;

  const GetAllUndeliverableCustomers(this._repo);

  @override
  ResultFuture<List<UndeliverableCustomerEntity>> call() {
    return _repo.getAllUndeliverableCustomers();
  }
}
