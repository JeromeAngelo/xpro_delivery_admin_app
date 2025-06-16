import 'package:equatable/equatable.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/invoice_items/domain/entity/invoice_items_entity.dart';

abstract class InvoiceItemsState extends Equatable {
  const InvoiceItemsState();

  @override
  List<Object?> get props => [];
}

class InvoiceItemsInitial extends InvoiceItemsState {
  const InvoiceItemsInitial();
}

class InvoiceItemsLoading extends InvoiceItemsState {
  const InvoiceItemsLoading();
}

class InvoiceItemsError extends InvoiceItemsState {
  final String message;
  final String? statusCode;

  const InvoiceItemsError({
    required this.message,
    this.statusCode,
  });

  @override
  List<Object?> get props => [message, statusCode];
}

// State for getting invoice items by invoice data ID
class InvoiceItemsByInvoiceDataIdLoaded extends InvoiceItemsState {
  final List<InvoiceItemsEntity> invoiceItems;
  final String invoiceDataId;

  const InvoiceItemsByInvoiceDataIdLoaded({
    required this.invoiceItems,
    required this.invoiceDataId,
  });

  @override
  List<Object?> get props => [invoiceItems, invoiceDataId];
}

// State for getting all invoice items
class AllInvoiceItemsLoaded extends InvoiceItemsState {
  final List<InvoiceItemsEntity> invoiceItems;

  const AllInvoiceItemsLoaded(this.invoiceItems);

  @override
  List<Object?> get props => [invoiceItems];
}

// State for updating an invoice item by ID
class InvoiceItemUpdated extends InvoiceItemsState {
  final InvoiceItemsEntity invoiceItem;

  const InvoiceItemUpdated(this.invoiceItem);

  @override
  List<Object?> get props => [invoiceItem];
}
