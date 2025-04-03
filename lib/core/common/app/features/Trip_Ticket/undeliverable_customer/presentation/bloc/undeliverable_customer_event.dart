import 'package:desktop_app/core/common/app/features/Trip_Ticket/undeliverable_customer/domain/entity/undeliverable_customer_entity.dart';
import 'package:desktop_app/core/enums/undeliverable_reason.dart';
import 'package:equatable/equatable.dart';

abstract class UndeliverableCustomerEvent extends Equatable {
  const UndeliverableCustomerEvent();
}

class GetUndeliverableCustomersEvent extends UndeliverableCustomerEvent {
  final String tripId;
  const GetUndeliverableCustomersEvent(this.tripId);

  @override
  List<Object?> get props => [tripId];
}

class GetUndeliverableCustomerByIdEvent extends UndeliverableCustomerEvent {
  final String customerId;
  const GetUndeliverableCustomerByIdEvent(this.customerId);

  @override
  List<Object?> get props => [customerId];
}

class GetAllUndeliverableCustomersEvent extends UndeliverableCustomerEvent {
  const GetAllUndeliverableCustomersEvent();

  @override
  List<Object?> get props => [];
}

class CreateUndeliverableCustomerEvent extends UndeliverableCustomerEvent {
  final UndeliverableCustomerEntity customer;
  final String customerId;

  const CreateUndeliverableCustomerEvent(this.customer, this.customerId);

  @override
  List<Object?> get props => [customer, customerId];
}

class UpdateUndeliverableCustomerEvent extends UndeliverableCustomerEvent {
  final UndeliverableCustomerEntity customer;
  final String customerId;

  const UpdateUndeliverableCustomerEvent(this.customer, this.customerId);

  @override
  List<Object?> get props => [customer, customerId];
}

class DeleteUndeliverableCustomerEvent extends UndeliverableCustomerEvent {
  final String customerId;

  const DeleteUndeliverableCustomerEvent(this.customerId);

  @override
  List<Object?> get props => [customerId];
}

class DeleteAllUndeliverableCustomersEvent extends UndeliverableCustomerEvent {
  const DeleteAllUndeliverableCustomersEvent();

  @override
  List<Object?> get props => [];
}

class SetUndeliverableReasonEvent extends UndeliverableCustomerEvent {
  final String customerId;
  final UndeliverableReason reason;

  const SetUndeliverableReasonEvent(this.customerId, this.reason);

  @override
  List<Object?> get props => [customerId, reason];
}
