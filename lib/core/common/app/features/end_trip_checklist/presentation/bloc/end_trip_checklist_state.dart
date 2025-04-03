import 'package:desktop_app/core/common/app/features/end_trip_checklist/domain/entity/end_checklist_entity.dart';
import 'package:equatable/equatable.dart';

abstract class EndTripChecklistState extends Equatable {
  const EndTripChecklistState();
  
  @override
  List<Object?> get props => [];
}

class EndTripChecklistInitial extends EndTripChecklistState {
  const EndTripChecklistInitial();
}

class EndTripChecklistLoading extends EndTripChecklistState {
  const EndTripChecklistLoading();
}

class AllEndTripChecklistsLoaded extends EndTripChecklistState {
  final List<EndChecklistEntity> checklists;
  
  const AllEndTripChecklistsLoaded(this.checklists);
  
  @override
  List<Object?> get props => [checklists];
}

class EndTripChecklistGenerated extends EndTripChecklistState {
  final List<EndChecklistEntity> checklist;
  
  const EndTripChecklistGenerated(this.checklist);
  
  @override
  List<Object?> get props => [checklist];
}

class EndTripItemChecked extends EndTripChecklistState {
  final String id;
  final bool isChecked;
  
  const EndTripItemChecked({
    required this.id,
    required this.isChecked,
  });
  
  @override
  List<Object?> get props => [id, isChecked];
}

class EndTripChecklistLoaded extends EndTripChecklistState {
  final List<EndChecklistEntity> checklist;
  
  const EndTripChecklistLoaded(this.checklist);
  
  @override
  List<Object?> get props => [checklist];
}

class EndTripChecklistItemCreated extends EndTripChecklistState {
  final EndChecklistEntity checklistItem;
  
  const EndTripChecklistItemCreated(this.checklistItem);
  
  @override
  List<Object?> get props => [checklistItem];
}

class EndTripChecklistItemUpdated extends EndTripChecklistState {
  final EndChecklistEntity checklistItem;
  
  const EndTripChecklistItemUpdated(this.checklistItem);
  
  @override
  List<Object?> get props => [checklistItem];
}

class EndTripChecklistItemDeleted extends EndTripChecklistState {
  final String id;
  
  const EndTripChecklistItemDeleted(this.id);
  
  @override
  List<Object?> get props => [id];
}

class AllEndTripChecklistItemsDeleted extends EndTripChecklistState {
  final List<String> ids;
  
  const AllEndTripChecklistItemsDeleted(this.ids);
  
  @override
  List<Object?> get props => [ids];
}

class EndTripChecklistError extends EndTripChecklistState {
  final String message;
  
  const EndTripChecklistError(this.message);
  
  @override
  List<Object?> get props => [message];
}
