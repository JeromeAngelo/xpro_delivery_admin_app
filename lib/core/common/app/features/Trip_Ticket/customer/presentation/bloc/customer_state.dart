import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/customer/domain/entity/customer_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/delivery_update/presentation/bloc/delivery_update_state.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/invoice/presentation/bloc/invoice_state.dart';
import 'package:equatable/equatable.dart';

abstract class CustomerState extends Equatable {
  const CustomerState();

  @override
  List<Object> get props => [];
}

// Existing states
class CustomerInitial extends CustomerState {}

class CustomerLoading extends CustomerState {}

class CustomerLocationLoading extends CustomerState {}

class CustomerLocationLoaded extends CustomerState {
  final CustomerEntity customer;
  
  const CustomerLocationLoaded(this.customer);
  
  @override
  List<Object> get props => [customer];
}

class CustomerLoaded extends CustomerState {
  final List<CustomerEntity> customer;
  final InvoiceState invoice;
  final DeliveryUpdateState deliveryUpdate;

  const CustomerLoaded({
    required this.customer,
    required this.invoice,
    required this.deliveryUpdate,
  });

  @override
  List<Object> get props => [customer, invoice, deliveryUpdate];
}

class CustomerError extends CustomerState {
  final String message;
  
  const CustomerError(this.message);
  
  @override
  List<Object> get props => [message];
}

class CustomerTotalTimeCalculated extends CustomerState {
  final String totalTime;
  final String customerId;
  
  const CustomerTotalTimeCalculated({
    required this.totalTime,
    required this.customerId,
  });
  
  @override
  List<Object> get props => [totalTime, customerId];
}

class CustomerRefreshing extends CustomerState {}

// New states
class AllCustomersLoaded extends CustomerState {
  final List<CustomerEntity> customers;
  
  const AllCustomersLoaded(this.customers);
  
  @override
  List<Object> get props => [customers];
}

class CustomerCreated extends CustomerState {
  final CustomerEntity customer;
  
  const CustomerCreated(this.customer);
  
  @override
  List<Object> get props => [customer];
}

class CustomerUpdated extends CustomerState {
  final CustomerEntity customer;
  
  const CustomerUpdated(this.customer);
  
  @override
  List<Object> get props => [customer];
}

class CustomerDeleted extends CustomerState {
  final String id;
  
  const CustomerDeleted(this.id);
  
  @override
  List<Object> get props => [id];
}

class AllCustomersDeleted extends CustomerState {
  final List<String> ids;
  
  const AllCustomersDeleted(this.ids);
  
  @override
  List<Object> get props => [ids];
}
