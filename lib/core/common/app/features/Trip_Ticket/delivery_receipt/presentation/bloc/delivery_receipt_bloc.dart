import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/delivery_receipt/presentation/bloc/delivery_receipt_event.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/delivery_receipt/presentation/bloc/delivery_receipt_state.dart';

import '../../domain/entity/delivery_receipt_entity.dart';
import '../../domain/usecases/create_delivery_receipt.dart';
import '../../domain/usecases/delete_delivery_receipt.dart';
import '../../domain/usecases/generate_pdf.dart';
import '../../domain/usecases/get_delivery_receipt_by_delivery_data_id.dart' show GetDeliveryReceiptByDeliveryDataId;
import '../../domain/usecases/get_delivery_receipt_by_trip_id.dart';

class DeliveryReceiptBloc extends Bloc<DeliveryReceiptEvent, DeliveryReceiptState> {
  final GetDeliveryReceiptByTripId _getDeliveryReceiptByTripId;
  final GetDeliveryReceiptByDeliveryDataId _getDeliveryReceiptByDeliveryDataId;
  final CreateDeliveryReceipt _createDeliveryReceipt;
  final DeleteDeliveryReceipt _deleteDeliveryReceipt;
  final GenerateDeliveryReceiptPdf _generateDeliveryReceiptPdf;

  DeliveryReceiptState? _cachedState;

  DeliveryReceiptBloc({
    required GetDeliveryReceiptByTripId getDeliveryReceiptByTripId,
    required GetDeliveryReceiptByDeliveryDataId getDeliveryReceiptByDeliveryDataId,
    required CreateDeliveryReceipt createDeliveryReceipt,
    required DeleteDeliveryReceipt deleteDeliveryReceipt,
    required GenerateDeliveryReceiptPdf generateDeliveryReceiptPdf,
  })  : _getDeliveryReceiptByTripId = getDeliveryReceiptByTripId,
        _getDeliveryReceiptByDeliveryDataId = getDeliveryReceiptByDeliveryDataId,
        _createDeliveryReceipt = createDeliveryReceipt,
        _deleteDeliveryReceipt = deleteDeliveryReceipt,
        _generateDeliveryReceiptPdf = generateDeliveryReceiptPdf,
        super(const DeliveryReceiptInitial()) {
    
    on<GetDeliveryReceiptByTripIdEvent>(_onGetDeliveryReceiptByTripId);
    on<GetDeliveryReceiptByDeliveryDataIdEvent>(_onGetDeliveryReceiptByDeliveryDataId);
    on<CreateDeliveryReceiptEvent>(_onCreateDeliveryReceipt);
    on<DeleteDeliveryReceiptEvent>(_onDeleteDeliveryReceipt);
    on<GenerateDeliveryReceiptPdfEvent>(_onGenerateDeliveryReceiptPdf);
  }

  Future<void> _onGetDeliveryReceiptByTripId(
    GetDeliveryReceiptByTripIdEvent event,
    Emitter<DeliveryReceiptState> emit,
  ) async {
    debugPrint('🔄 BLoC: Getting delivery receipt by trip ID: ${event.tripId}');

    // Emit cached state if available, then loading
    if (_cachedState != null && _cachedState is DeliveryReceiptLoaded) {
      emit(_cachedState!);
    } else {
      emit(const DeliveryReceiptLoading());
    }

    final result = await _getDeliveryReceiptByTripId(event.tripId);
    
    result.fold(
      (failure) {
        debugPrint('❌ BLoC: Failed to get delivery receipt by trip ID: ${failure.message}');
        
        if (failure.message.contains('404') || failure.message.contains('not found')) {
          emit(DeliveryReceiptNotFound(
            searchId: event.tripId,
            searchType: 'tripId',
          ));
        } else {
          emit(DeliveryReceiptError(
            message: failure.message,
            errorCode: failure.statusCode,
          ));
        }
      },
      (deliveryReceipt) {
        debugPrint('✅ BLoC: Successfully retrieved delivery receipt by trip ID');
        final newState = DeliveryReceiptLoaded(
          deliveryReceipt: deliveryReceipt,
          isFromCache: false,
        );
        _cachedState = newState;
        emit(newState);
      },
    );
  }

  Future<void> _onGetDeliveryReceiptByDeliveryDataId(
    GetDeliveryReceiptByDeliveryDataIdEvent event,
    Emitter<DeliveryReceiptState> emit,
  ) async {
    debugPrint('🔄 BLoC: Getting delivery receipt by delivery data ID: ${event.deliveryDataId}');

    // Emit cached state if available, then loading
    if (_cachedState != null && _cachedState is DeliveryReceiptLoaded) {
      emit(_cachedState!);
    } else {
      emit(const DeliveryReceiptLoading());
    }

    final result = await _getDeliveryReceiptByDeliveryDataId(event.deliveryDataId);
    
    result.fold(
      (failure) {
        debugPrint('❌ BLoC: Failed to get delivery receipt by delivery data ID: ${failure.message}');
        
        if (failure.message.contains('404') || failure.message.contains('not found')) {
          emit(DeliveryReceiptNotFound(
            searchId: event.deliveryDataId,
            searchType: 'deliveryDataId',
          ));
        } else {
          emit(DeliveryReceiptError(
            message: failure.message,
            errorCode: failure.statusCode,
          ));
        }
      },
      (deliveryReceipt) {
        debugPrint('✅ BLoC: Successfully retrieved delivery receipt by delivery data ID');
        final newState = DeliveryReceiptLoaded(
          deliveryReceipt: deliveryReceipt,
          isFromCache: false,
        );
        _cachedState = newState;
        emit(newState);
      },
    );
  }

  Future<void> _onCreateDeliveryReceipt(
    CreateDeliveryReceiptEvent event,
    Emitter<DeliveryReceiptState> emit,
  ) async {
    debugPrint('🔄 BLoC: Creating delivery receipt for delivery data: ${event.deliveryDataId}');
    debugPrint('📝 BLoC: Status: ${event.status}');
    debugPrint('📸 BLoC: Customer images count: ${event.customerImages?.length ?? 0}');
    debugPrint('✍️ BLoC: Has signature: ${event.customerSignature?.isNotEmpty ?? false}');
    debugPrint('📄 BLoC: Has receipt file: ${event.receiptFile?.isNotEmpty ?? false}');
    
    emit(const DeliveryReceiptLoading());

    final result = await _createDeliveryReceipt(
      CreateDeliveryReceiptParams(
        deliveryDataId: event.deliveryDataId,
        status: event.status,
        dateTimeCompleted: event.dateTimeCompleted,
        customerImages: event.customerImages,
        customerSignature: event.customerSignature,
        receiptFile: event.receiptFile,
      ),
    );

    result.fold(
      (failure) {
        debugPrint('❌ BLoC: Failed to create delivery receipt: ${failure.message}');
        emit(DeliveryReceiptError(
          message: failure.message,
          errorCode: failure.statusCode,
        ));
      },
      (deliveryReceipt) {
        debugPrint('✅ BLoC: Successfully created delivery receipt: ${deliveryReceipt.id}');
        
        // Emit success state for immediate UI navigation
        final newState = DeliveryReceiptCreated(
          deliveryReceipt: deliveryReceipt,
          deliveryDataId: event.deliveryDataId,
        );
        emit(newState);
        
        // Update cached state for future use
        _cachedState = DeliveryReceiptLoaded(
          deliveryReceipt: deliveryReceipt,
          isFromCache: false,
        );
        
        debugPrint('📱 BLoC: UI can now navigate immediately');
      },
    );
  }

  Future<void> _onDeleteDeliveryReceipt(
    DeleteDeliveryReceiptEvent event,
    Emitter<DeliveryReceiptState> emit,
  ) async {
    debugPrint('🗑️ BLoC: Deleting delivery receipt: ${event.receiptId}');
    
    emit(const DeliveryReceiptLoading());

    final result = await _deleteDeliveryReceipt(event.receiptId);

    result.fold(
      (failure) {
        debugPrint('❌ BLoC: Failed to delete delivery receipt: ${failure.message}');
        emit(DeliveryReceiptError(
          message: failure.message,
          errorCode: failure.statusCode,
        ));
      },
      (success) {
        if (success) {
          debugPrint('✅ BLoC: Successfully deleted delivery receipt');
          emit(DeliveryReceiptDeleted(event.receiptId));
          
          // Clear cached state if it matches the deleted receipt
          if (_cachedState is DeliveryReceiptLoaded) {
            final loadedState = _cachedState as DeliveryReceiptLoaded;
            if (loadedState.deliveryReceipt.id == event.receiptId) {
              _cachedState = null;
            }
          }
        } else {
          debugPrint('⚠️ BLoC: Delivery receipt deletion returned false');
          emit(const DeliveryReceiptError(
            message: 'Failed to delete delivery receipt',
            errorCode: '500',
          ));
        }
      },
    );
  }

  Future<void> _onGenerateDeliveryReceiptPdf(
    GenerateDeliveryReceiptPdfEvent event,
    Emitter<DeliveryReceiptState> emit,
  ) async {
    debugPrint('📄 BLoC: Generating delivery receipt PDF for: ${event.deliveryData.id}');
    
    emit(DeliveryReceiptPdfGenerating(event.deliveryData.id ?? ''));

    final result = await _generateDeliveryReceiptPdf(event.deliveryData);
    
    result.fold(
      (failure) {
        debugPrint('❌ BLoC: Failed to generate delivery receipt PDF: ${failure.message}');
        emit(DeliveryReceiptError(
          message: failure.message,
          errorCode: failure.statusCode,
        ));
      },
      (pdfBytes) {
        debugPrint('✅ BLoC: Successfully generated delivery receipt PDF');
        debugPrint('📊 BLoC: PDF size: ${pdfBytes.length} bytes');
        emit(DeliveryReceiptPdfGenerated(
          pdfBytes: pdfBytes,
          deliveryDataId: event.deliveryData.id ?? '',
        ));
      },
    );
  }


  /// Helper method to check if we have cached data
  bool get hasCachedData => _cachedState is DeliveryReceiptLoaded;

  /// Helper method to get cached delivery receipt
  DeliveryReceiptEntity? get cachedDeliveryReceipt {
    if (_cachedState is DeliveryReceiptLoaded) {
      return (_cachedState as DeliveryReceiptLoaded).deliveryReceipt;
    }
    return null;
  }

  /// Helper method to clear cache
  void clearCache() {
    debugPrint('🗑️ BLoC: Clearing delivery receipt cache');
    _cachedState = null;
  }

    @override
  Future<void> close() {
    debugPrint('🔄 BLoC: Closing DeliveryReceiptBloc and clearing cache');
    _cachedState = null;
    return super.close();
  }
}
