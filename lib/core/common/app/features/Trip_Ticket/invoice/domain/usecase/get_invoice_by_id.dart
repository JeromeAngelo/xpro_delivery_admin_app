import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/invoice/domain/entity/invoice_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/invoice/domain/repo/invoice_repo.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';
import 'package:xpro_delivery_admin_app/core/usecases/usecase.dart';

class GetInvoiceById implements UsecaseWithParams<InvoiceEntity, String> {
  final InvoiceRepo _repo;

  const GetInvoiceById(this._repo);

  @override
  ResultFuture<InvoiceEntity> call(String params) async {
    return await _repo.getInvoiceById(params);
  }
}
