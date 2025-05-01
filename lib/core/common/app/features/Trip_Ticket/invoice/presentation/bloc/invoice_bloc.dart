import 'package:bloc/bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/invoice/domain/entity/invoice_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/invoice/domain/usecase/create_invoice.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/invoice/domain/usecase/delete_all_invoices.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/invoice/domain/usecase/delete_invoice.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/invoice/domain/usecase/get_invoice.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/invoice/domain/usecase/get_invoice_by_id.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/invoice/domain/usecase/get_invoice_per_customer.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/invoice/domain/usecase/get_invoice_per_trip_id.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/invoice/domain/usecase/get_invoices_by_completed_customer_id.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/invoice/domain/usecase/update_invoice.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/invoice/presentation/bloc/invoice_event.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/invoice/presentation/bloc/invoice_state.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/products/presentation/bloc/products_bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/products/presentation/bloc/products_event.dart';
import 'package:xpro_delivery_admin_app/core/enums/invoice_status.dart';
import 'package:flutter/material.dart';

class InvoiceBloc extends Bloc<InvoiceEvent, InvoiceState> {
  final ProductsBloc _productsBloc;
  final GetInvoice _getInvoices;
  final GetInvoicesByTrip _getInvoicesByTrip;
  final GetInvoicesByCustomer _getInvoicesByCustomer;
  final CreateInvoice _createInvoice;
  final UpdateInvoice _updateInvoice;
  final DeleteInvoice _deleteInvoice;
  final DeleteAllInvoices _deleteAllInvoices;
  final GetInvoiceById _getInvoiceById;
  final GetInvoicesByCompletedCustomerId _getInvoicesByCompletedCustomerId;
  
  InvoiceState? _cachedState;

   final Map<String, List<InvoiceEntity>> _tripInvoicesCache = {};

// Update the constructor to initialize the field
InvoiceBloc({
  required ProductsBloc productsBloc,
  required GetInvoicesByCompletedCustomerId getInvoicesByCompletedCustomerId,
  required GetInvoice getInvoices,
  required GetInvoicesByTrip getInvoicesByTrip,
  required GetInvoicesByCustomer getInvoicesByCustomer,
  required CreateInvoice createInvoice,
  required UpdateInvoice updateInvoice,
  required DeleteInvoice deleteInvoice,
  required DeleteAllInvoices deleteAllInvoices,
  required GetInvoiceById getInvoiceById,  // New parameter
}) : _productsBloc = productsBloc,
     _getInvoices = getInvoices,
     _getInvoicesByTrip = getInvoicesByTrip,
     _getInvoicesByCustomer = getInvoicesByCustomer,
     _createInvoice = createInvoice,
     _updateInvoice = updateInvoice,
     _deleteInvoice = deleteInvoice,
     _deleteAllInvoices = deleteAllInvoices,
     _getInvoicesByCompletedCustomerId = getInvoicesByCompletedCustomerId,
     _getInvoiceById = getInvoiceById,  // Initialize the field
     super(InvoiceInitial()) {
  on<GetInvoiceEvent>(_onGetInvoiceHandler);
  on<GetInvoicesByTripEvent>(_onGetInvoicesByTripHandler);
  on<GetInvoicesByCustomerEvent>(_onGetInvoicesByCustomerHandler);
  on<CreateInvoiceEvent>(_onCreateInvoiceHandler);
  on<UpdateInvoiceEvent>(_onUpdateInvoiceHandler);
  on<DeleteInvoiceEvent>(_onDeleteInvoiceHandler);
  on<DeleteAllInvoicesEvent>(_onDeleteAllInvoicesHandler);
  on<RefreshInvoiceEvent>(_onRefreshInvoiceHandler);
  on<GetInvoiceByIdEvent>(_onGetInvoiceByIdHandler);  // Register the new event handler
  on<GetInvoicesByCompletedCustomerEvent>(_onGetInvoicesByCompletedCustomer);
}

Future<void> _onGetInvoicesByCompletedCustomer(
  GetInvoicesByCompletedCustomerEvent event,
  Emitter<InvoiceState> emit,
) async {
  debugPrint('🔄 BLOC: Fetching invoices for completed customer: ${event.completedCustomerId}');
  emit(InvoiceLoading());

  final result = await _getInvoicesByCompletedCustomerId(event.completedCustomerId);
  
  result.fold(
    (failure) {
      debugPrint('❌ BLOC: Failed to get invoices for completed customer: ${failure.message}');
      emit(InvoiceError(failure.message));
    },
    (invoices) {
      debugPrint('✅ BLOC: Successfully retrieved ${invoices.length} invoices for completed customer');
      emit(CompletedCustomerInvoicesLoaded(invoices, event.completedCustomerId));
    },
  );
}


// Add the new event handler method
Future<void> _onGetInvoiceByIdHandler(
  GetInvoiceByIdEvent event,
  Emitter<InvoiceState> emit,
) async {
  emit(InvoiceLoading());
  debugPrint('🔄 BLOC: Fetching invoice by ID: ${event.id}');
  
  final result = await _getInvoiceById(event.id);
  
  result.fold(
    (failure) {
      debugPrint('❌ BLOC: Failed to get invoice: ${failure.message}');
      emit(InvoiceError(failure.message));
    },
    (invoice) {
      debugPrint('✅ BLOC: Successfully fetched invoice: ${invoice.id}');
      emit(SingleInvoiceLoaded(invoice));
      
      // Also load products for this invoice
      if (invoice.productList.isNotEmpty) {
        _productsBloc.add(GetProductsByInvoiceIdEvent(invoice.id!));
      }
    },
  );
}
 Future<void> _onGetInvoiceHandler(
    GetInvoiceEvent event,
    Emitter<InvoiceState> emit,
  ) async {
    // Check if we have a cached TripInvoicesLoaded state and preserve it
    if (state is TripInvoicesLoaded) {
      final tripState = state as TripInvoicesLoaded;
      _tripInvoicesCache[tripState.tripId] = tripState.invoices;
      debugPrint('📦 Cached ${tripState.invoices.length} invoices for trip ${tripState.tripId}');
    }

    if (_cachedState != null) {
      emit(_cachedState!);
    } else {
      emit(InvoiceLoading());
    }
    
    _productsBloc.add(const GetProductsEvent());

    final result = await _getInvoices();
    result.fold(
      (failure) => emit(InvoiceError(failure.message)),
      (invoices) {
        final newState = InvoiceLoaded(invoices);
        _cachedState = newState;
        emit(newState);
        
        // If we were previously viewing trip invoices, restore that state
        if (_tripInvoicesCache.isNotEmpty) {
          final entries = _tripInvoicesCache.entries.toList();
          if (entries.isNotEmpty) {
            final lastTripId = entries.last.key;
            final cachedInvoices = entries.last.value;
            debugPrint('🔄 Restoring cached view of ${cachedInvoices.length} invoices for trip $lastTripId');
            emit(TripInvoicesLoaded(cachedInvoices, lastTripId));
          }
        }
      },
    );
  }

 
  Future<void> _onGetInvoicesByTripHandler(
    GetInvoicesByTripEvent event,
    Emitter<InvoiceState> emit,
  ) async {
    emit(InvoiceLoading());
    debugPrint('🔄 BLOC: Fetching invoices for trip: ${event.tripId}');
    
    final result = await _getInvoicesByTrip(event.tripId);
    result.fold(
      (failure) {
        debugPrint('❌ BLOC: Failed to get trip invoices: ${failure.message}');
        emit(InvoiceError(failure.message));
      },
      (invoices) {
        debugPrint('✅ BLOC: Successfully fetched ${invoices.length} invoices for trip: ${event.tripId}');
        // Cache the trip invoices
        _tripInvoicesCache[event.tripId] = invoices;
        emit(TripInvoicesLoaded(invoices, event.tripId));
      },
    );
  }



  // Make sure this method is correctly implemented
Future<void> _onGetInvoicesByCustomerHandler(
  GetInvoicesByCustomerEvent event,
  Emitter<InvoiceState> emit,
) async {
  emit(InvoiceLoading());
  debugPrint('🔄 BLOC: Fetching invoices for customer: ${event.customerId}');
  
  final result = await _getInvoicesByCustomer(event.customerId);
  result.fold(
    (failure) {
      debugPrint('❌ BLOC: Failed to get customer invoices: ${failure.message}');
      emit(InvoiceError(failure.message));
    },
    (invoices) {
      debugPrint('✅ BLOC: Successfully fetched ${invoices.length} invoices for customer');
      emit(CustomerInvoicesLoaded(invoices, event.customerId));
    },
  );
}


  Future<void> _onCreateInvoiceHandler(
    CreateInvoiceEvent event,
    Emitter<InvoiceState> emit,
  ) async {
    emit(InvoiceLoading());
    debugPrint('🔄 Creating new invoice: ${event.invoiceNumber}');
    
    final result = await _createInvoice(
      CreateInvoiceParams(
        invoiceNumber: event.invoiceNumber,
        customerId: event.customerId,
        tripId: event.tripId,
        productIds: event.productIds,
        status: event.status ?? InvoiceStatus.truck,
        totalAmount: event.totalAmount,
        confirmTotalAmount: event.confirmTotalAmount,
        customerDeliveryStatus: event.customerDeliveryStatus,
      ),
    );
    
    result.fold(
      (failure) {
        debugPrint('❌ Invoice creation failed: ${failure.message}');
        emit(InvoiceError(failure.message));
      },
      (invoice) {
        debugPrint('✅ Invoice created successfully: ${invoice.id}');
        emit(InvoiceCreated(invoice));
        
        // Refresh the list after creation
        add(const GetInvoiceEvent());
      },
    );
  }

  Future<void> _onUpdateInvoiceHandler(
    UpdateInvoiceEvent event,
    Emitter<InvoiceState> emit,
  ) async {
    emit(InvoiceLoading());
    debugPrint('🔄 Updating invoice: ${event.id}');
    
    final result = await _updateInvoice(
      UpdateInvoiceParams(
        id: event.id,
        invoiceNumber: event.invoiceNumber,
        customerId: event.customerId,
        tripId: event.tripId,
        productIds: event.productIds,
        status: event.status,
        totalAmount: event.totalAmount,
        confirmTotalAmount: event.confirmTotalAmount,
        customerDeliveryStatus: event.customerDeliveryStatus,
      ),
    );
    
    result.fold(
      (failure) {
        debugPrint('❌ Invoice update failed: ${failure.message}');
        emit(InvoiceError(failure.message));
      },
      (invoice) {
        debugPrint('✅ Invoice updated successfully: ${invoice.id}');
        emit(InvoiceUpdated(invoice));
        
        // Refresh the list after update
        if (event.tripId != null) {
          add(GetInvoicesByTripEvent(event.tripId!));
        } else if (event.customerId != null) {
          add(GetInvoicesByCustomerEvent(event.customerId!));
        } else {
          add(const GetInvoiceEvent());
        }
      },
    );
  }

  Future<void> _onDeleteInvoiceHandler(
    DeleteInvoiceEvent event,
    Emitter<InvoiceState> emit,
  ) async {
    emit(InvoiceLoading());
    debugPrint('🔄 Deleting invoice: ${event.id}');
    
    final result = await _deleteInvoice(event.id);
    
    result.fold(
      (failure) {
        debugPrint('❌ Invoice deletion failed: ${failure.message}');
        emit(InvoiceError(failure.message));
      },
      (_) {
        debugPrint('✅ Invoice deleted successfully');
        emit(InvoiceDeleted(event.id));
        
        // Refresh the list after deletion
        add(const GetInvoiceEvent());
      },
    );
  }

  Future<void> _onDeleteAllInvoicesHandler(
    DeleteAllInvoicesEvent event,
    Emitter<InvoiceState> emit,
  ) async {
    emit(InvoiceLoading());
    debugPrint('🔄 Deleting multiple invoices: ${event.ids.length} items');
    
    final result = await _deleteAllInvoices(event.ids);
    
    result.fold(
      (failure) {
        debugPrint('❌ Bulk invoice deletion failed: ${failure.message}');
        emit(InvoiceError(failure.message));
      },
      (_) {
        debugPrint('✅ All invoices deleted successfully');
        emit(InvoicesDeleted(event.ids));
        
        // Refresh the list after deletion
        add(const GetInvoiceEvent());
      },
    );
  }

 
  // Modify other event handlers to preserve trip invoice state
  Future<void> _onRefreshInvoiceHandler(
    RefreshInvoiceEvent event,
    Emitter<InvoiceState> emit,
  ) async {
    // Save current trip state if applicable
    if (state is TripInvoicesLoaded) {
      final tripState = state as TripInvoicesLoaded;
      _tripInvoicesCache[tripState.tripId] = tripState.invoices;
    }
    
    emit(InvoiceRefreshing());
    
    final result = await _getInvoices();
    result.fold(
      (failure) => emit(InvoiceError(failure.message)),
      (invoices) {
        final newState = InvoiceLoaded(invoices);
        _cachedState = newState;
        emit(newState);
        
        // Restore trip state if we were viewing trip invoices
        if (_tripInvoicesCache.isNotEmpty) {
          final entries = _tripInvoicesCache.entries.toList();
          if (entries.isNotEmpty) {
            final lastTripId = entries.last.key;
            final cachedInvoices = entries.last.value;
            emit(TripInvoicesLoaded(cachedInvoices, lastTripId));
          }
        }
      },
    );
  }

   @override
  Future<void> close() {
    _cachedState = null;
    _tripInvoicesCache.clear();
    return super.close();
  }
}
