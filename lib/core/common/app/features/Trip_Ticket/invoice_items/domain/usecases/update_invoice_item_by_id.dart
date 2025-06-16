import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/invoice_items/domain/entity/invoice_items_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/invoice_items/domain/repo/invoice_items_repo.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';
import 'package:xpro_delivery_admin_app/core/usecases/usecase.dart';

class UpdateInvoiceItemById extends UsecaseWithParams<InvoiceItemsEntity, InvoiceItemsEntity> {
  const UpdateInvoiceItemById(this._repo);

  final InvoiceItemsRepo _repo;

  @override
  ResultFuture<InvoiceItemsEntity> call(InvoiceItemsEntity params) async {
    return _repo.updateInvoiceItemById(params);
  }
}
