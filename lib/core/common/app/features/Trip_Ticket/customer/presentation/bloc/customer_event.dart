import 'package:equatable/equatable.dart';

abstract class CustomerEvent extends Equatable {
  const CustomerEvent();
}

// Existing events
class GetCustomerEvent extends CustomerEvent {
  final String tripId;
  const GetCustomerEvent(this.tripId);
  
  @override
  List<Object?> get props => [tripId];
}

class GetCustomerLocationEvent extends CustomerEvent {
  final String customerId;
  const GetCustomerLocationEvent(this.customerId);
  
  @override
  List<Object?> get props => [customerId];
}

class RefreshCustomersEvent extends CustomerEvent {
  final String tripId;
  const RefreshCustomersEvent(this.tripId);
  
  @override
  List<Object?> get props => [tripId];
}

class CalculateCustomerTotalTimeEvent extends CustomerEvent {
  final String customerId;
  
  const CalculateCustomerTotalTimeEvent(this.customerId);
  
  @override
  List<Object?> get props => [customerId];
}

// New events
class GetAllCustomersEvent extends CustomerEvent {
  const GetAllCustomersEvent();
  
  @override
  List<Object?> get props => [];
}

class CreateCustomerEvent extends CustomerEvent {
  final String deliveryNumber;
  final String storeName;
  final String ownerName;
  final List<String> contactNumber;
  final String address;
  final String municipality;
  final String province;
  final String modeOfPayment;
  final String tripId;
  final String? totalAmount;
  final String? latitude;
  final String? longitude;
  final String? notes;
  final String? remarks;
  final bool? hasNotes;
  final double? confirmedTotalPayment;

  const CreateCustomerEvent({
    required this.deliveryNumber,
    required this.storeName,
    required this.ownerName,
    required this.contactNumber,
    required this.address,
    required this.municipality,
    required this.province,
    required this.modeOfPayment,
    required this.tripId,
    this.totalAmount,
    this.latitude,
    this.longitude,
    this.notes,
    this.remarks,
    this.hasNotes,
    this.confirmedTotalPayment,
  });

  @override
  List<Object?> get props => [
    deliveryNumber,
    storeName,
    ownerName,
    contactNumber,
    address,
    municipality,
    province,
    modeOfPayment,
    tripId,
    totalAmount,
    latitude,
    longitude,
    notes,
    remarks,
    hasNotes,
    confirmedTotalPayment,
  ];
}

class UpdateCustomerEvent extends CustomerEvent {
  final String id;
  final String? deliveryNumber;
  final String? storeName;
  final String? ownerName;
  final List<String>? contactNumber;
  final String? address;
  final String? municipality;
  final String? province;
  final String? modeOfPayment;
  final String? tripId;
  final String? totalAmount;
  final String? latitude;
  final String? longitude;
  final String? notes;
  final String? remarks;
  final bool? hasNotes;
  final double? confirmedTotalPayment;

  const UpdateCustomerEvent({
    required this.id,
    this.deliveryNumber,
    this.storeName,
    this.ownerName,
    this.contactNumber,
    this.address,
    this.municipality,
    this.province,
    this.modeOfPayment,
    this.tripId,
    this.totalAmount,
    this.latitude,
    this.longitude,
    this.notes,
    this.remarks,
    this.hasNotes,
    this.confirmedTotalPayment,
  });

  @override
  List<Object?> get props => [
    id,
    deliveryNumber,
    storeName,
    ownerName,
    contactNumber,
    address,
    municipality,
    province,
    modeOfPayment,
    tripId,
    totalAmount,
    latitude,
    longitude,
    notes,
    remarks,
    hasNotes,
    confirmedTotalPayment,
  ];
}

class DeleteCustomerEvent extends CustomerEvent {
  final String id;
  
  const DeleteCustomerEvent(this.id);
  
  @override
  List<Object?> get props => [id];
}

class DeleteAllCustomersEvent extends CustomerEvent {
  final List<String> ids;
  
  const DeleteAllCustomersEvent(this.ids);
  
  @override
  List<Object?> get props => [ids];
}
