import 'package:desktop_app/core/enums/invoice_status.dart';
import 'package:equatable/equatable.dart';

abstract class InvoiceEvent extends Equatable {
  const InvoiceEvent();
  
  @override
  List<Object?> get props => [];
}

class GetInvoiceEvent extends InvoiceEvent {
  const GetInvoiceEvent();
}

class GetInvoicesByTripEvent extends InvoiceEvent {
  final String tripId;
  const GetInvoicesByTripEvent(this.tripId);
  
  @override
  List<Object?> get props => [tripId];
}

class GetInvoicesByCustomerEvent extends InvoiceEvent {
  final String customerId;
  const GetInvoicesByCustomerEvent(this.customerId);
  
  @override
  List<Object?> get props => [customerId];
}

class CreateInvoiceEvent extends InvoiceEvent {
  final String invoiceNumber;
  final String customerId;
  final String tripId;
  final List<String> productIds;
  final InvoiceStatus? status;
  final double? totalAmount;
  final double? confirmTotalAmount;
  final String? customerDeliveryStatus;

  const CreateInvoiceEvent({
    required this.invoiceNumber,
    required this.customerId,
    required this.tripId,
    required this.productIds,
    this.status,
    this.totalAmount,
    this.confirmTotalAmount,
    this.customerDeliveryStatus,
  });
  
  @override
  List<Object?> get props => [
    invoiceNumber, 
    customerId, 
    tripId, 
    productIds, 
    status, 
    totalAmount, 
    confirmTotalAmount, 
    customerDeliveryStatus
  ];
}

class UpdateInvoiceEvent extends InvoiceEvent {
  final String id;
  final String? invoiceNumber;
  final String? customerId;
  final String? tripId;
  final List<String>? productIds;
  final InvoiceStatus? status;
  final double? totalAmount;
  final double? confirmTotalAmount;
  final String? customerDeliveryStatus;

  const UpdateInvoiceEvent({
    required this.id,
    this.invoiceNumber,
    this.customerId,
    this.tripId,
    this.productIds,
    this.status,
    this.totalAmount,
    this.confirmTotalAmount,
    this.customerDeliveryStatus,
  });
  
  @override
  List<Object?> get props => [
    id, 
    invoiceNumber, 
    customerId, 
    tripId, 
    productIds, 
    status, 
    totalAmount, 
    confirmTotalAmount, 
    customerDeliveryStatus
  ];
}

class GetInvoicesByCompletedCustomerEvent extends InvoiceEvent {
  final String completedCustomerId;
  
  const GetInvoicesByCompletedCustomerEvent(this.completedCustomerId);
  
  @override
  List<Object?> get props => [completedCustomerId];
}

class DeleteInvoiceEvent extends InvoiceEvent {
  final String id;
  
  const DeleteInvoiceEvent(this.id);
  
  @override
  List<Object?> get props => [id];
}

class DeleteAllInvoicesEvent extends InvoiceEvent {
  final List<String> ids;
  
  const DeleteAllInvoicesEvent(this.ids);
  
  @override
  List<Object?> get props => [ids];
}

// Add this to the existing invoice_event.dart file

class GetInvoiceByIdEvent extends InvoiceEvent {
  final String id;
  
  const GetInvoiceByIdEvent(this.id);
  
  @override
  List<Object?> get props => [id];
}


class RefreshInvoiceEvent extends InvoiceEvent {
  const RefreshInvoiceEvent();
}
