import 'package:equatable/equatable.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/invoice_items/domain/entity/invoice_items_entity.dart';

abstract class InvoiceItemsEvent extends Equatable {
  const InvoiceItemsEvent();

  @override
  List<Object?> get props => [];
}

// Event for getting invoice items by invoice data ID
class GetInvoiceItemsByInvoiceDataIdEvent extends InvoiceItemsEvent {
  final String invoiceDataId;

  const GetInvoiceItemsByInvoiceDataIdEvent(this.invoiceDataId);

  @override
  List<Object?> get props => [invoiceDataId];
}

// Event for getting all invoice items
class GetAllInvoiceItemsEvent extends InvoiceItemsEvent {
  const GetAllInvoiceItemsEvent();
}

// Event for updating an invoice item by ID
class UpdateInvoiceItemByIdEvent extends InvoiceItemsEvent {
  final InvoiceItemsEntity invoiceItem;

  const UpdateInvoiceItemByIdEvent(this.invoiceItem);

  @override
  List<Object?> get props => [invoiceItem];
}
