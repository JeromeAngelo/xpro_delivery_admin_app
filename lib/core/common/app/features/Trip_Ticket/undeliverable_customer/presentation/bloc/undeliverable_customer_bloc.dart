import 'package:desktop_app/core/common/app/features/Trip_Ticket/undeliverable_customer/domain/usecases/create_undeliverable_customer.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/undeliverable_customer/domain/usecases/delete_all_undeliverable_customer.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/undeliverable_customer/domain/usecases/delete_undeliverable_customer.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/undeliverable_customer/domain/usecases/get_all_undeliverable_customer.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/undeliverable_customer/domain/usecases/get_undeliverable_customer.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/undeliverable_customer/domain/usecases/get_undeliverable_customer_by_id.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/undeliverable_customer/domain/usecases/set_undeliverable_reason.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/undeliverable_customer/domain/usecases/update_undeliverable_customer.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/undeliverable_customer/presentation/bloc/undeliverable_customer_event.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/undeliverable_customer/presentation/bloc/undeliverable_customer_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UndeliverableCustomerBloc
    extends Bloc<UndeliverableCustomerEvent, UndeliverableCustomerState> {
  final GetUndeliverableCustomers _getUndeliverableCustomers;
  final GetUndeliverableCustomerById _getUndeliverableCustomerById;
  final GetAllUndeliverableCustomers _getAllUndeliverableCustomers;
  final CreateUndeliverableCustomer _createUndeliverableCustomer;
  final UpdateUndeliverableCustomer _updateUndeliverableCustomer;
  final DeleteUndeliverableCustomer _deleteUndeliverableCustomer;
  final DeleteAllUndeliverableCustomers _deleteAllUndeliverableCustomers;
  final SetUndeliverableReason _setUndeliverableReason;

  UndeliverableCustomerState? _cachedState;

  UndeliverableCustomerBloc({
    required GetUndeliverableCustomers getUndeliverableCustomers,
    required GetUndeliverableCustomerById getUndeliverableCustomerById,
    required GetAllUndeliverableCustomers getAllUndeliverableCustomers,
    required CreateUndeliverableCustomer createUndeliverableCustomer,
    required UpdateUndeliverableCustomer updateUndeliverableCustomer,
    required DeleteUndeliverableCustomer deleteUndeliverableCustomer,
    required DeleteAllUndeliverableCustomers deleteAllUndeliverableCustomers,
    required SetUndeliverableReason setUndeliverableReason,
  })  : _getUndeliverableCustomers = getUndeliverableCustomers,
        _getUndeliverableCustomerById = getUndeliverableCustomerById,
        _getAllUndeliverableCustomers = getAllUndeliverableCustomers,
        _createUndeliverableCustomer = createUndeliverableCustomer,
        _updateUndeliverableCustomer = updateUndeliverableCustomer,
        _deleteUndeliverableCustomer = deleteUndeliverableCustomer,
        _deleteAllUndeliverableCustomers = deleteAllUndeliverableCustomers,
        _setUndeliverableReason = setUndeliverableReason,
        super(UndeliverableCustomerInitial()) {
    on<GetUndeliverableCustomersEvent>(_onGetUndeliverableCustomers);
    on<GetUndeliverableCustomerByIdEvent>(_onGetUndeliverableCustomerById);
    on<GetAllUndeliverableCustomersEvent>(_onGetAllUndeliverableCustomers);
    on<CreateUndeliverableCustomerEvent>(_onCreateUndeliverableCustomer);
    on<UpdateUndeliverableCustomerEvent>(_onUpdateUndeliverableCustomer);
    on<DeleteUndeliverableCustomerEvent>(_onDeleteUndeliverableCustomer);
    on<DeleteAllUndeliverableCustomersEvent>(_onDeleteAllUndeliverableCustomers);
    on<SetUndeliverableReasonEvent>(_onSetUndeliverableReason);
  }

  Future<void> _onGetUndeliverableCustomers(
    GetUndeliverableCustomersEvent event,
    Emitter<UndeliverableCustomerState> emit,
  ) async {
    debugPrint('🔄 Getting undeliverable customers for trip: ${event.tripId}');
    
    if (_cachedState is UndeliverableCustomerLoaded) {
      emit(_cachedState!);
    } else {
      emit(UndeliverableCustomerLoading());
    }

    final result = await _getUndeliverableCustomers(event.tripId);
    result.fold(
      (failure) {
        debugPrint('❌ Failed to get undeliverable customers: ${failure.message}');
        emit(UndeliverableCustomerError(failure.message));
      },
      (customers) {
        debugPrint('✅ Successfully retrieved ${customers.length} undeliverable customers');
        final newState = UndeliverableCustomerLoaded(customers);
        _cachedState = newState;
        emit(newState);
      },
    );
  }

  Future<void> _onGetUndeliverableCustomerById(
    GetUndeliverableCustomerByIdEvent event,
    Emitter<UndeliverableCustomerState> emit,
  ) async {
    debugPrint('🔄 Getting undeliverable customer by ID: ${event.customerId}');
    emit(UndeliverableCustomerLoading());

    final result = await _getUndeliverableCustomerById(event.customerId);
    result.fold(
      (failure) {
        debugPrint('❌ Failed to get undeliverable customer: ${failure.message}');
        emit(UndeliverableCustomerError(failure.message));
      },
      (customer) {
        debugPrint('✅ Successfully retrieved undeliverable customer');
        emit(UndeliverableCustomerByIdLoaded(customer));
      },
    );
  }

  Future<void> _onGetAllUndeliverableCustomers(
    GetAllUndeliverableCustomersEvent event,
    Emitter<UndeliverableCustomerState> emit,
  ) async {
    debugPrint('🔄 Getting all undeliverable customers');
    emit(UndeliverableCustomerLoading());

    final result = await _getAllUndeliverableCustomers();
    result.fold(
      (failure) {
        debugPrint('❌ Failed to get all undeliverable customers: ${failure.message}');
        emit(UndeliverableCustomerError(failure.message));
      },
      (customers) {
        debugPrint('✅ Successfully retrieved ${customers.length} undeliverable customers');
        emit(AllUndeliverableCustomersLoaded(customers));
      },
    );
  }

  Future<void> _onCreateUndeliverableCustomer(
    CreateUndeliverableCustomerEvent event,
    Emitter<UndeliverableCustomerState> emit,
  ) async {
    debugPrint('🔄 Creating undeliverable customer record');
    emit(UndeliverableCustomerLoading());

    final params = CreateUndeliverableCustomerParams(
      undeliverableCustomer: event.customer,
      customerId: event.customerId,
    );

    final result = await _createUndeliverableCustomer(params);
    result.fold(
      (failure) {
        debugPrint('❌ Failed to create undeliverable customer: ${failure.message}');
        emit(UndeliverableCustomerError(failure.message));
      },
      (customer) {
        debugPrint('✅ Undeliverable customer created successfully');
        emit(UndeliverableCustomerCreated(customer));
        // Refresh the list
        add(GetUndeliverableCustomersEvent(event.customerId));
      },
    );
  }

  Future<void> _onUpdateUndeliverableCustomer(
    UpdateUndeliverableCustomerEvent event,
    Emitter<UndeliverableCustomerState> emit,
  ) async {
    debugPrint('🔄 Updating undeliverable customer');
    emit(UndeliverableCustomerLoading());

    final params = UpdateUndeliverableCustomerParams(
      undeliverableCustomer: event.customer,
      customerId: event.customerId, 
    );

    final result = await _updateUndeliverableCustomer(params);
    result.fold(
      (failure) {
        debugPrint('❌ Failed to update undeliverable customer: ${failure.message}');
        emit(UndeliverableCustomerError(failure.message));
      },
      (customer) {
        debugPrint('✅ Undeliverable customer updated successfully');
        emit(UndeliverableCustomerUpdated(customer));
        // Refresh the list
        add(GetUndeliverableCustomersEvent(event.customerId));
      },
    );
  }

  Future<void> _onDeleteUndeliverableCustomer(
    DeleteUndeliverableCustomerEvent event,
    Emitter<UndeliverableCustomerState> emit,
  ) async {
    debugPrint('🔄 Deleting undeliverable customer: ${event.customerId}');
    emit(UndeliverableCustomerLoading());

    final result = await _deleteUndeliverableCustomer(event.customerId);
    result.fold(
      (failure) {
        debugPrint('❌ Failed to delete undeliverable customer: ${failure.message}');
        emit(UndeliverableCustomerError(failure.message));
      },
      (_) {
        debugPrint('✅ Undeliverable customer deleted successfully');
        emit(UndeliverableCustomerDeleted(event.customerId));
        // Clear cached state
        _cachedState = null;
      },
    );
  }

  Future<void> _onDeleteAllUndeliverableCustomers(
    DeleteAllUndeliverableCustomersEvent event,
    Emitter<UndeliverableCustomerState> emit,
  ) async {
    debugPrint('🔄 Deleting all undeliverable customers');
    emit(UndeliverableCustomerLoading());

    final result = await _deleteAllUndeliverableCustomers();
    result.fold(
      (failure) {
        debugPrint('❌ Failed to delete all undeliverable customers: ${failure.message}');
        emit(UndeliverableCustomerError(failure.message));
      },
      (_) {
        debugPrint('✅ All undeliverable customers deleted successfully');
        emit(AllUndeliverableCustomersDeleted());
        // Clear cached state
        _cachedState = null;
      },
    );
  }

  Future<void> _onSetUndeliverableReason(
    SetUndeliverableReasonEvent event,
    Emitter<UndeliverableCustomerState> emit,
  ) async {
    debugPrint('🔄 Setting undeliverable reason for customer: ${event.customerId}');
    emit(UndeliverableCustomerLoading());

    final params = SetUndeliverableReasonParams(
      customerId: event.customerId,
      reason: event.reason,
    );
    
    final result = await _setUndeliverableReason(params);
    result.fold(
      (failure) {
        debugPrint('❌ Failed to set undeliverable reason: ${failure.message}');
        emit(UndeliverableCustomerError(failure.message));
      },
      (customer) {
        debugPrint('✅ Undeliverable reason set successfully');
        emit(UndeliverableReasonSet(customer));
        // Refresh the customer details
        add(GetUndeliverableCustomerByIdEvent(event.customerId));
      },
    );
  }

  @override
  Future<void> close() {
    _cachedState = null;
    return super.close();
  }
}
