import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/cancelled_invoices/presentation/bloc/cancelled_invoice_event.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/cancelled_invoices/presentation/bloc/cancelled_invoice_state.dart';

import '../../domain/usecases/create_cancelled_invoice_by_delivery_data_id.dart';
import '../../domain/usecases/delete_cancelled_invoice.dart';
import '../../domain/usecases/get_all_cancelled_invoice.dart';
import '../../domain/usecases/load_cancelled_invoice_by_id.dart';
import '../../domain/usecases/load_cancelled_invoice_by_trip_id.dart';
import '../../domain/usecases/resassign_trip_for_cancelled_invoice.dart';

class CancelledInvoiceBloc extends Bloc<CancelledInvoiceEvent, CancelledInvoiceState> {
  final LoadCancelledInvoicesByTripId _loadCancelledInvoicesByTripId;
  final LoadCancelledInvoiceById _loadCancelledInvoicesById;
  final CreateCancelledInvoiceByDeliveryDataId _createCancelledInvoiceByDeliveryDataId;
  final DeleteCancelledInvoice _deleteCancelledInvoice;
  final GetAllCancelledInvoices _getAllCancelledInvoices;
  final ReassignTripForCancelledInvoice _reassignTripForCancelledInvoice; // Add this line

  CancelledInvoiceState? _cachedState;

  CancelledInvoiceBloc({
    required LoadCancelledInvoicesByTripId loadCancelledInvoicesByTripId,
    required LoadCancelledInvoiceById loadCancelledInvoicesById,
    required GetAllCancelledInvoices getAllCancelledInvoices,
    required CreateCancelledInvoiceByDeliveryDataId createCancelledInvoiceByDeliveryDataId,
    required DeleteCancelledInvoice deleteCancelledInvoice,
    required ReassignTripForCancelledInvoice reassignTripForCancelledInvoice, // Add this line
  }) : _loadCancelledInvoicesByTripId = loadCancelledInvoicesByTripId,
       _loadCancelledInvoicesById = loadCancelledInvoicesById,
       _createCancelledInvoiceByDeliveryDataId = createCancelledInvoiceByDeliveryDataId,
       _getAllCancelledInvoices = getAllCancelledInvoices,
       _deleteCancelledInvoice = deleteCancelledInvoice,
       _reassignTripForCancelledInvoice = reassignTripForCancelledInvoice, // Add this line
       super(const CancelledInvoiceInitial()) {
    
    on<LoadCancelledInvoicesByTripIdEvent>(_onLoadCancelledInvoicesByTripId);
    on<LoadCancelledInvoicesByIdEvent>(_onLoadCancelledInvoicesById);
    on<CreateCancelledInvoiceByDeliveryDataIdEvent>(_onCreateCancelledInvoiceByDeliveryDataId);
    on<DeleteCancelledInvoiceEvent>(_onDeleteCancelledInvoice);
    on<RefreshCancelledInvoicesEvent>(_onRefreshCancelledInvoices);
    on<GetAllCancelledInvoicesEvent>(_onGetAllCancelledInvoices);
    on<ReassignTripForCancelledInvoiceEvent>(_onReassignTripForCancelledInvoice); // Add this line
  }


  Future<void> _onGetAllCancelledInvoices(
  GetAllCancelledInvoicesEvent event,
  Emitter<CancelledInvoiceState> emit,
) async {
  debugPrint('🔄 BLoC: Loading all cancelled invoices');
  
  emit(const CancelledInvoiceLoading());

  final result = await _getAllCancelledInvoices();
  
  result.fold(
    (failure) {
      debugPrint('❌ BLoC: Failed to load all cancelled invoices: ${failure.message}');
      emit(CancelledInvoiceError(failure.message));
    },
    (cancelledInvoices) {
      debugPrint('✅ BLoC: Loaded ${cancelledInvoices.length} cancelled invoices');
      
      if (cancelledInvoices.isEmpty) {
        emit(const CancelledInvoiceError('No cancelled invoices found'));
      } else {
        final newState = AllCancelledInvoicesLoaded(cancelledInvoices);
        emit(newState);
        _cachedState = newState;
      }
    },
  );
}

Future<void> _onReassignTripForCancelledInvoice(
  ReassignTripForCancelledInvoiceEvent event,
  Emitter<CancelledInvoiceState> emit,
) async {
  debugPrint('🔄 BLoC: Reassigning trip for cancelled invoice with delivery data: ${event.deliveryDataId}');
  
  emit(const CancelledInvoiceLoading());

  final result = await _reassignTripForCancelledInvoice(
    ReassignTripForCancelledInvoiceParams(
      deliveryDataId: event.deliveryDataId,
    ),
  );
  
  result.fold(
    (failure) {
      debugPrint('❌ BLoC: Failed to reassign trip for cancelled invoice: ${failure.message}');
      emit(CancelledInvoiceError(failure.message));
    },
    (success) {
      if (success) {
        debugPrint('✅ BLoC: Successfully reassigned trip for delivery data: ${event.deliveryDataId}');
        emit(CancelledInvoiceTripReassigned(event.deliveryDataId));
      } else {
        debugPrint('❌ BLoC: Trip reassignment returned false');
        emit(const CancelledInvoiceError('Failed to reassign trip for cancelled invoice'));
      }
    },
  );
}



  Future<void> _onLoadCancelledInvoicesByTripId(
    LoadCancelledInvoicesByTripIdEvent event,
    Emitter<CancelledInvoiceState> emit,
  ) async {
    debugPrint('🔄 BLoC: Loading cancelled invoices for trip: ${event.tripId}');
    
    emit(const CancelledInvoiceLoading());

    final result = await _loadCancelledInvoicesByTripId(event.tripId);
    
    result.fold(
      (failure) {
        debugPrint('❌ BLoC: Failed to load cancelled invoices: ${failure.message}');
        emit(CancelledInvoiceError(failure.message));
      },
      (cancelledInvoices) {
        debugPrint('✅ BLoC: Loaded ${cancelledInvoices.length} cancelled invoices');
        
        if (cancelledInvoices.isEmpty) {
          emit(CancelledInvoicesEmpty(event.tripId));
        } else {
          final newState = CancelledInvoicesLoaded(
            cancelledInvoices,
          );
          emit(newState);
          _cachedState = newState;
        }
      },
    );
  }

  Future<void> _onLoadCancelledInvoicesById(
    LoadCancelledInvoicesByIdEvent event,
    Emitter<CancelledInvoiceState> emit,
  ) async {
    debugPrint('🔄 BLoC: Loading cancelled invoice by ID: ${event.id}');
    
    emit(const CancelledInvoiceLoading());

    final result = await _loadCancelledInvoicesById(event.id);
    
    result.fold(
      (failure) {
        debugPrint('❌ BLoC: Failed to load cancelled invoice by ID: ${failure.message}');
        emit(CancelledInvoiceError(failure.message));
      },
      (cancelledInvoice) {
        debugPrint('✅ BLoC: Loaded cancelled invoice by ID');
        emit(SpecificCancelledInvoiceLoaded(
          cancelledInvoice,
        ));
      },
    );
  }

  Future<void> _onCreateCancelledInvoiceByDeliveryDataId(
    CreateCancelledInvoiceByDeliveryDataIdEvent event,
    Emitter<CancelledInvoiceState> emit,
  ) async {
    debugPrint('🔄 BLoC: Creating cancelled invoice for delivery data: ${event.deliveryDataId}');
    debugPrint('📝 BLoC: Reason: ${event.reason.toString().split('.').last}');
    
    emit(const CancelledInvoiceLoading());

    final result = await _createCancelledInvoiceByDeliveryDataId(
      CreateCancelledInvoiceParams(
        deliveryDataId: event.deliveryDataId,
        reason: event.reason,
        image: event.image,
      ),
    );
    
    result.fold(
      (failure) {
        debugPrint('❌ BLoC: Failed to create cancelled invoice: ${failure.message}');
        emit(CancelledInvoiceError(failure.message));
      },
      (cancelledInvoice) {
        debugPrint('✅ BLoC: Successfully created cancelled invoice: ${cancelledInvoice.id}');
        emit(CancelledInvoiceCreated(cancelledInvoice));
      },
    );
  }

  Future<void> _onDeleteCancelledInvoice(
    DeleteCancelledInvoiceEvent event,
    Emitter<CancelledInvoiceState> emit,
  ) async {
    debugPrint('🗑️ BLoC: Deleting cancelled invoice: ${event.cancelledInvoiceId}');
    
    emit(const CancelledInvoiceLoading());

    final result = await _deleteCancelledInvoice(event.cancelledInvoiceId);
    
    result.fold(
      (failure) {
        debugPrint('❌ BLoC: Failed to delete cancelled invoice: ${failure.message}');
        emit(CancelledInvoiceError(failure.message));
      },
      (success) {
        if (success) {
          debugPrint('✅ BLoC: Successfully deleted cancelled invoice');
          emit(CancelledInvoiceDeleted(event.cancelledInvoiceId));
        } else {
          debugPrint('❌ BLoC: Failed to delete cancelled invoice');
          emit(const CancelledInvoiceError('Failed to delete cancelled invoice'));
        }
      },
    );
  }

  Future<void> _onRefreshCancelledInvoices(
    RefreshCancelledInvoicesEvent event,
    Emitter<CancelledInvoiceState> emit,
  ) async {
    debugPrint('🔄 BLoC: Refreshing cancelled invoices for trip: ${event.tripId}');
    
    // Don't emit loading state for refresh to avoid UI flicker
    final result = await _loadCancelledInvoicesByTripId(event.tripId);
    
    result.fold(
      (failure) {
        debugPrint('❌ BLoC: Refresh failed: ${failure.message}');
        // Keep current state if refresh fails
        if (_cachedState != null) {
          emit(_cachedState!);
        } else {
          emit(CancelledInvoiceError(failure.message));
        }
      },
      (cancelledInvoices) {
        debugPrint('✅ BLoC: Successfully refreshed ${cancelledInvoices.length} cancelled invoices');
        
        if (cancelledInvoices.isEmpty) {
          emit(CancelledInvoicesEmpty(event.tripId));
        } else {
          final newState = CancelledInvoicesLoaded(
            cancelledInvoices,
          );
          emit(newState);
          _cachedState = newState;
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
