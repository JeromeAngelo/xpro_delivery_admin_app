import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/completed_customer/domain/usecase/create_compeleted_customer.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/completed_customer/domain/usecase/delete_all_completed_customer.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/completed_customer/domain/usecase/delete_completed_customer.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/completed_customer/domain/usecase/get_all_completed_customer.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/completed_customer/domain/usecase/get_completed_customer.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/completed_customer/domain/usecase/get_completed_customer_by_id_usecase.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/completed_customer/domain/usecase/update_completed_customer.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/completed_customer/presentation/bloc/completed_customer_event.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/completed_customer/presentation/bloc/completed_customer_state.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/invoice/presentation/bloc/invoice_bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/invoice/presentation/bloc/invoice_event.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CompletedCustomerBloc
    extends Bloc<CompletedCustomerEvent, CompletedCustomerState> {
  final GetCompletedCustomer _getCompletedCustomers;
  final GetCompletedCustomerById _getCompletedCustomerById;
  final GetAllCompletedCustomers _getAllCompletedCustomers;
  final CreateCompletedCustomer _createCompletedCustomer;
  final UpdateCompletedCustomer _updateCompletedCustomer;
  final DeleteCompletedCustomer _deleteCompletedCustomer;
  final DeleteAllCompletedCustomers _deleteAllCompletedCustomers;
  CompletedCustomerState? _cachedState;
  final InvoiceBloc _invoiceBloc;

  CompletedCustomerBloc({
    required InvoiceBloc invoiceBloc,
    required GetCompletedCustomer getCompletedCustomers,
    required GetCompletedCustomerById getCompletedCustomerById,
    required GetAllCompletedCustomers getAllCompletedCustomers,
    required CreateCompletedCustomer createCompletedCustomer,
    required UpdateCompletedCustomer updateCompletedCustomer,
    required DeleteCompletedCustomer deleteCompletedCustomer,
    required DeleteAllCompletedCustomers deleteAllCompletedCustomers,
  })  : _getCompletedCustomers = getCompletedCustomers,
        _getCompletedCustomerById = getCompletedCustomerById,
        _getAllCompletedCustomers = getAllCompletedCustomers,
        _createCompletedCustomer = createCompletedCustomer,
        _updateCompletedCustomer = updateCompletedCustomer,
        _deleteCompletedCustomer = deleteCompletedCustomer,
        _deleteAllCompletedCustomers = deleteAllCompletedCustomers,
        _invoiceBloc = invoiceBloc,
        super(const CompletedCustomerInitial()) {
    on<GetCompletedCustomerEvent>(_getCompletedCustomerHandler);
    on<GetCompletedCustomerByIdEvent>(_getCompletedCustomerByIdHandler);
    on<GetAllCompletedCustomersEvent>(_getAllCompletedCustomersHandler);
    on<CreateCompletedCustomerEvent>(_createCompletedCustomerHandler);
    on<UpdateCompletedCustomerEvent>(_updateCompletedCustomerHandler);
    on<DeleteCompletedCustomerEvent>(_deleteCompletedCustomerHandler);
    on<DeleteAllCompletedCustomersEvent>(_deleteAllCompletedCustomersHandler);
  }

  Future<void> _getCompletedCustomerHandler(
    GetCompletedCustomerEvent event,
    Emitter<CompletedCustomerState> emit,
  ) async {
    if (_cachedState != null) {
      emit(_cachedState!);
    } else {
      emit(const CompletedCustomerLoading());
    }

    final result = await _getCompletedCustomers(event.tripId);
    result.fold(
      (failure) => emit(CompletedCustomerError(failure.message)),
      (customers) {
        _invoiceBloc.add(const GetInvoiceEvent());

        final newState = CompletedCustomerLoaded(
          customers: customers,
          invoice: _invoiceBloc.state,
        );
        _cachedState = newState;
        emit(newState);
      },
    );
  }

  Future<void> _getCompletedCustomerByIdHandler(
    GetCompletedCustomerByIdEvent event,
    Emitter<CompletedCustomerState> emit,
  ) async {
    emit(const CompletedCustomerLoading());
    final result = await _getCompletedCustomerById(event.customerId);
    result.fold(
      (failure) => emit(CompletedCustomerError(failure.message)),
      (customer) => emit(CompletedCustomerByIdLoaded(customer)),
    );
  }

  Future<void> _getAllCompletedCustomersHandler(
    GetAllCompletedCustomersEvent event,
    Emitter<CompletedCustomerState> emit,
  ) async {
    emit(const CompletedCustomerLoading());
    debugPrint('🔄 Getting all completed customers');

    final result = await _getAllCompletedCustomers();
    result.fold(
      (failure) {
        debugPrint('❌ Failed to get all completed customers: ${failure.message}');
        emit(CompletedCustomerError(failure.message));
      },
      (customers) {
        debugPrint('✅ Retrieved ${customers.length} completed customers');
        emit(AllCompletedCustomersLoaded(customers));
      },
    );
  }

  Future<void> _createCompletedCustomerHandler(
    CreateCompletedCustomerEvent event,
    Emitter<CompletedCustomerState> emit,
  ) async {
    emit(const CompletedCustomerLoading());
    debugPrint('🔄 Creating new completed customer');

    final result = await _createCompletedCustomer(
      CreateCompletedCustomerParams(
        deliveryNumber: event.deliveryNumber,
        storeName: event.storeName,
        ownerName: event.ownerName,
        contactNumber: event.contactNumber,
        address: event.address,
        municipality: event.municipality,
        province: event.province,
        modeOfPayment: event.modeOfPayment,
        timeCompleted: event.timeCompleted,
        totalAmount: event.totalAmount,
        totalTime: event.totalTime,
        tripId: event.tripId,
        transactionId: event.transactionId,
        customerId: event.customerId,
      ),
    );

    result.fold(
      (failure) {
        debugPrint('❌ Failed to create completed customer: ${failure.message}');
        emit(CompletedCustomerError(failure.message));
      },
      (customer) {
        debugPrint('✅ Successfully created completed customer: ${customer.id}');
        emit(CompletedCustomerCreated(customer));
      },
    );
  }

  Future<void> _updateCompletedCustomerHandler(
    UpdateCompletedCustomerEvent event,
    Emitter<CompletedCustomerState> emit,
  ) async {
    emit(const CompletedCustomerLoading());
    debugPrint('🔄 Updating completed customer: ${event.id}');

    final result = await _updateCompletedCustomer(
      UpdateCompletedCustomerParams(
        id: event.id,
        deliveryNumber: event.deliveryNumber,
        storeName: event.storeName,
        ownerName: event.ownerName,
        contactNumber: event.contactNumber,
        address: event.address,
        municipality: event.municipality,
        province: event.province,
        modeOfPayment: event.modeOfPayment,
        timeCompleted: event.timeCompleted,
        totalAmount: event.totalAmount,
        totalTime: event.totalTime,
        tripId: event.tripId,
        transactionId: event.transactionId,
        customerId: event.customerId,
      ),
    );

    result.fold(
      (failure) {
        debugPrint('❌ Failed to update completed customer: ${failure.message}');
        emit(CompletedCustomerError(failure.message));
      },
      (customer) {
        debugPrint('✅ Successfully updated completed customer: ${customer.id}');
        emit(CompletedCustomerUpdated(customer));
      },
    );
  }

  Future<void> _deleteCompletedCustomerHandler(
    DeleteCompletedCustomerEvent event,
    Emitter<CompletedCustomerState> emit,
  ) async {
    emit(const CompletedCustomerLoading());
    debugPrint('🔄 Deleting completed customer: ${event.id}');

    final result = await _deleteCompletedCustomer(event.id);
    result.fold(
      (failure) {
        debugPrint('❌ Failed to delete completed customer: ${failure.message}');
        emit(CompletedCustomerError(failure.message));
      },
      (_) {
        debugPrint('✅ Successfully deleted completed customer');
        emit(CompletedCustomerDeleted(event.id));
      },
    );
  }

  Future<void> _deleteAllCompletedCustomersHandler(
    DeleteAllCompletedCustomersEvent event,
    Emitter<CompletedCustomerState> emit,
  ) async {
    emit(const CompletedCustomerLoading());
    debugPrint('🔄 Deleting multiple completed customers: ${event.ids.length} items');

    final result = await _deleteAllCompletedCustomers(event.ids);
    result.fold(
      (failure) {
        debugPrint('❌ Failed to delete completed customers: ${failure.message}');
        emit(CompletedCustomerError(failure.message));
      },
      (_) {
        debugPrint('✅ Successfully deleted all completed customers');
        emit(AllCompletedCustomersDeleted(event.ids));
      },
    );
  }

  @override
  Future<void> close() {
    _cachedState = null;
    return super.close();
  }
}
