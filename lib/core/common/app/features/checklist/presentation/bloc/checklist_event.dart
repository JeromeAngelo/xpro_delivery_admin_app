import 'package:equatable/equatable.dart';

abstract class ChecklistEvent extends Equatable {
  const ChecklistEvent();
}

class GetAllChecklistsEvent extends ChecklistEvent {
  const GetAllChecklistsEvent();
  
  @override
  List<Object?> get props => [];
}

class LoadChecklistEvent extends ChecklistEvent {
  const LoadChecklistEvent();
  
  @override
  List<Object?> get props => [];
}

class LoadChecklistByTripIdEvent extends ChecklistEvent {
  final String tripId;
  const LoadChecklistByTripIdEvent(this.tripId);
  
  @override
  List<Object?> get props => [tripId];
}

class CheckItemEvent extends ChecklistEvent {
  final String id;
  const CheckItemEvent(this.id);
  
  @override
  List<Object?> get props => [id];
}

class CreateChecklistItemEvent extends ChecklistEvent {
  final String objectName;
  final bool isChecked;
  final String? tripId;
  final String? status;
  final DateTime? timeCompleted;
  
  const CreateChecklistItemEvent({
    required this.objectName,
    required this.isChecked,
    this.tripId,
    this.status,
    this.timeCompleted,
  });
  
  @override
  List<Object?> get props => [objectName, isChecked, tripId, status, timeCompleted];
}

class UpdateChecklistItemEvent extends ChecklistEvent {
  final String id;
  final String? objectName;
  final bool? isChecked;
  final String? tripId;
  final String? status;
  final DateTime? timeCompleted;
  
  const UpdateChecklistItemEvent({
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

class DeleteChecklistItemEvent extends ChecklistEvent {
  final String id;
  
  const DeleteChecklistItemEvent(this.id);
  
  @override
  List<Object?> get props => [id];
}

class DeleteAllChecklistItemsEvent extends ChecklistEvent {
  final List<String> ids;
  
  const DeleteAllChecklistItemsEvent(this.ids);
  
  @override
  List<Object?> get props => [ids];
}
