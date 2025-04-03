import 'package:desktop_app/core/common/app/features/Trip_Ticket/undeliverable_customer/domain/entity/undeliverable_customer_entity.dart';
import 'package:equatable/equatable.dart';

abstract class UndeliverableCustomerState extends Equatable {
  const UndeliverableCustomerState();

  @override
  List<Object> get props => [];
}

class UndeliverableCustomerInitial extends UndeliverableCustomerState {}

class UndeliverableCustomerLoading extends UndeliverableCustomerState {}

class UndeliverableCustomerLoaded extends UndeliverableCustomerState {
  final List<UndeliverableCustomerEntity> customers;

  const UndeliverableCustomerLoaded(this.customers);

  @override
  List<Object> get props => [customers];
}

class AllUndeliverableCustomersLoaded extends UndeliverableCustomerState {
  final List<UndeliverableCustomerEntity> customers;

  const AllUndeliverableCustomersLoaded(this.customers);

  @override
  List<Object> get props => [customers];
}

class UndeliverableCustomerByIdLoaded extends UndeliverableCustomerState {
  final UndeliverableCustomerEntity customer;

  const UndeliverableCustomerByIdLoaded(this.customer);

  @override
  List<Object> get props => [customer];
}

class UndeliverableCustomerCreated extends UndeliverableCustomerState {
  final UndeliverableCustomerEntity customer;

  const UndeliverableCustomerCreated(this.customer);

  @override
  List<Object> get props => [customer];
}

class UndeliverableCustomerUpdated extends UndeliverableCustomerState {
  final UndeliverableCustomerEntity customer;

  const UndeliverableCustomerUpdated(this.customer);

  @override
  List<Object> get props => [customer];
}

class UndeliverableCustomerDeleted extends UndeliverableCustomerState {
  final String customerId;

  const UndeliverableCustomerDeleted(this.customerId);

  @override
  List<Object> get props => [customerId];
}

class AllUndeliverableCustomersDeleted extends UndeliverableCustomerState {}

class UndeliverableReasonSet extends UndeliverableCustomerState {
  final UndeliverableCustomerEntity customer;

  const UndeliverableReasonSet(this.customer);

  @override
  List<Object> get props => [customer];
}

class UndeliverableCustomerError extends UndeliverableCustomerState {
  final String message;

  const UndeliverableCustomerError(this.message);

  @override
  List<Object> get props => [message];
}
