


import '../../../../../../../typedefs/typedefs.dart';
import '../entity/cancelled_invoice_entity.dart';

abstract class CancelledInvoiceRepo {
  const CancelledInvoiceRepo();

  /// Load cancelled invoices by trip ID from remote
  ResultFuture<List<CancelledInvoiceEntity>> loadCancelledInvoicesByTripId(String tripId);

  /// Load cancelled invoices by trip ID from local storage

    ResultFuture<CancelledInvoiceEntity> loadCancelledInvoicesById(String id);



 /// Create cancelled invoice
  ResultFuture<CancelledInvoiceEntity> createCancelledInvoice(
    CancelledInvoiceEntity cancelledInvoice,
    String deliveryDataId,
  );


  /// Delete cancelled invoice
  ResultFuture<bool> deleteCancelledInvoice(String cancelledInvoiceId);

  ResultFuture<List<CancelledInvoiceEntity>> getAllCancelledInvoices();
}
