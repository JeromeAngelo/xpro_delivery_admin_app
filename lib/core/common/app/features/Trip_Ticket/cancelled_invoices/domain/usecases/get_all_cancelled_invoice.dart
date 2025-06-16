import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/cancelled_invoices/domain/entity/cancelled_invoice_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/cancelled_invoices/domain/repo/cancelled_invoice_repo.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';
import 'package:xpro_delivery_admin_app/core/usecases/usecase.dart';

class GetAllCancelledInvoices extends UsecaseWithoutParams<List<CancelledInvoiceEntity>> {
  const GetAllCancelledInvoices(this._repo);

  final CancelledInvoiceRepo _repo;

  @override
  ResultFuture<List<CancelledInvoiceEntity>> call() => _repo.getAllCancelledInvoices();
}
