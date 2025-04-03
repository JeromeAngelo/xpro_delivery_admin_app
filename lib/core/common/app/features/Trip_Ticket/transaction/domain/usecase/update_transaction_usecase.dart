import 'dart:io';

import 'package:desktop_app/core/common/app/features/Trip_Ticket/invoice/domain/entity/invoice_entity.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/transaction/domain/entity/transaction_entity.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/transaction/domain/repo/transaction_repo.dart';
import 'package:desktop_app/core/enums/mode_of_payment.dart';
import 'package:desktop_app/core/enums/transaction_status.dart';
import 'package:desktop_app/core/typedefs/typedefs.dart';
import 'package:desktop_app/core/usecases/usecase.dart';
import 'package:equatable/equatable.dart';

class UpdateTransaction extends UsecaseWithParams<TransactionEntity, UpdateTransactionParams> {
  const UpdateTransaction(this._repo);

  final TransactionRepo _repo;

  @override
  ResultFuture<TransactionEntity> call(UpdateTransactionParams params) => 
      _repo.updateTransaction(
        id: params.id,
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

class UpdateTransactionParams extends Equatable {
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

  const UpdateTransactionParams({
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
