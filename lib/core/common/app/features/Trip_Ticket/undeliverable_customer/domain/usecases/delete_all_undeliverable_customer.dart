import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/undeliverable_customer/domain/repo/undeliverable_repo.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';
import 'package:xpro_delivery_admin_app/core/usecases/usecase.dart';

class DeleteAllUndeliverableCustomers extends UsecaseWithoutParams<bool> {
  final UndeliverableRepo _repo;

  const DeleteAllUndeliverableCustomers(this._repo);

  @override
  ResultFuture<bool> call() {
    return _repo.deleteAllUndeliverableCustomers();
  }
}
