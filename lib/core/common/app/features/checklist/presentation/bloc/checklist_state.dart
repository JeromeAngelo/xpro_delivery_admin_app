import 'package:desktop_app/core/common/app/features/checklist/domain/entity/checklist_entity.dart';
import 'package:equatable/equatable.dart';

abstract class ChecklistState extends Equatable {
  const ChecklistState();

  @override
  List<Object?> get props => [];
}

class ChecklistInitial extends ChecklistState {
  const ChecklistInitial();
}

class ChecklistLoading extends ChecklistState {
  const ChecklistLoading();
}

class AllChecklistsLoaded extends ChecklistState {
  final List<ChecklistEntity> checklists;

  const AllChecklistsLoaded(this.checklists);

  @override
  List<Object?> get props => [checklists];
}

class ChecklistLoaded extends ChecklistState {
  final List<ChecklistEntity> checklist;

  const ChecklistLoaded(this.checklist);

  @override
  List<Object?> get props => [checklist];
}

class ChecklistItemChecked extends ChecklistState {
  final bool isChecked;
  final String id;

  const ChecklistItemChecked({
    required this.isChecked,
    required this.id,
  });

  @override
  List<Object?> get props => [isChecked, id];
}

class ChecklistItemCreated extends ChecklistState {
  final ChecklistEntity checklistItem;
  
  const ChecklistItemCreated(this.checklistItem);
  
  @override
  List<Object?> get props => [checklistItem];
}

class ChecklistItemUpdated extends ChecklistState {
  final ChecklistEntity checklistItem;
  
  const ChecklistItemUpdated(this.checklistItem);
  
  @override
  List<Object?> get props => [checklistItem];
}

class ChecklistItemDeleted extends ChecklistState {
  final String id;
  
  const ChecklistItemDeleted(this.id);
  
  @override
  List<Object?> get props => [id];
}

class AllChecklistItemsDeleted extends ChecklistState {
  final List<String> ids;
  
  const AllChecklistItemsDeleted(this.ids);
  
  @override
  List<Object?> get props => [ids];
}

class ChecklistError extends ChecklistState {
  final String message;

  const ChecklistError(this.message);

  @override
  List<Object?> get props => [message];
}
