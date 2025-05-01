import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/invoice/domain/entity/invoice_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/invoice/domain/repo/invoice_repo.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';
import 'package:xpro_delivery_admin_app/core/usecases/usecase.dart';

class GetInvoicesByCompletedCustomerId extends UsecaseWithParams<List<InvoiceEntity>, String> {
  final InvoiceRepo _repo;

  const GetInvoicesByCompletedCustomerId(this._repo);

  @override
  ResultFuture<List<InvoiceEntity>> call(String params) async {
    return _repo.getInvoicesByCompletedCustomerId(params);
  }
}
