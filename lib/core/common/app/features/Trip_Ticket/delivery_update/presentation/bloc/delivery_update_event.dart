import 'package:equatable/equatable.dart';

abstract class DeliveryUpdateEvent extends Equatable {
  const DeliveryUpdateEvent();
}

// Existing events
class GetDeliveryStatusChoicesEvent extends DeliveryUpdateEvent {
  final String customerId;
  const GetDeliveryStatusChoicesEvent(this.customerId);
  
  @override
  List<Object> get props => [customerId];
}

class UpdateDeliveryStatusEvent extends DeliveryUpdateEvent {
  final String customerId;
  final String statusId;
  const UpdateDeliveryStatusEvent({required this.customerId, required this.statusId});
  @override
  List<Object> get props => [customerId, statusId];
}



class CheckEndDeliveryStatusEvent extends DeliveryUpdateEvent {
  final String tripId;
  
  const CheckEndDeliveryStatusEvent(this.tripId);
  
  @override
  List<Object> get props => [tripId];
}

class InitializePendingStatusEvent extends DeliveryUpdateEvent {
  final List<String> customerIds;
  const InitializePendingStatusEvent(this.customerIds);
  @override
  List<Object> get props => [customerIds];
}

class CreateDeliveryStatusEvent extends DeliveryUpdateEvent {
  final String customerId;
  final String title;
  final String subtitle;
  final DateTime time;
  final bool isAssigned;
  final String image;
  const CreateDeliveryStatusEvent({
    required this.customerId,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.isAssigned,
    required this.image,
  });
  @override
  List<Object> get props => [customerId, title, subtitle, time, isAssigned, image];
}

class UpdateQueueRemarksEvent extends DeliveryUpdateEvent {
  final String customerId;
  final String queueCount;

  const UpdateQueueRemarksEvent({
    required this.customerId,
    required this.queueCount,
  });

  @override
  List<Object> get props => [customerId, queueCount];
}

// New events
class GetAllDeliveryUpdatesEvent extends DeliveryUpdateEvent {
  const GetAllDeliveryUpdatesEvent();
  
  @override
  List<Object> get props => [];
}

class CreateDeliveryUpdateEvent extends DeliveryUpdateEvent {
  final String title;
  final String subtitle;
  final DateTime time;
  final String customerId;
  final bool isAssigned;
  final String? assignedTo;
  final String? image;
  final String? remarks;

  const CreateDeliveryUpdateEvent({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.customerId,
    required this.isAssigned,
    this.assignedTo,
    this.image,
    this.remarks,
  });

  @override
  List<Object> get props => [
    title,
    subtitle,
    time,
    customerId,
    isAssigned,
    assignedTo ?? '',
    image ?? '',
    remarks ?? '',
  ];
}

class UpdateDeliveryUpdateEvent extends DeliveryUpdateEvent {
  final String id;
  final String? title;
  final String? subtitle;
  final DateTime? time;
  final String? customerId;
  final bool? isAssigned;
  final String? assignedTo;
  final String? image;
  final String? remarks;

  const UpdateDeliveryUpdateEvent({
    required this.id,
    this.title,
    this.subtitle,
    this.time,
    this.customerId,
    this.isAssigned,
    this.assignedTo,
    this.image,
    this.remarks,
  });

  @override
  List<Object> get props => [
    id,
    title ?? '',
    subtitle ?? '',
    time ?? DateTime.now(),
    customerId ?? '',
    isAssigned ?? false,
    assignedTo ?? '',
    image ?? '',
    remarks ?? '',
  ];
}

class DeleteDeliveryUpdateEvent extends DeliveryUpdateEvent {
  final String id;
  
  const DeleteDeliveryUpdateEvent(this.id);
  
  @override
  List<Object> get props => [id];
}

class DeleteAllDeliveryUpdatesEvent extends DeliveryUpdateEvent {
  final List<String> ids;
  
  const DeleteAllDeliveryUpdatesEvent(this.ids);
  
  @override
  List<Object> get props => [ids];
}
