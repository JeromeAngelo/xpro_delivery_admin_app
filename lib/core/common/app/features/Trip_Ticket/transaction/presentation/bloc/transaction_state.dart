import 'dart:typed_data';

import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/transaction/domain/entity/transaction_entity.dart';
import 'package:equatable/equatable.dart';

abstract class TransactionState extends Equatable {
  const TransactionState();

  @override
  List<Object?> get props => [];
}

// Existing states
class TransactionInitial extends TransactionState {}

class TransactionLoading extends TransactionState {}

class TransactionError extends TransactionState {
  final String message;
  const TransactionError(this.message);

  @override
  List<Object?> get props => [message];
}

class TransactionCreated extends TransactionState {}

class TransactionsLoaded extends TransactionState {
  final List<TransactionEntity> transactions;
  const TransactionsLoaded(this.transactions);

  @override
  List<Object?> get props => [transactions];
}

class TransactionLoaded extends TransactionState {
  final TransactionEntity transaction;
  const TransactionLoaded(this.transaction);

  @override
  List<Object?> get props => [transaction];
}

class TransactionUpdated extends TransactionState {}

class TransactionDeleted extends TransactionState {}

class PdfGenerating extends TransactionState {}

class PdfGenerated extends TransactionState {
  final Uint8List pdfBytes;
  
  const PdfGenerated(this.pdfBytes);
  
  @override
  List<Object?> get props => [pdfBytes];
}

class PdfGenerationError extends TransactionState {
  final String message;
  
  const PdfGenerationError(this.message);
  
  @override
  List<Object?> get props => [message];
}

// New states
class AllTransactionsLoaded extends TransactionState {
  final List<TransactionEntity> transactions;
  const AllTransactionsLoaded(this.transactions);

  @override
  List<Object?> get props => [transactions];
}

class TransactionProcessed extends TransactionState {
  final TransactionEntity transaction;
  const TransactionProcessed(this.transaction);

  @override
  List<Object?> get props => [transaction];
}

class TransactionDetailUpdated extends TransactionState {
  final TransactionEntity transaction;
  const TransactionDetailUpdated(this.transaction);

  @override
  List<Object?> get props => [transaction];
}

class TransactionsDeleted extends TransactionState {
  final List<String> ids;
  const TransactionsDeleted(this.ids);

  @override
  List<Object?> get props => [ids];
}
