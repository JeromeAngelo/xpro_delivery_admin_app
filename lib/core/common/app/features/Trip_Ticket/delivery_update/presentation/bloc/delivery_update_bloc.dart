import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/delivery_update/domain/usecase/check_end_delivery_status.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/delivery_update/domain/usecase/create_delivery_status.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/delivery_update/domain/usecase/create_delivery_update.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/delivery_update/domain/usecase/delete_all_delivery_update.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/delivery_update/domain/usecase/delete_delivery_update.dart' show DeleteDeliveryUpdate;
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/delivery_update/domain/usecase/get_all_delivery_status.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/delivery_update/domain/usecase/get_delivery_update.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/delivery_update/domain/usecase/itialized_pending_status.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/delivery_update/domain/usecase/update_delivery_status.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/delivery_update/domain/usecase/update_delivery_update.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/delivery_update/domain/usecase/update_queue_remarks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import './delivery_update_event.dart';
import './delivery_update_state.dart';

class DeliveryUpdateBloc extends Bloc<DeliveryUpdateEvent, DeliveryUpdateState> {
   final GetDeliveryStatusChoices _getDeliveryStatusChoices;
  final UpdateDeliveryStatus _updateDeliveryStatus;
  final CheckEndDeliverStatus _checkEndDeliverStatus;
  final InitializePendingStatus _initializePendingStatus;
  final CreateDeliveryStatus _createDeliveryStatus;
  final UpdateQueueRemarks _updateQueueRemarks;
  // New use cases
  final GetAllDeliveryUpdates _getAllDeliveryUpdates;
  final CreateDeliveryUpdate _createDeliveryUpdate;
  final UpdateDeliveryUpdate _updateDeliveryUpdate;
  final DeleteDeliveryUpdate _deleteDeliveryUpdate;
  final DeleteAllDeliveryUpdates _deleteAllDeliveryUpdates;
  
  DeliveryUpdateState? _cachedState;

  DeliveryUpdateBloc({
    required GetDeliveryStatusChoices getDeliveryStatusChoices,
    required UpdateDeliveryStatus updateDeliveryStatus,
    required CheckEndDeliverStatus checkEndDeliverStatus,
    required InitializePendingStatus initializePendingStatus,
    required CreateDeliveryStatus createDeliveryStatus,
    required UpdateQueueRemarks updateQueueRemarks,
    required GetAllDeliveryUpdates getAllDeliveryUpdates,
    required CreateDeliveryUpdate createDeliveryUpdate,
    required UpdateDeliveryUpdate updateDeliveryUpdate,
    required DeleteDeliveryUpdate deleteDeliveryUpdate,
    required DeleteAllDeliveryUpdates deleteAllDeliveryUpdates,
  }) : _getDeliveryStatusChoices = getDeliveryStatusChoices,
       _updateDeliveryStatus = updateDeliveryStatus,
       _checkEndDeliverStatus = checkEndDeliverStatus,
       _initializePendingStatus = initializePendingStatus,
       _createDeliveryStatus = createDeliveryStatus,
       _updateQueueRemarks = updateQueueRemarks,
       _getAllDeliveryUpdates = getAllDeliveryUpdates,
       _createDeliveryUpdate = createDeliveryUpdate,
       _updateDeliveryUpdate = updateDeliveryUpdate,
       _deleteDeliveryUpdate = deleteDeliveryUpdate,
       _deleteAllDeliveryUpdates = deleteAllDeliveryUpdates,
       super(DeliveryUpdateInitial()) {
    on<GetDeliveryStatusChoicesEvent>(_onGetDeliveryStatusChoices);
    on<UpdateDeliveryStatusEvent>(_onUpdateDeliveryStatus);
    on<CheckEndDeliveryStatusEvent>(_onCheckEndDeliveryStatus);
    on<InitializePendingStatusEvent>(_onInitializePendingStatus);
    on<CreateDeliveryStatusEvent>(_onCreateDeliveryStatus);
    on<UpdateQueueRemarksEvent>(_onUpdateQueueRemarks);
    
    // Register new event handlers
    on<GetAllDeliveryUpdatesEvent>(_onGetAllDeliveryUpdates);
    on<CreateDeliveryUpdateEvent>(_onCreateDeliveryUpdate);
    on<UpdateDeliveryUpdateEvent>(_onUpdateDeliveryUpdate);
    on<DeleteDeliveryUpdateEvent>(_onDeleteDeliveryUpdate);
    on<DeleteAllDeliveryUpdatesEvent>(_onDeleteAllDeliveryUpdates);
  }

  Future<void> _onUpdateQueueRemarks(
    UpdateQueueRemarksEvent event,
    Emitter<DeliveryUpdateState> emit,
  ) async {
    emit(DeliveryUpdateLoading());

    final result = await _updateQueueRemarks(
      UpdateQueueRemarksParams(
        customerId: event.customerId,
        queueCount: event.queueCount,
      ),
    );

    if (!emit.isDone) {
      result.fold(
        (failure) => emit(DeliveryUpdateError(failure.message)),
        (_) => emit(QueueRemarksUpdated(
          customerId: event.customerId,
          queueCount: event.queueCount,
        )),
      );
    }
  }
Future<void> _onGetDeliveryStatusChoices(
  GetDeliveryStatusChoicesEvent event,
  Emitter<DeliveryUpdateState> emit,
) async {
  emit(DeliveryUpdateLoading());
  debugPrint('🌐 Fetching delivery status choices from remote');

  final result = await _getDeliveryStatusChoices(event.customerId);
  result.fold(
    (failure) => emit(DeliveryUpdateError(failure.message)),
    (statusChoices) {
      final newState = DeliveryStatusChoicesLoaded(statusChoices);
      _cachedState = newState;
      emit(newState);
    },
  );
}

 



 Future<void> _onUpdateDeliveryStatus(
  UpdateDeliveryStatusEvent event,
  Emitter<DeliveryUpdateState> emit,
) async {
  debugPrint('🔄 Starting delivery status update');
  emit(DeliveryUpdateLoading());

  final result = await _updateDeliveryStatus(
    UpdateDeliveryStatusParams(
      customerId: event.customerId,
      statusId: event.statusId,
    ),
  );

  result.fold(
    (failure) => emit(DeliveryUpdateError(failure.message)),
    (_) {
      emit(const DeliveryStatusUpdateSuccess());
     
      // Then update with remote data
      add(GetDeliveryStatusChoicesEvent(event.customerId));
    },
  );
}



  Future<void> _onCheckEndDeliveryStatus(
  CheckEndDeliveryStatusEvent event,
  Emitter<DeliveryUpdateState> emit,
) async {
  emit(DeliveryUpdateLoading());
  debugPrint('🔄 Checking remote delivery status for trip: ${event.tripId}');

  final result = await _checkEndDeliverStatus(event.tripId);
  result.fold(
    (failure) => emit(DeliveryUpdateError(failure.message)),
    (stats) => emit(EndDeliveryStatusChecked(
      stats: stats,
      tripId: event.tripId,
    )),
  );
}



  Future<void> _onInitializePendingStatus(
    InitializePendingStatusEvent event,
    Emitter<DeliveryUpdateState> emit,
  ) async {
    emit(DeliveryUpdateLoading());

    final result = await _initializePendingStatus(event.customerIds);

    result.fold(
      (failure) => emit(DeliveryUpdateError(failure.message)),
      (_) => emit(PendingStatusInitialized()),
    );
  }

  Future<void> _onCreateDeliveryStatus(
    CreateDeliveryStatusEvent event,
    Emitter<DeliveryUpdateState> emit,
  ) async {
    emit(DeliveryUpdateLoading());

    final result = await _createDeliveryStatus(
      CreateDeliveryStatusParams(
        customerId: event.customerId,
        title: event.title,
        subtitle: event.subtitle,
        time: event.time,
        isAssigned: event.isAssigned,
        image: event.image,
      ),
    );

    result.fold(
      (failure) => emit(DeliveryUpdateError(failure.message)),
      (_) => emit(DeliveryStatusCreated(event.customerId)),
    );
  }

// New event handlers
  Future<void> _onGetAllDeliveryUpdates(
    GetAllDeliveryUpdatesEvent event,
    Emitter<DeliveryUpdateState> emit,
  ) async {
    emit(DeliveryUpdateLoading());
    debugPrint('🔄 Getting all delivery updates');

    final result = await _getAllDeliveryUpdates();
    result.fold(
      (failure) {
        debugPrint('❌ Failed to get all delivery updates: ${failure.message}');
        emit(DeliveryUpdateError(failure.message));
      },
      (updates) {
        debugPrint('✅ Retrieved ${updates.length} delivery updates');
        emit(AllDeliveryUpdatesLoaded(updates));
      },
    );
  }

  Future<void> _onCreateDeliveryUpdate(
    CreateDeliveryUpdateEvent event,
    Emitter<DeliveryUpdateState> emit,
  ) async {
    emit(DeliveryUpdateLoading());
    debugPrint('🔄 Creating new delivery update');

    final result = await _createDeliveryUpdate(
      CreateDeliveryUpdateParams(
        title: event.title,
        subtitle: event.subtitle,
        time: event.time,
        customerId: event.customerId,
        isAssigned: event.isAssigned,
        assignedTo: event.assignedTo,
        image: event.image,
        remarks: event.remarks,
      ),
    );

    result.fold(
      (failure) {
        debugPrint('❌ Failed to create delivery update: ${failure.message}');
        emit(DeliveryUpdateError(failure.message));
      },
      (update) {
        debugPrint('✅ Successfully created delivery update: ${update.id}');
        emit(DeliveryUpdateCreated(update));
      },
    );
  }

  Future<void> _onUpdateDeliveryUpdate(
    UpdateDeliveryUpdateEvent event,
    Emitter<DeliveryUpdateState> emit,
  ) async {
    emit(DeliveryUpdateLoading());
    debugPrint('🔄 Updating delivery update: ${event.id}');

    final result = await _updateDeliveryUpdate(
      UpdateDeliveryUpdateParams(
        id: event.id,
        title: event.title,
        subtitle: event.subtitle,
        time: event.time,
        customerId: event.customerId,
        isAssigned: event.isAssigned,
        assignedTo: event.assignedTo,
        image: event.image,
        remarks: event.remarks,
      ),
    );

    result.fold(
      (failure) {
        debugPrint('❌ Failed to update delivery update: ${failure.message}');
        emit(DeliveryUpdateError(failure.message));
      },
      (update) {
        debugPrint('✅ Successfully updated delivery update');
        emit(DeliveryUpdateUpdated(update));
      },
    );
  }

  Future<void> _onDeleteDeliveryUpdate(
    DeleteDeliveryUpdateEvent event,
    Emitter<DeliveryUpdateState> emit,
  ) async {
    emit(DeliveryUpdateLoading());
    debugPrint('🔄 Deleting delivery update: ${event.id}');

    final result = await _deleteDeliveryUpdate(event.id);
    result.fold(
      (failure) {
        debugPrint('❌ Failed to delete delivery update: ${failure.message}');
        emit(DeliveryUpdateError(failure.message));
      },
      (_) {
        debugPrint('✅ Successfully deleted delivery update');
        emit(DeliveryUpdateDeleted(event.id));
      },
    );
  }

  Future<void> _onDeleteAllDeliveryUpdates(
    DeleteAllDeliveryUpdatesEvent event,
    Emitter<DeliveryUpdateState> emit,
  ) async {
    emit(DeliveryUpdateLoading());
    debugPrint('🔄 Deleting multiple delivery updates: ${event.ids.length} items');

    final result = await _deleteAllDeliveryUpdates(event.ids);
    result.fold(
      (failure) {
        debugPrint('❌ Failed to delete delivery updates: ${failure.message}');
        emit(DeliveryUpdateError(failure.message));
      },
      (_) {
        debugPrint('✅ Successfully deleted all delivery updates');
        emit(AllDeliveryUpdatesDeleted(event.ids));
      },
    );
  }



  @override
  Future<void> close() {
    _cachedState = null;
    return super.close();
  }
}
