import 'dart:io';

import 'package:desktop_app/core/common/app/features/Trip_Ticket/customer/domain/entity/customer_entity.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/invoice/domain/entity/invoice_entity.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/transaction/domain/entity/transaction_entity.dart';
import 'package:desktop_app/core/enums/mode_of_payment.dart';
import 'package:desktop_app/core/enums/transaction_status.dart';
import 'package:equatable/equatable.dart';

abstract class TransactionEvent extends Equatable {
  const TransactionEvent();

  @override
  List<Object?> get props => [];
}

// Existing events
class CreateTransactionEvent extends TransactionEvent {
  final TransactionEntity transaction;
  final String customerId;
  final String tripId;

  const CreateTransactionEvent({
    required this.transaction,
    required this.customerId,
    required this.tripId,
  });

  @override
  List<Object?> get props => [transaction, customerId, tripId];
}

class GetTransactionsEvent extends TransactionEvent {
  final String customerId;
  const GetTransactionsEvent(this.customerId);

  @override
  List<Object?> get props => [customerId];
}

class GetTransactionByIdEvent extends TransactionEvent {
  final String transactionId;
  const GetTransactionByIdEvent(this.transactionId);

  @override
  List<Object?> get props => [transactionId];
}

class GetTransactionsByDateRangeEvent extends TransactionEvent {
  final DateTime startDate;
  final DateTime endDate;
  final String customerId;

  const GetTransactionsByDateRangeEvent({
    required this.startDate,
    required this.endDate,
    required this.customerId,
  });

  @override
  List<Object?> get props => [startDate, endDate, customerId];
}

class GetTransactionsByCompletedCustomerEvent extends TransactionEvent {
  final String completedCustomerId;
  const GetTransactionsByCompletedCustomerEvent(this.completedCustomerId);

  @override
  List<Object?> get props => [completedCustomerId];
}

class GenerateTransactionPdfEvent extends TransactionEvent {
  final CustomerEntity customer;
  final List<InvoiceEntity> invoices;

  const GenerateTransactionPdfEvent({
    required this.customer,
    required this.invoices,
  });

  @override
  List<Object?> get props => [customer, invoices];
}

// New events
class GetAllTransactionsEvent extends TransactionEvent {
  const GetAllTransactionsEvent();
}

class ProcessCompleteTransactionEvent extends TransactionEvent {
  final String customerName;
  final String totalAmount;
  final String refNumber;
  final File? signature;
  final String? customerImage;
  final List<InvoiceEntity> invoices;
  final String deliveryNumber;
  final DateTime transactionDate;
  final TransactionStatus transactionStatus;
  final ModeOfPayment modeOfPayment;
  final bool isCompleted;
  final File? pdf;
  final String? tripId;
  final String? customerId;
  final String? completedCustomerId;

  const ProcessCompleteTransactionEvent({
    required this.customerName,
    required this.totalAmount,
    required this.refNumber,
    required this.signature,
    required this.customerImage,
    required this.invoices,
    required this.deliveryNumber,
    required this.transactionDate,
    required this.transactionStatus,
    required this.modeOfPayment,
    required this.isCompleted,
    required this.pdf,
    required this.tripId,
    required this.customerId,
    required this.completedCustomerId,
  });

  @override
  List<Object?> get props => [
    customerName,
    totalAmount,
    refNumber,
    signature,
    customerImage,
    invoices,
    deliveryNumber,
    transactionDate,
    transactionStatus,
    modeOfPayment,
    isCompleted,
    pdf,
    tripId,
    customerId,
    completedCustomerId,
  ];
}

class UpdateTransactionEvent extends TransactionEvent {
  final String id;
  final String? customerName;
  final String? totalAmount;
  final String? refNumber;
  final File? signature;
  final String? customerImage;
  final List<InvoiceEntity>? invoices;
  final String? deliveryNumber;
  final DateTime? transactionDate;
  final TransactionStatus? transactionStatus;
  final ModeOfPayment? modeOfPayment;
  final bool? isCompleted;
  final File? pdf;
  final String? tripId;
  final String? customerId;
  final String? completedCustomerId;

  const UpdateTransactionEvent({
    required this.id,
    this.customerName,
    this.totalAmount,
    this.refNumber,
    this.signature,
    this.customerImage,
    this.invoices,
    this.deliveryNumber,
    this.transactionDate,
    this.transactionStatus,
    this.modeOfPayment,
    this.isCompleted,
    this.pdf,
    this.tripId,
    this.customerId,
    this.completedCustomerId,
  });

  @override
  List<Object?> get props => [
    id,
    customerName,
    totalAmount,
    refNumber,
    signature,
    customerImage,
    invoices,
    deliveryNumber,
    transactionDate,
    transactionStatus,
    modeOfPayment,
    isCompleted,
    pdf,
    tripId,
    customerId,
    completedCustomerId,
  ];
}

class DeleteTransactionEvent extends TransactionEvent {
  final String transactionId;
  const DeleteTransactionEvent(this.transactionId);

  @override
  List<Object?> get props => [transactionId];
}

class DeleteAllTransactionsEvent extends TransactionEvent {
  final List<String> transactionIds;
  const DeleteAllTransactionsEvent(this.transactionIds);

  @override
  List<Object?> get props => [transactionIds];
}
