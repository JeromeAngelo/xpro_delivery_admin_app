import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/transaction/domain/usecase/create_transaction_usecase.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/transaction/domain/usecase/delete_all_transactions.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/transaction/domain/usecase/delete_transaction_usecase.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/transaction/domain/usecase/generate_pdf.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/transaction/domain/usecase/get_all_transactions.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/transaction/domain/usecase/get_transaction_by_completed_customer.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/transaction/domain/usecase/get_transaction_by_date_range_usecase.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/transaction/domain/usecase/get_transaction_by_id_usecase.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/transaction/domain/usecase/get_transaction_usecase.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/transaction/domain/usecase/process_complete_transactions.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/transaction/domain/usecase/update_transaction_usecase.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/transaction/presentation/bloc/transaction_event.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/transaction/presentation/bloc/transaction_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final CreateTransactionUseCase _createTransaction;
  final DeleteTransactionUseCase _deleteTransaction;
  final GetTransactionByIdUseCase _getTransactionById;
  final GetTransactionUseCase _getTransactions;
  final GetTransactionByDateRangeUseCase _getTransactionsByDateRange;
  final GetTransactionsByCompletedCustomer _getTransactionsByCompletedCustomer;
  final GenerateTransactionPdf _generateTransactionPdf;
  final GetAllTransactions _getAllTransactions;
  final ProcessCompleteTransaction _processCompleteTransaction;
  final UpdateTransaction _updateTransaction;
  final DeleteAllTransactions _deleteAllTransactions;

  TransactionBloc({
    required CreateTransactionUseCase createTransaction,
    required DeleteTransactionUseCase deleteTransaction,
    required GetTransactionByIdUseCase getTransactionById,
    required GetTransactionUseCase getTransactions,
    required GetTransactionByDateRangeUseCase getTransactionsByDateRange,
    required GetTransactionsByCompletedCustomer
    getTransactionsByCompletedCustomer,
    required GenerateTransactionPdf generateTransactionPdf,
    required GetAllTransactions getAllTransactions,
    required ProcessCompleteTransaction processCompleteTransaction,
    required UpdateTransaction updateTransaction,
    required DeleteAllTransactions deleteAllTransactions,
  }) : _createTransaction = createTransaction,
       _deleteTransaction = deleteTransaction,
       _getTransactionById = getTransactionById,
       _getTransactions = getTransactions,
       _getTransactionsByDateRange = getTransactionsByDateRange,
       _getTransactionsByCompletedCustomer = getTransactionsByCompletedCustomer,
       _generateTransactionPdf = generateTransactionPdf,
       _getAllTransactions = getAllTransactions,
       _processCompleteTransaction = processCompleteTransaction,
       _updateTransaction = updateTransaction,
       _deleteAllTransactions = deleteAllTransactions,
       super(TransactionInitial()) {
    on<CreateTransactionEvent>(_createTransactionHandler);
    on<DeleteTransactionEvent>(_deleteTransactionHandler);
    on<GetTransactionByIdEvent>(_getTransactionByIdHandler);
    on<GetTransactionsEvent>(_getTransactionsHandler);
    on<GetTransactionsByDateRangeEvent>(_getTransactionsByDateRangeHandler);
    on<GetTransactionsByCompletedCustomerEvent>(
      _getTransactionsByCompletedCustomerHandler,
    );
    on<GenerateTransactionPdfEvent>(_generatePdfHandler);
    on<GetAllTransactionsEvent>(_getAllTransactionsHandler);
    on<ProcessCompleteTransactionEvent>(_processCompleteTransactionHandler);
    on<UpdateTransactionEvent>(_updateTransactionHandler);
    on<DeleteAllTransactionsEvent>(_deleteAllTransactionsHandler);
  }

  Future<void> _createTransactionHandler(
    CreateTransactionEvent event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionLoading());
    debugPrint('🔄 Creating transaction');

    final result = await _createTransaction(
      CreateTransactionParams(
        transaction: event.transaction,
        customerId: event.customerId,
        tripId: event.tripId,
      ),
    );

    result.fold(
      (failure) {
        debugPrint('❌ Transaction creation failed: ${failure.message}');
        emit(TransactionError(failure.message));
      },
      (_) {
        debugPrint('✅ Transaction created successfully');
        emit(TransactionCreated());
      },
    );
  }

  Future<void> _generatePdfHandler(
    GenerateTransactionPdfEvent event,
    Emitter<TransactionState> emit,
  ) async {
    emit(PdfGenerating());
    debugPrint('📄 Starting PDF generation');

    final result = await _generateTransactionPdf(
      GeneratePdfParams(customer: event.customer, invoices: event.invoices),
    );

    result.fold(
      (failure) {
        debugPrint('❌ PDF generation failed: ${failure.message}');
        emit(PdfGenerationError(failure.message));
      },
      (pdfBytes) {
        debugPrint('✅ PDF generated successfully');
        emit(PdfGenerated(pdfBytes));
      },
    );
  }

  Future<void> _deleteTransactionHandler(
    DeleteTransactionEvent event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionLoading());
    debugPrint('🔄 Deleting transaction: ${event.transactionId}');

    final result = await _deleteTransaction(event.transactionId);
    result.fold(
      (failure) {
        debugPrint('❌ Transaction deletion failed: ${failure.message}');
        emit(TransactionError(failure.message));
      },
      (_) {
        debugPrint('✅ Transaction deleted successfully');
        emit(TransactionDeleted());
      },
    );
  }

  Future<void> _getTransactionByIdHandler(
    GetTransactionByIdEvent event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionLoading());
    final result = await _getTransactionById(event.transactionId);
    result.fold(
      (failure) => emit(TransactionError(failure.message)),
      (transaction) => emit(TransactionLoaded(transaction)),
    );
  }

  Future<void> _getTransactionsHandler(
    GetTransactionsEvent event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionLoading());
    final result = await _getTransactions(event.customerId);
    result.fold(
      (failure) => emit(TransactionError(failure.message)),
      (transactions) => emit(TransactionsLoaded(transactions)),
    );
  }

  Future<void> _getTransactionsByDateRangeHandler(
    GetTransactionsByDateRangeEvent event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionLoading());
    final result = await _getTransactionsByDateRange(
      GetTransactionByDateRangeParams(
        startDate: event.startDate,
        endDate: event.endDate,
        customerId: event.customerId,
      ),
    );
    result.fold(
      (failure) => emit(TransactionError(failure.message)),
      (transactions) => emit(TransactionsLoaded(transactions)),
    );
  }

  Future<void> _getTransactionsByCompletedCustomerHandler(
    GetTransactionsByCompletedCustomerEvent event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionLoading());
    final result = await _getTransactionsByCompletedCustomer(
      event.completedCustomerId,
    );
    result.fold(
      (failure) => emit(TransactionError(failure.message)),
      (transactions) => emit(TransactionsLoaded(transactions)),
    );
  }

  // New handlers

  Future<void> _getAllTransactionsHandler(
    GetAllTransactionsEvent event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionLoading());
    debugPrint('🔄 Fetching all transactions');

    final result = await _getAllTransactions();
    result.fold(
      (failure) {
        debugPrint('❌ Failed to fetch all transactions: ${failure.message}');
        emit(TransactionError(failure.message));
      },
      (transactions) {
        debugPrint(
          '✅ Successfully fetched ${transactions.length} transactions',
        );
        emit(AllTransactionsLoaded(transactions));
      },
    );
  }

  Future<void> _processCompleteTransactionHandler(
    ProcessCompleteTransactionEvent event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionLoading());
    debugPrint('🔄 Processing complete transaction');

    final params = ProcessCompleteTransactionParams(
      customerName: event.customerName,
      totalAmount: event.totalAmount,
      refNumber: event.refNumber,
      signature: event.signature,
      customerImage: event.customerImage,
      invoices: event.invoices,
      deliveryNumber: event.deliveryNumber,
      transactionDate: event.transactionDate,
      transactionStatus: event.transactionStatus,
      modeOfPayment: event.modeOfPayment,
      isCompleted: event.isCompleted,
      pdf: event.pdf,
      tripId: event.tripId,
      customerId: event.customerId,
      completedCustomerId: event.completedCustomerId,
    );

    final result = await _processCompleteTransaction(params);
    result.fold(
      (failure) {
        debugPrint('❌ Transaction processing failed: ${failure.message}');
        emit(TransactionError(failure.message));
      },
      (transaction) {
        debugPrint('✅ Transaction processed successfully');
        emit(TransactionProcessed(transaction));
      },
    );
  }

  Future<void> _updateTransactionHandler(
    UpdateTransactionEvent event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionLoading());
    debugPrint('🔄 Updating transaction: ${event.id}');

    final params = UpdateTransactionParams(
      id: event.id,
      customerName: event.customerName,
      totalAmount: event.totalAmount,
      refNumber: event.refNumber,
      signature: event.signature,
      customerImage: event.customerImage,
      invoices: event.invoices,
      deliveryNumber: event.deliveryNumber,
      transactionDate: event.transactionDate,
      transactionStatus: event.transactionStatus,
      modeOfPayment: event.modeOfPayment,
      isCompleted: event.isCompleted,
      pdf: event.pdf,
      tripId: event.tripId,
      customerId: event.customerId,
      completedCustomerId: event.completedCustomerId,
    );

    final result = await _updateTransaction(params);
    result.fold(
      (failure) {
        debugPrint('❌ Transaction update failed: ${failure.message}');
        emit(TransactionError(failure.message));
      },
      (transaction) {
        debugPrint('✅ Transaction updated successfully');
        emit(TransactionDetailUpdated(transaction));
      },
    );
  }

  Future<void> _deleteAllTransactionsHandler(
    DeleteAllTransactionsEvent event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionLoading());

    final result = await _deleteAllTransactions(event.transactionIds);
    result.fold(
      (failure) {
        emit(TransactionError(failure.message));
      },
      (_) {
        emit(TransactionsDeleted(event.transactionIds));
      },
    );
  }
}
