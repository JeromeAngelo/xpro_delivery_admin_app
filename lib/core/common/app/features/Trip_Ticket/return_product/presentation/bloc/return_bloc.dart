import 'package:bloc/bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/return_product/domain/usecase/create_returns.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/return_product/domain/usecase/delete_all_return.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/return_product/domain/usecase/delete_return.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/return_product/domain/usecase/get_all_returns.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/return_product/domain/usecase/get_return_by_customerId.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/return_product/domain/usecase/get_return_usecase.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/return_product/domain/usecase/update_returns.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/return_product/presentation/bloc/return_event.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/return_product/presentation/bloc/return_state.dart';
import 'package:flutter/widgets.dart';

class ReturnBloc extends Bloc<ReturnEvent, ReturnState> {
  final GetReturnUsecase _getReturns;
  final GetReturnByCustomerId _getReturnByCustomerId;
  final GetAllReturns _getAllReturns;
  final CreateReturn _createReturn;
  final UpdateReturn _updateReturn;
  final DeleteReturn _deleteReturn;
  final DeleteAllReturns _deleteAllReturns;
  
  ReturnState? _cachedState;

  ReturnBloc({
    required GetReturnUsecase getReturns,
    required GetReturnByCustomerId getReturnByCustomerId,
    required GetAllReturns getAllReturns,
    required CreateReturn createReturn,
    required UpdateReturn updateReturn,
    required DeleteReturn deleteReturn,
    required DeleteAllReturns deleteAllReturns,
  })  : _getReturns = getReturns,
        _getReturnByCustomerId = getReturnByCustomerId,
        _getAllReturns = getAllReturns,
        _createReturn = createReturn,
        _updateReturn = updateReturn,
        _deleteReturn = deleteReturn,
        _deleteAllReturns = deleteAllReturns,
        super(const ReturnInitial()) {
    on<GetReturnsEvent>(_onGetReturnsHandler);
    on<GetReturnByCustomerIdEvent>(_onGetReturnByCustomerIdHandler);
    on<GetAllReturnsEvent>(_onGetAllReturnsHandler);
    on<CreateReturnEvent>(_onCreateReturnHandler);
    on<UpdateReturnEvent>(_onUpdateReturnHandler);
    on<DeleteReturnEvent>(_onDeleteReturnHandler);
    on<DeleteAllReturnsEvent>(_onDeleteAllReturnsHandler);
  }

  Future<void> _onGetReturnsHandler(
    GetReturnsEvent event,
    Emitter<ReturnState> emit,
  ) async {
    if (_cachedState != null) {
      emit(_cachedState!);
    } else {
      emit(const ReturnLoading());
    }

    final result = await _getReturns(event.tripId);
    
    result.fold(
      (failure) {
        debugPrint('❌ Failed to load returns: ${failure.message}');
        emit(ReturnError(failure.message));
      },
      (returns) {
        debugPrint('✅ Loaded ${returns.length} returns for trip: ${event.tripId}');
        final newState = ReturnLoaded(returns);
        _cachedState = newState;
        emit(newState);
      },
    );
  }

  Future<void> _onGetReturnByCustomerIdHandler(
    GetReturnByCustomerIdEvent event,
    Emitter<ReturnState> emit,
  ) async {
    emit(const ReturnLoading());
    final result = await _getReturnByCustomerId(event.customerId);
    result.fold(
      (failure) => emit(ReturnError(failure.message)),
      (returnItem) => emit(ReturnByCustomerLoaded(returnItem)),
    );
  }

  Future<void> _onGetAllReturnsHandler(
    GetAllReturnsEvent event,
    Emitter<ReturnState> emit,
  ) async {
    emit(const ReturnLoading());
    debugPrint('🔄 Loading all returns');
    
    final result = await _getAllReturns();
    result.fold(
      (failure) {
        debugPrint('❌ Failed to load all returns: ${failure.message}');
        emit(ReturnError(failure.message));
      },
      (returns) {
        debugPrint('✅ Loaded ${returns.length} returns');
        emit(AllReturnsLoaded(returns));
      },
    );
  }

  Future<void> _onCreateReturnHandler(
    CreateReturnEvent event,
    Emitter<ReturnState> emit,
  ) async {
    emit(const ReturnLoading());
    debugPrint('🔄 Creating new return for product: ${event.productName}');
    
    final params = CreateReturnParams(
      productName: event.productName,
      productDescription: event.productDescription,
      reason: event.reason,
      returnDate: event.returnDate,
      productQuantityCase: event.productQuantityCase,
      productQuantityPcs: event.productQuantityPcs,
      productQuantityPack: event.productQuantityPack,
      productQuantityBox: event.productQuantityBox,
      isCase: event.isCase,
      isPcs: event.isPcs,
      isBox: event.isBox,
      isPack: event.isPack,
      invoiceId: event.invoiceId,
      customerId: event.customerId,
      tripId: event.tripId,
    );
    
    final result = await _createReturn(params);
    result.fold(
      (failure) {
        debugPrint('❌ Return creation failed: ${failure.message}');
        emit(ReturnError(failure.message));
      },
      (returnItem) {
        debugPrint('✅ Return created successfully: ${returnItem.id}');
        emit(ReturnCreated(returnItem));
        
        // Refresh the list after creation
        if (event.tripId != null) {
          add(GetReturnsEvent(event.tripId!));
        } else {
          add(const GetAllReturnsEvent());
        }
      },
    );
  }

  Future<void> _onUpdateReturnHandler(
    UpdateReturnEvent event,
    Emitter<ReturnState> emit,
  ) async {
    emit(const ReturnLoading());
    debugPrint('🔄 Updating return: ${event.id}');
    
    final params = UpdateReturnParams(
      id: event.id,
      productName: event.productName,
      productDescription: event.productDescription,
      reason: event.reason,
      returnDate: event.returnDate,
      productQuantityCase: event.productQuantityCase,
      productQuantityPcs: event.productQuantityPcs,
      productQuantityPack: event.productQuantityPack,
      productQuantityBox: event.productQuantityBox,
      isCase: event.isCase,
      isPcs: event.isPcs,
      isBox: event.isBox,
      isPack: event.isPack,
      invoiceId: event.invoiceId,
      customerId: event.customerId,
      tripId: event.tripId,
    );
    
    final result = await _updateReturn(params);
    result.fold(
      (failure) {
        debugPrint('❌ Return update failed: ${failure.message}');
        emit(ReturnError(failure.message));
      },
      (returnItem) {
        debugPrint('✅ Return updated successfully: ${returnItem.id}');
        emit(ReturnUpdated(returnItem));
        
        // Refresh the list after update
        if (event.tripId != null) {
          add(GetReturnsEvent(event.tripId!));
        } else if (event.customerId != null) {
          add(GetReturnByCustomerIdEvent(event.customerId!));
        } else {
          add(const GetAllReturnsEvent());
        }
      },
    );
  }

  Future<void> _onDeleteReturnHandler(
    DeleteReturnEvent event,
    Emitter<ReturnState> emit,
  ) async {
    emit(const ReturnLoading());
    debugPrint('🔄 Deleting return: ${event.id}');
    
    final result = await _deleteReturn(event.id);
    result.fold(
      (failure) {
        debugPrint('❌ Return deletion failed: ${failure.message}');
        emit(ReturnError(failure.message));
      },
      (_) {
        debugPrint('✅ Return deleted successfully');
        emit(ReturnDeleted(event.id));
        
        // Refresh the list after deletion
        add(const GetAllReturnsEvent());
      },
    );
  }

  Future<void> _onDeleteAllReturnsHandler(
    DeleteAllReturnsEvent event,
    Emitter<ReturnState> emit,
  ) async {
    emit(const ReturnLoading());
    debugPrint('🔄 Deleting multiple returns: ${event.ids.length} items');
    
    final result = await _deleteAllReturns(event.ids);
    result.fold(
      (failure) {
        debugPrint('❌ Bulk return deletion failed: ${failure.message}');
        emit(ReturnError(failure.message));
      },
      (_) {
        debugPrint('✅ All returns deleted successfully');
        emit(ReturnsDeleted(event.ids));
        
        // Refresh the list after deletion
        add(const GetAllReturnsEvent());
      },
    );
  }

  @override
  Future<void> close() {
    _cachedState = null;
    return super.close();
  }
}
