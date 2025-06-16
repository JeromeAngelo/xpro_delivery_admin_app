

import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/cancelled_invoices/domain/repo/cancelled_invoice_repo.dart' show CancelledInvoiceRepo;

import '../../../../../../../typedefs/typedefs.dart';
import '../../../../../../../usecases/usecase.dart';
import '../entity/cancelled_invoice_entity.dart';

class LoadCancelledInvoiceById extends UsecaseWithParams<CancelledInvoiceEntity, String> {
  const LoadCancelledInvoiceById(this._repo);

  final CancelledInvoiceRepo _repo;

  @override
  ResultFuture<CancelledInvoiceEntity> call(String tripId) => 
      _repo.loadCancelledInvoicesById(tripId);

 
}
