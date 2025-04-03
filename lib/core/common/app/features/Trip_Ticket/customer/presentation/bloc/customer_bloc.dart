import 'package:desktop_app/core/common/app/features/Trip_Ticket/customer/domain/usecases/calculate_customer_total_time.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/customer/domain/usecases/create_customer.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/customer/domain/usecases/delete_all_customer.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/customer/domain/usecases/delete_customer.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/customer/domain/usecases/get_all_customer.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/customer/domain/usecases/get_customer.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/customer/domain/usecases/get_customersLocation.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/customer/domain/usecases/update_customer.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/customer/presentation/bloc/customer_event.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/customer/presentation/bloc/customer_state.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/delivery_update/presentation/bloc/delivery_update_bloc.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/delivery_update/presentation/bloc/delivery_update_event.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/invoice/presentation/bloc/invoice_bloc.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/invoice/presentation/bloc/invoice_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CustomerBloc extends Bloc<CustomerEvent, CustomerState> {
  final InvoiceBloc _invoiceBloc;
  final DeliveryUpdateBloc _deliveryUpdateBloc;
  final GetCustomer _getCustomer;
  final GetCustomersLocation _getCustomersLocation;
  final CalculateCustomerTotalTime _calculateCustomerTotalTime;
  final GetAllCustomers _getAllCustomers;
  final CreateCustomer _createCustomer;
  final UpdateCustomer _updateCustomer;
  final DeleteCustomer _deleteCustomer;
  final DeleteAllCustomers _deleteAllCustomers;

  CustomerState? _cachedState;

  CustomerBloc({
    required InvoiceBloc invoiceBloc,
    required DeliveryUpdateBloc deliveryUpdateBloc,
    required GetCustomer getCustomer,
    required GetCustomersLocation getCustomersLocation,
    required CalculateCustomerTotalTime calculateCustomerTotalTime,
    required GetAllCustomers getAllCustomers,
    required CreateCustomer createCustomer,
    required UpdateCustomer updateCustomer,
    required DeleteCustomer deleteCustomer,
    required DeleteAllCustomers deleteAllCustomers,
  })  : _invoiceBloc = invoiceBloc,
        _deliveryUpdateBloc = deliveryUpdateBloc,
        _getCustomer = getCustomer,
        _getCustomersLocation = getCustomersLocation,
        _calculateCustomerTotalTime = calculateCustomerTotalTime,
        _getAllCustomers = getAllCustomers,
        _createCustomer = createCustomer,
        _updateCustomer = updateCustomer,
        _deleteCustomer = deleteCustomer,
        _deleteAllCustomers = deleteAllCustomers,
        super(CustomerInitial()) {
    on<GetCustomerEvent>(_onGetCustomer);
    on<GetCustomerLocationEvent>(_onGetCustomerLocation);
    on<CalculateCustomerTotalTimeEvent>(_onCalculateCustomerTotalTime);
    on<RefreshCustomersEvent>(_onRefreshCustomers);
    
    // New event handlers
    on<GetAllCustomersEvent>(_onGetAllCustomers);
    on<CreateCustomerEvent>(_onCreateCustomer);
    on<UpdateCustomerEvent>(_onUpdateCustomer);
    on<DeleteCustomerEvent>(_onDeleteCustomer);
    on<DeleteAllCustomersEvent>(_onDeleteAllCustomers);
  }

  Future<void> _onCalculateCustomerTotalTime(
    CalculateCustomerTotalTimeEvent event,
    Emitter<CustomerState> emit,
  ) async {
    emit(CustomerLoading());

    final result = await _calculateCustomerTotalTime(event.customerId);

    result.fold(
      (failure) => emit(CustomerError(failure.message)),
      (totalTime) => emit(CustomerTotalTimeCalculated(
        totalTime: totalTime,
        customerId: event.customerId,
      )),
    );
  }

  Future<void> _onGetCustomer(
    GetCustomerEvent event, 
    Emitter<CustomerState> emit
  ) async {
    emit(CustomerLoading());
    debugPrint('🌐 Fetching customers from remote');

    final result = await _getCustomer(event.tripId);
    result.fold(
      (failure) => emit(CustomerError(failure.message)),
      (customers) {
        _invoiceBloc.add(const GetInvoiceEvent());
        if (customers.isNotEmpty) {
          _deliveryUpdateBloc
              .add(GetDeliveryStatusChoicesEvent(customers.first.id ?? ''));
        }
        final newState = CustomerLoaded(
          customer: customers,
          invoice: _invoiceBloc.state,
          deliveryUpdate: _deliveryUpdateBloc.state,
        );
        _cachedState = newState;
        emit(newState);
      },
    );
  }

  Future<void> _onGetCustomerLocation(
    GetCustomerLocationEvent event, 
    Emitter<CustomerState> emit
  ) async {
    emit(CustomerLocationLoading());
    debugPrint('🌐 Fetching customer location from remote');

    final result = await _getCustomersLocation(event.customerId);
    result.fold(
      (failure) => emit(CustomerError(failure.message)),
      (customer) {
        debugPrint(
            '📍 Customer location loaded: ${customer.latitude}, ${customer.longitude}');
        emit(CustomerLocationLoaded(customer));
      },
    );
  }

  Future<void> _onRefreshCustomers(
    RefreshCustomersEvent event, 
    Emitter<CustomerState> emit
  ) async {
    emit(CustomerRefreshing());
    add(GetCustomerEvent(event.tripId));
  }

  // New event handlers
  Future<void> _onGetAllCustomers(
    GetAllCustomersEvent event, 
    Emitter<CustomerState> emit
  ) async {
    emit(CustomerLoading());
    debugPrint('🔄 Getting all customers');

    final result = await _getAllCustomers();
    result.fold(
      (failure) {
        debugPrint('❌ Failed to get all customers: ${failure.message}');
        emit(CustomerError(failure.message));
      },
      (customers) {
        debugPrint('✅ Retrieved ${customers.length} customers');
        emit(AllCustomersLoaded(customers));
      },
    );
  }

  Future<void> _onCreateCustomer(
    CreateCustomerEvent event, 
    Emitter<CustomerState> emit
  ) async {
    emit(CustomerLoading());
    debugPrint('🔄 Creating new customer');

    final result = await _createCustomer(
      CreateCustomerParams(
        deliveryNumber: event.deliveryNumber,
        storeName: event.storeName,
        ownerName: event.ownerName,
        contactNumber: event.contactNumber,
        address: event.address,
        municipality: event.municipality,
        province: event.province,
        modeOfPayment: event.modeOfPayment,
        tripId: event.tripId,
        totalAmount: event.totalAmount,
        latitude: event.latitude,
        longitude: event.longitude,
        notes: event.notes,
        remarks: event.remarks,
        hasNotes: event.hasNotes,
        confirmedTotalPayment: event.confirmedTotalPayment,
      ),
    );

    result.fold(
      (failure) {
        debugPrint('❌ Failed to create customer: ${failure.message}');
        emit(CustomerError(failure.message));
      },
      (customer) {
        debugPrint('✅ Successfully created customer: ${customer.id}');
        emit(CustomerCreated(customer));
        
        // Refresh the customer list
        add(GetCustomerEvent(event.tripId));
      },
    );
  }

  Future<void> _onUpdateCustomer(
    UpdateCustomerEvent event, 
    Emitter<CustomerState> emit
  ) async {
    emit(CustomerLoading());
    debugPrint('🔄 Updating customer: ${event.id}');

    final result = await _updateCustomer(
      UpdateCustomerParams(
        id: event.id,
        deliveryNumber: event.deliveryNumber,
        storeName: event.storeName,
        ownerName: event.ownerName,
        contactNumber: event.contactNumber,
        address: event.address,
        municipality: event.municipality,
        province: event.province,
        modeOfPayment: event.modeOfPayment,
        tripId: event.tripId,
        totalAmount: event.totalAmount,
        latitude: event.latitude,
        longitude: event.longitude,
        notes: event.notes,
        remarks: event.remarks,
        hasNotes: event.hasNotes,
        confirmedTotalPayment: event.confirmedTotalPayment,
      ),
    );

    result.fold(
      (failure) {
        debugPrint('❌ Failed to update customer: ${failure.message}');
        emit(CustomerError(failure.message));
      },
      (customer) {
        debugPrint('✅ Successfully updated customer: ${customer.id}');
        emit(CustomerUpdated(customer));
        
        // Refresh the customer list if tripId is provided
        if (event.tripId != null) {
          add(GetCustomerEvent(event.tripId!));
        }
      },
    );
  }

  Future<void> _onDeleteCustomer(
    DeleteCustomerEvent event, 
    Emitter<CustomerState> emit
  ) async {
    emit(CustomerLoading());
    debugPrint('🔄 Deleting customer: ${event.id}');

    final result = await _deleteCustomer(event.id);
    result.fold(
      (failure) {
        debugPrint('❌ Failed to delete customer: ${failure.message}');
        emit(CustomerError(failure.message));
      },
      (_) {
        debugPrint('✅ Successfully deleted customer');
        emit(CustomerDeleted(event.id));
        
        // We would need to refresh the customer list here, but we don't have the tripId
        // This would typically be handled by the UI after receiving the CustomerDeleted state
      },
    );
  }

  Future<void> _onDeleteAllCustomers(
    DeleteAllCustomersEvent event, 
    Emitter<CustomerState> emit
  ) async {
    emit(CustomerLoading());
    debugPrint('🔄 Deleting multiple customers: ${event.ids.length} items');

    final result = await _deleteAllCustomers(event.ids);
    result.fold(
      (failure) {
        debugPrint('❌ Failed to delete customers: ${failure.message}');
        emit(CustomerError(failure.message));
      },
      (_) {
        debugPrint('✅ Successfully deleted all customers');
        emit(AllCustomersDeleted(event.ids));
        
        // Similar to delete, we would need to refresh the list but don't have tripId
      },
    );
  }

  @override
  Future<void> close() {
    _cachedState = null;
    return super.close();
  }
}
