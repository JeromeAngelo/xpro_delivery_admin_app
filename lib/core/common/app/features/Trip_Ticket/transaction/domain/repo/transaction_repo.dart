import 'dart:io';
import 'dart:typed_data';

import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/customer/domain/entity/customer_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/invoice/domain/entity/invoice_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/transaction/domain/entity/transaction_entity.dart';
import 'package:xpro_delivery_admin_app/core/enums/mode_of_payment.dart';
import 'package:xpro_delivery_admin_app/core/enums/transaction_status.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';

abstract class TransactionRepo {
  const TransactionRepo();

  // Get operations
  ResultFuture<List<TransactionEntity>> getTransactions(String customerId);
  ResultFuture<List<TransactionEntity>> getTransactionsByCompletedCustomer(String completedCustomerId);
  ResultFuture<TransactionEntity> getTransactionById(String transactionId);
  ResultFuture<List<TransactionEntity>> getAllTransactions();

  // Create operation - comprehensive version
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
  });

  // Update operation
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
  });

  // Delete operations
  ResultFuture<bool> deleteTransaction(String transactionId);
  ResultFuture<bool> deleteAllTransactions(List<String> transactionIds);

  // Existing specialized operations
  ResultFuture<void> createTransaction({
    required TransactionEntity transaction,
    required String customerId,
    required String tripId,
  });

  ResultFuture<List<TransactionEntity>> getTransactionsByDateRange(
    DateTime startDate,
    DateTime endDate,
    String customerId,
  );

  ResultFuture<Uint8List> generateTransactionPdf(
    CustomerEntity customer,
    List<InvoiceEntity> invoices,
  );
}
