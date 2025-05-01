import 'package:xpro_delivery_admin_app/core/common/app/features/checklist/domain/usecase/check_Item.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/checklist/domain/usecase/create_checklist.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/checklist/domain/usecase/delete_all_checklist.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/checklist/domain/usecase/delete_checklist.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/checklist/domain/usecase/get_all_checklist.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/checklist/domain/usecase/load_checklist_by_trip_id.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/checklist/domain/usecase/update_checklist.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/checklist/presentation/bloc/checklist_event.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/checklist/presentation/bloc/checklist_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
class ChecklistBloc extends Bloc<ChecklistEvent, ChecklistState> {
  final CheckItem _checkItem;
  final LoadChecklistByTripId _loadChecklistByTripId;
  final GetAllChecklists _getAllChecklists;
  final CreateChecklistItem _createChecklistItem;
  final UpdateChecklistItem _updateChecklistItem;
  final DeleteChecklistItem _deleteChecklistItem;
  final DeleteAllChecklistItems _deleteAllChecklistItems;
  ChecklistState? _cachedState;

  ChecklistBloc({
    required CheckItem checkItem,
    required LoadChecklistByTripId loadChecklistByTripId,
    required GetAllChecklists getAllChecklists,
    required CreateChecklistItem createChecklistItem,
    required UpdateChecklistItem updateChecklistItem,
    required DeleteChecklistItem deleteChecklistItem,
    required DeleteAllChecklistItems deleteAllChecklistItems,
  })  : 
        _checkItem = checkItem,
        _loadChecklistByTripId = loadChecklistByTripId,
        _getAllChecklists = getAllChecklists,
        _createChecklistItem = createChecklistItem,
        _updateChecklistItem = updateChecklistItem,
        _deleteChecklistItem = deleteChecklistItem,
        _deleteAllChecklistItems = deleteAllChecklistItems,
        super(const ChecklistInitial()) {
    on<CheckItemEvent>(_onCheckItemHandler);
    on<LoadChecklistByTripIdEvent>(_onLoadChecklistByTripIdHandler);
    on<GetAllChecklistsEvent>(_onGetAllChecklistsHandler);
    on<CreateChecklistItemEvent>(_onCreateChecklistItemHandler);
    on<UpdateChecklistItemEvent>(_onUpdateChecklistItemHandler);
    on<DeleteChecklistItemEvent>(_onDeleteChecklistItemHandler);
    on<DeleteAllChecklistItemsEvent>(_onDeleteAllChecklistItemsHandler);
  }

 

  Future<void> _onGetAllChecklistsHandler(
    GetAllChecklistsEvent event,
    Emitter<ChecklistState> emit,
  ) async {
    debugPrint('🔄 Getting all checklists');
    emit(const ChecklistLoading());
    
    final result = await _getAllChecklists();
    
    result.fold(
      (failure) {
        debugPrint('❌ Failed to get all checklists: ${failure.message}');
        emit(ChecklistError(failure.message));
      },
      (checklists) {
        debugPrint('✅ Successfully retrieved ${checklists.length} checklists');
        emit(AllChecklistsLoaded(checklists));
      },
    );
  }

  Future<void> _onLoadChecklistByTripIdHandler(
    LoadChecklistByTripIdEvent event,
    Emitter<ChecklistState> emit,
  ) async {
    debugPrint('🔄 Loading checklist for trip: ${event.tripId}');
    emit(const ChecklistLoading());

    final result = await _loadChecklistByTripId(event.tripId);
    result.fold(
      (failure) {
        debugPrint('❌ Checklist load failed: ${failure.message}');
        emit(ChecklistError(failure.message));
      },
      (checklist) {
        debugPrint('✅ Successfully loaded ${checklist.length} checklist items for trip');
        _cachedState = ChecklistLoaded(checklist);
        emit(_cachedState!);
      },
    );
  }

  Future<void> _onCheckItemHandler(
    CheckItemEvent event,
    Emitter<ChecklistState> emit,
  ) async {
    debugPrint('🔄 Checking item: ${event.id}');
    
    if (_cachedState is ChecklistLoaded) {
      final currentState = _cachedState as ChecklistLoaded;
      emit(const ChecklistLoading());

      final result = await _checkItem(event.id);
      result.fold(
        (failure) {
          debugPrint('❌ Check failed: ${failure.message}');
          emit(ChecklistError(failure.message));
        },
        (isChecked) {
          final updatedChecklist = currentState.checklist.map((item) {
            if (item.id == event.id) {
              return item..isChecked = isChecked;
            }
            return item;
          }).toList();
          
          final newState = ChecklistLoaded(updatedChecklist);
          _cachedState = newState;
          emit(newState);
          emit(ChecklistItemChecked(isChecked: isChecked, id: event.id));
          debugPrint('✅ Item checked successfully');
        },
      );
    }
  }

  Future<void> _onCreateChecklistItemHandler(
    CreateChecklistItemEvent event,
    Emitter<ChecklistState> emit,
  ) async {
    debugPrint('🔄 Creating new checklist item: ${event.objectName}');
    emit(const ChecklistLoading());
    
    final result = await _createChecklistItem(
      CreateChecklistItemParams(
        objectName: event.objectName,
        isChecked: event.isChecked,
        tripId: event.tripId,
        status: event.status,
        timeCompleted: event.timeCompleted,
      ),
    );
    
    result.fold(
      (failure) {
        debugPrint('❌ Failed to create checklist item: ${failure.message}');
        emit(ChecklistError(failure.message));
      },
      (checklistItem) {
        debugPrint('✅ Successfully created checklist item with ID: ${checklistItem.id}');
        emit(ChecklistItemCreated(checklistItem));
        
        // Refresh the checklist if we have a cached state
        if (_cachedState is ChecklistLoaded) {
          final currentState = _cachedState as ChecklistLoaded;
          final updatedChecklist = [...currentState.checklist, checklistItem];
          
          final newState = ChecklistLoaded(updatedChecklist);
          _cachedState = newState;
          emit(newState);
        }
      },
    );
  }

  Future<void> _onUpdateChecklistItemHandler(
    UpdateChecklistItemEvent event,
    Emitter<ChecklistState> emit,
  ) async {
    debugPrint('🔄 Updating checklist item: ${event.id}');
    emit(const ChecklistLoading());
    
    final result = await _updateChecklistItem(
      UpdateChecklistItemParams(
        id: event.id,
        objectName: event.objectName,
        isChecked: event.isChecked,
        tripId: event.tripId,
        status: event.status,
        timeCompleted: event.timeCompleted,
      ),
    );
    
    result.fold(
      (failure) {
        debugPrint('❌ Failed to update checklist item: ${failure.message}');
        emit(ChecklistError(failure.message));
      },
      (checklistItem) {
        debugPrint('✅ Successfully updated checklist item: ${checklistItem.id}');
        emit(ChecklistItemUpdated(checklistItem));
        
        // Update the cached state if we have one
        if (_cachedState is ChecklistLoaded) {
          final currentState = _cachedState as ChecklistLoaded;
          final updatedChecklist = currentState.checklist.map((item) {
            if (item.id == event.id) {
              return checklistItem;
            }
            return item;
          }).toList();
          
          final newState = ChecklistLoaded(updatedChecklist);
          _cachedState = newState;
          emit(newState);
        }
      },
    );
  }

  Future<void> _onDeleteChecklistItemHandler(
    DeleteChecklistItemEvent event,
    Emitter<ChecklistState> emit,
  ) async {
    debugPrint('🔄 Deleting checklist item: ${event.id}');
    emit(const ChecklistLoading());
    
    final result = await _deleteChecklistItem(event.id);
    
    result.fold(
      (failure) {
        debugPrint('❌ Failed to delete checklist item: ${failure.message}');
        emit(ChecklistError(failure.message));
      },
      (_) {
        debugPrint('✅ Successfully deleted checklist item');
        emit(ChecklistItemDeleted(event.id));
        
        // Update the cached state if we have one
        if (_cachedState is ChecklistLoaded) {
          final currentState = _cachedState as ChecklistLoaded;
          final updatedChecklist = currentState.checklist
              .where((item) => item.id != event.id)
              .toList();
          
          final newState = ChecklistLoaded(updatedChecklist);
          _cachedState = newState;
          emit(newState);
        }
      },
    );
  }

  Future<void> _onDeleteAllChecklistItemsHandler(
    DeleteAllChecklistItemsEvent event,
    Emitter<ChecklistState> emit,
  ) async {
    debugPrint('🔄 Deleting multiple checklist items: ${event.ids.length} items');
    emit(const ChecklistLoading());
    
    final result = await _deleteAllChecklistItems(
      DeleteAllChecklistItemsParams(ids: event.ids),
    );
    
    result.fold(
      (failure) {
        debugPrint('❌ Failed to delete multiple checklist items: ${failure.message}');
        emit(ChecklistError(failure.message));
      },
      (_) {
        debugPrint('✅ Successfully deleted all checklist items');
        emit(AllChecklistItemsDeleted(event.ids));
        
        // Update the cached state if we have one
        if (_cachedState is ChecklistLoaded) {
          final currentState = _cachedState as ChecklistLoaded;
          final updatedChecklist = currentState.checklist
              .where((item) => !event.ids.contains(item.id))
              .toList();
          
          final newState = ChecklistLoaded(updatedChecklist);
          _cachedState = newState;
          emit(newState);
        }
      },
    );
  }

  @override
  Future<void> close() {
    _cachedState = null;
    return super.close();
  }
}
