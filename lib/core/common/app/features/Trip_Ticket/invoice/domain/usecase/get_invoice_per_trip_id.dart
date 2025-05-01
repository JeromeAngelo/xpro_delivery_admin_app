
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/invoice/domain/entity/invoice_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/invoice/domain/repo/invoice_repo.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';
import 'package:xpro_delivery_admin_app/core/usecases/usecase.dart';

class GetInvoicesByTrip extends UsecaseWithParams<List<InvoiceEntity>, String> {
  const GetInvoicesByTrip(this._repo);
  final InvoiceRepo _repo;

  @override
  ResultFuture<List<InvoiceEntity>> call(String params) => _repo.getInvoicesByTripId(params);
}
