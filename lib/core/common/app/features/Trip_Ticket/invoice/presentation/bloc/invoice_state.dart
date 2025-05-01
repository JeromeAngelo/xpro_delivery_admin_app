import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/invoice/domain/entity/invoice_entity.dart';
import 'package:equatable/equatable.dart';

abstract class InvoiceState extends Equatable {
  const InvoiceState();

  @override
  List<Object?> get props => [];
}

class InvoiceInitial extends InvoiceState {}

class InvoiceLoading extends InvoiceState {}

class InvoiceLoaded extends InvoiceState {
  final List<InvoiceEntity> invoices;
  final String? tripId;
  final String? customerId;

  const InvoiceLoaded(
    this.invoices, {
    this.tripId,
    this.customerId,
  });

  @override
  List<Object?> get props => [invoices, tripId, customerId];
}

class InvoiceError extends InvoiceState {
  final String message;

  const InvoiceError(this.message);

  @override
  List<Object?> get props => [message];
}

class InvoiceRefreshing extends InvoiceState {}

class TripInvoicesLoaded extends InvoiceState {
  final List<InvoiceEntity> invoices;
  final String tripId;

  const TripInvoicesLoaded(
    this.invoices,
    this.tripId,
  );

  @override
  List<Object?> get props => [invoices, tripId];
}
// Add this to the existing invoice_state.dart file

class SingleInvoiceLoaded extends InvoiceState {
  final InvoiceEntity invoice;
  
  const SingleInvoiceLoaded(this.invoice);
  
  @override
  List<Object?> get props => [invoice];
}


class CustomerInvoicesLoaded extends InvoiceState {
  final List<InvoiceEntity> invoices;
  final String customerId;

  const CustomerInvoicesLoaded(
    this.invoices,
    this.customerId,
  );

  @override
  List<Object?> get props => [invoices, customerId];
}

class InvoiceCreated extends InvoiceState {
  final InvoiceEntity invoice;

  const InvoiceCreated(this.invoice);

  @override
  List<Object?> get props => [invoice];
}

class InvoiceUpdated extends InvoiceState {
  final InvoiceEntity invoice;

  const InvoiceUpdated(this.invoice);

  @override
  List<Object?> get props => [invoice];
}

class InvoiceDeleted extends InvoiceState {
  final String id;

  const InvoiceDeleted(this.id);

  @override
  List<Object?> get props => [id];
}

class CompletedCustomerInvoicesLoaded extends InvoiceState {
  final List<InvoiceEntity> invoices;
  final String completedCustomerId;

  const CompletedCustomerInvoicesLoaded(
    this.invoices,
    this.completedCustomerId,
  );

  @override
  List<Object?> get props => [invoices, completedCustomerId];
}

class AllInvoicesLoaded extends InvoiceState {
  final List<InvoiceEntity> invoices;

  const AllInvoicesLoaded(this.invoices);

  @override
  List<Object?> get props => [invoices];
}


class InvoicesDeleted extends InvoiceState {
  final List<String> ids;

  const InvoicesDeleted(this.ids);

  @override
  List<Object?> get props => [ids];
}
