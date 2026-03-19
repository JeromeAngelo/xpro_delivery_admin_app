

import '../../../../../../../typedefs/typedefs.dart';
import '../../../../../../../usecases/usecase.dart';
import '../entity/cancelled_invoice_entity.dart';
import '../repo/cancelled_invoice_repo.dart';

class LoadCancelledInvoicesByTripId extends UsecaseWithParams<List<CancelledInvoiceEntity>, String> {
  const LoadCancelledInvoicesByTripId(this._repo);

  final CancelledInvoiceRepo _repo;

  @override
  ResultFuture<List<CancelledInvoiceEntity>> call(String tripId) => 
      _repo.loadCancelledInvoicesByTripId(tripId);

}
