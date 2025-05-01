import 'package:xpro_delivery_admin_app/core/common/app/features/end_trip_checklist/domain/usecase/check_end_trip_checklist.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/end_trip_checklist/domain/usecase/create_end_trip_checklist.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/end_trip_checklist/domain/usecase/delete_all_end_trip_checklist.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/end_trip_checklist/domain/usecase/delete_end_trip_checklist.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/end_trip_checklist/domain/usecase/generate_end_trip_checklist.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/end_trip_checklist/domain/usecase/get_all_end_trip_checklist.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/end_trip_checklist/domain/usecase/load_end_trip_checklist.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/end_trip_checklist/domain/usecase/update_end_trip_checklist.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


import './end_trip_checklist_event.dart';
import './end_trip_checklist_state.dart';
class EndTripChecklistBloc extends Bloc<EndTripChecklistEvent, EndTripChecklistState> {
  final GenerateEndTripChecklist _generateEndTripChecklist;
  final CheckEndTripChecklist _checkEndTripChecklist;
  final LoadEndTripChecklist _loadEndTripChecklist;
  final GetAllEndTripChecklists _getAllEndTripChecklists;
  final CreateEndTripChecklistItem _createEndTripChecklistItem;
  final UpdateEndTripChecklistItem _updateEndTripChecklistItem;
  final DeleteEndTripChecklistItem _deleteEndTripChecklistItem;
  final DeleteAllEndTripChecklistItems _deleteAllEndTripChecklistItems;
  EndTripChecklistState? _cachedState;

  EndTripChecklistBloc({
    required GenerateEndTripChecklist generateEndTripChecklist,
    required CheckEndTripChecklist checkEndTripChecklist,
    required LoadEndTripChecklist loadEndTripChecklist,
    required GetAllEndTripChecklists getAllEndTripChecklists,
    required CreateEndTripChecklistItem createEndTripChecklistItem,
    required UpdateEndTripChecklistItem updateEndTripChecklistItem,
    required DeleteEndTripChecklistItem deleteEndTripChecklistItem,
    required DeleteAllEndTripChecklistItems deleteAllEndTripChecklistItems,
  })  : _generateEndTripChecklist = generateEndTripChecklist,
        _checkEndTripChecklist = checkEndTripChecklist,
        _loadEndTripChecklist = loadEndTripChecklist,
        _getAllEndTripChecklists = getAllEndTripChecklists,
        _createEndTripChecklistItem = createEndTripChecklistItem,
        _updateEndTripChecklistItem = updateEndTripChecklistItem,
        _deleteEndTripChecklistItem = deleteEndTripChecklistItem,
        _deleteAllEndTripChecklistItems = deleteAllEndTripChecklistItems,
        super(const EndTripChecklistInitial()) {
    on<GenerateEndTripChecklistEvent>(_onGenerateEndTripChecklist);
    on<CheckEndTripItemEvent>(_onCheckEndTripItem);
    on<LoadEndTripChecklistEvent>(_onLoadEndTripChecklist);
    on<GetAllEndTripChecklistsEvent>(_onGetAllEndTripChecklists);
    on<CreateEndTripChecklistItemEvent>(_onCreateEndTripChecklistItem);
    on<UpdateEndTripChecklistItemEvent>(_onUpdateEndTripChecklistItem);
    on<DeleteEndTripChecklistItemEvent>(_onDeleteEndTripChecklistItem);
    on<DeleteAllEndTripChecklistItemsEvent>(_onDeleteAllEndTripChecklistItems);
  }

  Future<void> _onGenerateEndTripChecklist(
    GenerateEndTripChecklistEvent event,
    Emitter<EndTripChecklistState> emit,
  ) async {
    debugPrint('🔄 Generating checklist for trip: ${event.tripId}');
    emit(const EndTripChecklistLoading());

    final result = await _generateEndTripChecklist(event.tripId);
    result.fold(
      (failure) => emit(EndTripChecklistError(failure.message)),
      (checklists) {
        final newState = EndTripChecklistGenerated(checklists);
        _cachedState = newState;
        emit(newState);
      },
    );
  }

  Future<void> _onCheckEndTripItem(
    CheckEndTripItemEvent event,
    Emitter<EndTripChecklistState> emit,
  ) async {
    debugPrint('🔄 Bloc: Checking item ${event.id}');
    
    if (_cachedState is EndTripChecklistLoaded) {
      final currentState = _cachedState as EndTripChecklistLoaded;
      emit(const EndTripChecklistLoading());

      final result = await _checkEndTripChecklist(event.id);
      result.fold(
        (failure) {
          debugPrint('❌ Bloc: Check failed - ${failure.message}');
          emit(EndTripChecklistError(failure.message));
        },
        (isChecked) {
          final updatedChecklists = currentState.checklist.map((item) {
            if (item.id == event.id) {
              return item..isChecked = isChecked;
            }
            return item;
          }).toList();
          
          final newState = EndTripChecklistLoaded(updatedChecklists);
          _cachedState = newState;
          emit(newState);
          emit(EndTripItemChecked(id: event.id, isChecked: isChecked));
          debugPrint('✅ Bloc: Item checked successfully');
        },
      );
    }
  }

  Future<void> _onLoadEndTripChecklist(
    LoadEndTripChecklistEvent event,
    Emitter<EndTripChecklistState> emit,
  ) async {
    emit(const EndTripChecklistLoading());
    debugPrint('🔄 Loading checklist for trip: ${event.tripId}');

    final result = await _loadEndTripChecklist(event.tripId);
    result.fold(
      (failure) {
        debugPrint('❌ Bloc: Load failed - ${failure.message}');
        emit(EndTripChecklistError(failure.message));
      },
      (checklists) {
        debugPrint('✅ Bloc: Loaded ${checklists.length} items');
        final newState = EndTripChecklistLoaded(checklists);
        _cachedState = newState;
        emit(newState);
      },
    );
  }

  Future<void> _onGetAllEndTripChecklists(
    GetAllEndTripChecklistsEvent event,
    Emitter<EndTripChecklistState> emit,
  ) async {
    emit(const EndTripChecklistLoading());
    debugPrint('🔄 Getting all end trip checklists');

    final result = await _getAllEndTripChecklists();
    result.fold(
      (failure) {
        debugPrint('❌ Failed to get all checklists: ${failure.message}');
        emit(EndTripChecklistError(failure.message));
      },
      (checklists) {
        debugPrint('✅ Successfully retrieved ${checklists.length} checklists');
        emit(AllEndTripChecklistsLoaded(checklists));
      },
    );
  }

  Future<void> _onCreateEndTripChecklistItem(
    CreateEndTripChecklistItemEvent event,
    Emitter<EndTripChecklistState> emit,
  ) async {
    emit(const EndTripChecklistLoading());
    debugPrint('🔄 Creating new checklist item: ${event.objectName}');

    final result = await _createEndTripChecklistItem(
      CreateEndTripChecklistItemParams(
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
        emit(EndTripChecklistError(failure.message));
      },
      (checklistItem) {
        debugPrint('✅ Successfully created checklist item with ID: ${checklistItem.id}');
        emit(EndTripChecklistItemCreated(checklistItem));
        
        // Refresh the checklist if we have a cached state
        if (_cachedState is EndTripChecklistLoaded) {
          add(LoadEndTripChecklistEvent(event.tripId));
        }
      },
    );
  }

  Future<void> _onUpdateEndTripChecklistItem(
    UpdateEndTripChecklistItemEvent event,
    Emitter<EndTripChecklistState> emit,
  ) async {
    emit(const EndTripChecklistLoading());
    debugPrint('🔄 Updating checklist item: ${event.id}');

    final result = await _updateEndTripChecklistItem(
      UpdateEndTripChecklistItemParams(
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
        emit(EndTripChecklistError(failure.message));
      },
      (checklistItem) {
        debugPrint('✅ Successfully updated checklist item: ${checklistItem.id}');
        emit(EndTripChecklistItemUpdated(checklistItem));
        
        // Refresh the checklist if we have a cached state and trip ID
        if (_cachedState is EndTripChecklistLoaded && event.tripId != null) {
          add(LoadEndTripChecklistEvent(event.tripId!));
        }
      },
    );
  }

  Future<void> _onDeleteEndTripChecklistItem(
    DeleteEndTripChecklistItemEvent event,
    Emitter<EndTripChecklistState> emit,
  ) async {
    emit(const EndTripChecklistLoading());
    debugPrint('🔄 Deleting checklist item: ${event.id}');

    final result = await _deleteEndTripChecklistItem(event.id);

    result.fold(
      (failure) {
        debugPrint('❌ Failed to delete checklist item: ${failure.message}');
        emit(EndTripChecklistError(failure.message));
      },
      (_) {
        debugPrint('✅ Successfully deleted checklist item');
        emit(EndTripChecklistItemDeleted(event.id));
        
        // Refresh the checklist if we have a cached state
        if (_cachedState is EndTripChecklistLoaded) {
          final currentState = _cachedState as EndTripChecklistLoaded;
          final updatedChecklists = currentState.checklist
              .where((item) => item.id != event.id)
              .toList();
          
          final newState = EndTripChecklistLoaded(updatedChecklists);
          _cachedState = newState;
          emit(newState);
        }
      },
    );
  }

  Future<void> _onDeleteAllEndTripChecklistItems(
    DeleteAllEndTripChecklistItemsEvent event,
    Emitter<EndTripChecklistState> emit,
  ) async {
    emit(const EndTripChecklistLoading());
    debugPrint('🔄 Deleting multiple checklist items: ${event.ids.length} items');

    final result = await _deleteAllEndTripChecklistItems(
      DeleteAllEndTripChecklistItemsParams(ids: event.ids),
    );

    result.fold(
      (failure) {
        debugPrint('❌ Failed to delete multiple checklist items: ${failure.message}');
        emit(EndTripChecklistError(failure.message));
      },
      (_) {
        debugPrint('✅ Successfully deleted all checklist items');
        emit(AllEndTripChecklistItemsDeleted(event.ids));
        
        // Refresh the checklist if we have a cached state
        if (_cachedState is EndTripChecklistLoaded) {
          final currentState = _cachedState as EndTripChecklistLoaded;
          final updatedChecklists = currentState.checklist
              .where((item) => !event.ids.contains(item.id))
              .toList();
          
          final newState = EndTripChecklistLoaded(updatedChecklists);
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
