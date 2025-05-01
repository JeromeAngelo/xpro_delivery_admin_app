import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/completed_customer/domain/entity/completed_customer_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/invoice/presentation/bloc/invoice_state.dart';
import 'package:equatable/equatable.dart';

abstract class CompletedCustomerState extends Equatable {
  const CompletedCustomerState();

  @override
  List<Object> get props => [];
}

class CompletedCustomerInitial extends CompletedCustomerState {
  const CompletedCustomerInitial();
}

class CompletedCustomerLoading extends CompletedCustomerState {
  const CompletedCustomerLoading();
}

class CompletedCustomerLoaded extends CompletedCustomerState {
  final List<CompletedCustomerEntity> customers;
  final InvoiceState invoice;
  
  const CompletedCustomerLoaded({
    required this.customers,
    required this.invoice,
  });
  
  @override
  List<Object> get props => [customers, invoice];
}

class CompletedCustomerByIdLoaded extends CompletedCustomerState {
  final CompletedCustomerEntity customer;
  
  const CompletedCustomerByIdLoaded(this.customer);
  
  @override
  List<Object> get props => [customer];
}

// New states
class AllCompletedCustomersLoaded extends CompletedCustomerState {
  final List<CompletedCustomerEntity> customers;
  
  const AllCompletedCustomersLoaded(this.customers);
  
  @override
  List<Object> get props => [customers];
}

class CompletedCustomerCreated extends CompletedCustomerState {
  final CompletedCustomerEntity customer;
  
  const CompletedCustomerCreated(this.customer);
  
  @override
  List<Object> get props => [customer];
}

class CompletedCustomerUpdated extends CompletedCustomerState {
  final CompletedCustomerEntity customer;
  
  const CompletedCustomerUpdated(this.customer);
  
  @override
  List<Object> get props => [customer];
}

class CompletedCustomerDeleted extends CompletedCustomerState {
  final String id;
  
  const CompletedCustomerDeleted(this.id);
  
  @override
  List<Object> get props => [id];
}

class AllCompletedCustomersDeleted extends CompletedCustomerState {
  final List<String> ids;
  
  const AllCompletedCustomersDeleted(this.ids);
  
  @override
  List<Object> get props => [ids];
}

class CompletedCustomerError extends CompletedCustomerState {
  final String message;
  
  const CompletedCustomerError(this.message);
  
  @override
  List<Object> get props => [message];
}
