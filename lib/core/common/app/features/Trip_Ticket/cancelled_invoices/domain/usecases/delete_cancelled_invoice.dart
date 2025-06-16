

import '../../../../../../../typedefs/typedefs.dart';
import '../../../../../../../usecases/usecase.dart';
import '../repo/cancelled_invoice_repo.dart';

class DeleteCancelledInvoice extends UsecaseWithParams<bool, String> {
  const DeleteCancelledInvoice(this._repo);

  final CancelledInvoiceRepo _repo;

  @override
  ResultFuture<bool> call(String cancelledInvoiceId) => 
      _repo.deleteCancelledInvoice(cancelledInvoiceId);
}
