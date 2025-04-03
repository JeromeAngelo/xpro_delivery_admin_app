import 'package:equatable/equatable.dart';

abstract class EndTripChecklistEvent extends Equatable {
  const EndTripChecklistEvent();
}

class GetAllEndTripChecklistsEvent extends EndTripChecklistEvent {
  const GetAllEndTripChecklistsEvent();
  
  @override
  List<Object?> get props => [];
}

class GenerateEndTripChecklistEvent extends EndTripChecklistEvent {
  final String tripId;
  const GenerateEndTripChecklistEvent(this.tripId);
  
  @override
  List<Object?> get props => [tripId];
}

class CheckEndTripItemEvent extends EndTripChecklistEvent {
  final String id;
  const CheckEndTripItemEvent(this.id);
  
  @override
  List<Object?> get props => [id];
}

class LoadEndTripChecklistEvent extends EndTripChecklistEvent {
  final String tripId;
  const LoadEndTripChecklistEvent(this.tripId);
  
  @override
  List<Object?> get props => [tripId];
}

class CreateEndTripChecklistItemEvent extends EndTripChecklistEvent {
  final String objectName;
  final bool isChecked;
  final String tripId;
  final String? status;
  final DateTime? timeCompleted;
  
  const CreateEndTripChecklistItemEvent({
    required this.objectName,
    required this.isChecked,
    required this.tripId,
    this.status,
    this.timeCompleted,
  });
  
  @override
  List<Object?> get props => [objectName, isChecked, tripId, status, timeCompleted];
}

class UpdateEndTripChecklistItemEvent extends EndTripChecklistEvent {
  final String id;
  final String? objectName;
  final bool? isChecked;
  final String? tripId;
  final String? status;
  final DateTime? timeCompleted;
  
  const UpdateEndTripChecklistItemEvent({
    required this.id,
    this.objectName,
    this.isChecked,
    this.tripId,
    this.status,
    this.timeCompleted,
  });
  
  @override
  List<Object?> get props => [id, objectName, isChecked, tripId, status, timeCompleted];
}

class DeleteEndTripChecklistItemEvent extends EndTripChecklistEvent {
  final String id;
  
  const DeleteEndTripChecklistItemEvent(this.id);
  
  @override
  List<Object?> get props => [id];
}

class DeleteAllEndTripChecklistItemsEvent extends EndTripChecklistEvent {
  final List<String> ids;
  
  const DeleteAllEndTripChecklistItemsEvent(this.ids);
  
  @override
  List<Object?> get props => [ids];
}
