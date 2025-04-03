import 'dart:io';

import 'package:desktop_app/core/common/app/features/Trip_Ticket/invoice/domain/entity/invoice_entity.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/transaction/domain/entity/transaction_entity.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/transaction/domain/repo/transaction_repo.dart';
import 'package:desktop_app/core/enums/mode_of_payment.dart';
import 'package:desktop_app/core/enums/transaction_status.dart';
import 'package:desktop_app/core/typedefs/typedefs.dart';
import 'package:desktop_app/core/usecases/usecase.dart';
import 'package:equatable/equatable.dart';

class ProcessCompleteTransaction extends UsecaseWithParams<TransactionEntity, ProcessCompleteTransactionParams> {
  const ProcessCompleteTransaction(this._repo);

  final TransactionRepo _repo;

  @override
  ResultFuture<TransactionEntity> call(ProcessCompleteTransactionParams params) => _repo.processCompleteTransaction(
    customerName: params.customerName,
    totalAmount: params.totalAmount,
    refNumber: params.refNumber,
    signature: params.signature,
    customerImage: params.customerImage,
    invoices: params.invoices,
    deliveryNumber: params.deliveryNumber,
    transactionDate: params.transactionDate,
    transactionStatus: params.transactionStatus,
    modeOfPayment: params.modeOfPayment,
    isCompleted: params.isCompleted,
    pdf: params.pdf,
    tripId: params.tripId,
    customerId: params.customerId,
    completedCustomerId: params.completedCustomerId,
  );
}

class ProcessCompleteTransactionParams extends Equatable {
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

  const ProcessCompleteTransactionParams({
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
