import 'dart:io';
import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/customer/domain/entity/customer_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/invoice/data/models/invoice_models.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/invoice/domain/entity/invoice_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/transaction/data/datasource/remote_datasource/transaction_remote_datasource.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/transaction/data/model/transaction_model.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/transaction/domain/entity/transaction_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/transaction/domain/repo/transaction_repo.dart';
import 'package:xpro_delivery_admin_app/core/enums/mode_of_payment.dart';
import 'package:xpro_delivery_admin_app/core/enums/transaction_status.dart';
import 'package:xpro_delivery_admin_app/core/errors/exceptions.dart';
import 'package:xpro_delivery_admin_app/core/errors/failures.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';
import 'package:flutter/foundation.dart';

class TransactionRepoImpl extends TransactionRepo {
  final TransactionRemoteDatasource _remoteDatasource;

  const TransactionRepoImpl(this._remoteDatasource);

  @override
  ResultFuture<void> createTransaction({
    required TransactionEntity transaction,
    required String customerId,
    required String tripId,
  }) async {
    try {
      debugPrint('🔄 Starting transaction creation flow');
      
      await _remoteDatasource.createTransaction(
        transaction: transaction as TransactionModel,
        customerId: customerId,
        tripId: tripId,
      );
      debugPrint('✅ Remote transaction creation completed');

      return const Right(null);
    } catch (e) {
      debugPrint('❌ Transaction operation failed: ${e.toString()}');
      return Left(ServerFailure(message: e.toString(), statusCode: '500'));
    }
  }

  @override
  ResultFuture<bool> deleteTransaction(String transactionId) async {
    try {
      await _remoteDatasource.deleteTransaction(transactionId);
      return const Right(true);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  ResultFuture<TransactionEntity> getTransactionById(String transactionId) async {
    try {
      final result = await _remoteDatasource.getTransactionById(transactionId);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  ResultFuture<List<TransactionEntity>> getTransactions(String customerId) async {
    try {
      final result = await _remoteDatasource.getTransactions(customerId);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  ResultFuture<List<TransactionEntity>> getTransactionsByDateRange(
    DateTime startDate,
    DateTime endDate,
    String customerId,
  ) async {
    try {
      final result = await _remoteDatasource.getTransactionsByDateRange(
        startDate,
        endDate,
        customerId,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  ResultFuture<TransactionEntity> updateTransaction({
    required String id,
    String? customerName,
    String? totalAmount,
    String? refNumber,
    File? signature,
    String? customerImage,
    List<InvoiceEntity>? invoices,
    String? deliveryNumber,
    DateTime? transactionDate,
    TransactionStatus? transactionStatus,
    ModeOfPayment? modeOfPayment,
    bool? isCompleted,
    File? pdf,
    String? tripId,
    String? customerId,
    String? completedCustomerId,
  }) async {
    try {
      final result = await _remoteDatasource.updateTransactionDetails(
        id: id,
        customerName: customerName,
        totalAmount: totalAmount,
        refNumber: refNumber,
        signature: signature,
        customerImage: customerImage,
        invoices: invoices as List<InvoiceModel> ,
        deliveryNumber: deliveryNumber,
        transactionDate: transactionDate,
        transactionStatus: transactionStatus,
        modeOfPayment: modeOfPayment,
        isCompleted: isCompleted,
        pdf: pdf,
        tripId: tripId,
        customerId: customerId,
        completedCustomerId: completedCustomerId,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  ResultFuture<List<TransactionEntity>> getTransactionsByCompletedCustomer(
    String completedCustomerId,
  ) async {
    try {
      debugPrint('🔄 Fetching transactions for completed customer');
      final remoteTransactions = await _remoteDatasource.getTransactionsByCompletedCustomer(completedCustomerId);
      return Right(remoteTransactions);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  ResultFuture<Uint8List> generateTransactionPdf(
    CustomerEntity customer,
    List<InvoiceEntity> invoices,
  ) async {
    try {
      // This would typically call a PDF generation service
      // For now, we'll just return a placeholder
      debugPrint('⚠️ PDF generation not implemented in remote datasource');
      return Left(ServerFailure(
        message: 'PDF generation not implemented in remote datasource',
        statusCode: '501',
      ));
    } catch (e) {
      return Left(ServerFailure(
        message: 'Failed to generate PDF: ${e.toString()}',
        statusCode: '500',
      ));
    }
  }
  
  // New methods
  
  @override
  ResultFuture<List<TransactionEntity>> getAllTransactions() async {
    try {
      debugPrint('🔄 Fetching all transactions');
      final transactions = await _remoteDatasource.getAllTransactions();
      debugPrint('✅ Successfully fetched ${transactions.length} transactions');
      return Right(transactions);
    } on ServerException catch (e) {
      debugPrint('❌ Failed to fetch all transactions: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }
  
  @override
  ResultFuture<TransactionEntity> processCompleteTransaction({
    required String customerName,
    required String totalAmount,
    required String refNumber,
    required File? signature,
    required String? customerImage,
    required List<InvoiceEntity> invoices,
    required String deliveryNumber,
    required DateTime transactionDate,
    required TransactionStatus transactionStatus,
    required ModeOfPayment modeOfPayment,
    required bool isCompleted,
    required File? pdf,
    required String? tripId,
    required String? customerId,
    required String? completedCustomerId,
  }) async {
    try {
      debugPrint('🔄 Processing complete transaction');
      final transaction = await _remoteDatasource.processCompleteTransaction(
        customerName: customerName,
        totalAmount: totalAmount,
        refNumber: refNumber,
        signature: signature,
        customerImage: customerImage,
        invoices: invoices as List<InvoiceModel>,
        deliveryNumber: deliveryNumber,
        transactionDate: transactionDate,
        transactionStatus: transactionStatus,
        modeOfPayment: modeOfPayment,
        isCompleted: isCompleted,
        pdf: pdf,
        tripId: tripId,
        customerId: customerId,
        completedCustomerId: completedCustomerId,
      );
      debugPrint('✅ Transaction processed successfully');
      return Right(transaction);
    } on ServerException catch (e) {
      debugPrint('❌ Transaction processing failed: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }
  
  @override
  ResultFuture<bool> deleteAllTransactions(List<String> transactionIds) async {
    try {
      debugPrint('🔄 Deleting multiple transactions: ${transactionIds.length} items');
      final result = await _remoteDatasource.deleteAllTransactions(transactionIds);
      debugPrint('✅ Transactions deleted successfully');
      return Right(result);
    } on ServerException catch (e) {
      debugPrint('❌ Bulk transaction deletion failed: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }
}
