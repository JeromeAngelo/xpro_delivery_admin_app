import 'package:equatable/equatable.dart';

abstract class CompletedCustomerEvent extends Equatable {
  const CompletedCustomerEvent();

  @override
  List<Object> get props => [];
}

class GetCompletedCustomerEvent extends CompletedCustomerEvent {
  final String tripId;
  const GetCompletedCustomerEvent(this.tripId);

  @override
  List<Object> get props => [tripId];
}

class GetCompletedCustomerByIdEvent extends CompletedCustomerEvent {
  final String customerId;
  const GetCompletedCustomerByIdEvent(this.customerId);
  
  @override
  List<Object> get props => [customerId];
}

// New events
class GetAllCompletedCustomersEvent extends CompletedCustomerEvent {
  const GetAllCompletedCustomersEvent();
}

class CreateCompletedCustomerEvent extends CompletedCustomerEvent {
  final String deliveryNumber;
  final String storeName;
  final String ownerName;
  final List<String> contactNumber;
  final String address;
  final String municipality;
  final String province;
  final String modeOfPayment;
  final DateTime timeCompleted;
  final double totalAmount;
  final String totalTime;
  final String tripId;
  final String? transactionId;
  final String? customerId;

  const CreateCompletedCustomerEvent({
    required this.deliveryNumber,
    required this.storeName,
    required this.ownerName,
    required this.contactNumber,
    required this.address,
    required this.municipality,
    required this.province,
    required this.modeOfPayment,
    required this.timeCompleted,
    required this.totalAmount,
    required this.totalTime,
    required this.tripId,
    this.transactionId,
    this.customerId,
  });

  @override
  List<Object> get props => [
    deliveryNumber,
    storeName,
    ownerName,
    contactNumber,
    address,
    municipality,
    province,
    modeOfPayment,
    timeCompleted,
    totalAmount,
    totalTime,
    tripId,
    transactionId ?? '',
    customerId ?? '',
  ];
}

class UpdateCompletedCustomerEvent extends CompletedCustomerEvent {
  final String id;
  final String? deliveryNumber;
  final String? storeName;
  final String? ownerName;
  final List<String>? contactNumber;
  final String? address;
  final String? municipality;
  final String? province;
  final String? modeOfPayment;
  final DateTime? timeCompleted;
  final double? totalAmount;
  final String? totalTime;
  final String? tripId;
  final String? transactionId;
  final String? customerId;

  const UpdateCompletedCustomerEvent({
    required this.id,
    this.deliveryNumber,
    this.storeName,
    this.ownerName,
    this.contactNumber,
    this.address,
    this.municipality,
    this.province,
    this.modeOfPayment,
    this.timeCompleted,
    this.totalAmount,
    this.totalTime,
    this.tripId,
    this.transactionId,
    this.customerId,
  });

  @override
  List<Object> get props => [
    id,
    deliveryNumber ?? '',
    storeName ?? '',
    ownerName ?? '',
    contactNumber ?? [],
    address ?? '',
    municipality ?? '',
    province ?? '',
    modeOfPayment ?? '',
    timeCompleted ?? DateTime.now(),
    totalAmount ?? 0.0,
    totalTime ?? '',
    tripId ?? '',
    transactionId ?? '',
    customerId ?? '',
  ];
}

class DeleteCompletedCustomerEvent extends CompletedCustomerEvent {
  final String id;
  
  const DeleteCompletedCustomerEvent(this.id);
  
  @override
  List<Object> get props => [id];
}

class DeleteAllCompletedCustomersEvent extends CompletedCustomerEvent {
  final List<String> ids;
  
  const DeleteAllCompletedCustomersEvent(this.ids);
  
  @override
  List<Object> get props => [ids];
}
