import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/invoice_items/domain/entity/invoice_items_entity.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';

abstract class InvoiceItemsRepo {
  const InvoiceItemsRepo();

  // Get invoice items by invoice data ID
  ResultFuture<List<InvoiceItemsEntity>> getInvoiceItemsByInvoiceDataId(String invoiceDataId);
  
  // Get all invoice items
  ResultFuture<List<InvoiceItemsEntity>> getAllInvoiceItems();
  
  // Update invoice item by ID
  ResultFuture<InvoiceItemsEntity> updateInvoiceItemById(InvoiceItemsEntity invoiceItem);
}
