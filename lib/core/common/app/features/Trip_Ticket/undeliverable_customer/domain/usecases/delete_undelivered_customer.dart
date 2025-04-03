import 'package:desktop_app/core/common/app/features/Trip_Ticket/undeliverable_customer/domain/repo/undeliverable_repo.dart';
import 'package:desktop_app/core/typedefs/typedefs.dart';
import 'package:desktop_app/core/usecases/usecase.dart';

class DeleteUndeliverableCustomer extends UsecaseWithParams<bool, String> {
  final UndeliverableRepo _repo;

  const DeleteUndeliverableCustomer(this._repo);

  @override
  ResultFuture<bool> call(String undeliverableCustomerId) {
    return _repo.deleteUndeliverableCustomer(undeliverableCustomerId);
  }
}
