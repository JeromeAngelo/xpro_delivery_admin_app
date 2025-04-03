


import 'package:desktop_app/core/common/app/features/Trip_Ticket/transaction/domain/entity/transaction_entity.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/transaction/domain/repo/transaction_repo.dart';
import 'package:desktop_app/core/typedefs/typedefs.dart';
import 'package:desktop_app/core/usecases/usecase.dart';

class CreateTransactionParams {
  final TransactionEntity transaction;
  final String customerId;
 
  final String tripId;

  const CreateTransactionParams({
    required this.transaction,
    required this.customerId,
    
    required this.tripId,
  });
}

class CreateTransactionUseCase extends UsecaseWithParams<void, CreateTransactionParams> {
  final TransactionRepo _repo;

  const CreateTransactionUseCase(this._repo);

  @override
  ResultFuture<void> call(CreateTransactionParams params) async {
    return _repo.createTransaction(
      transaction: params.transaction,
      customerId: params.customerId,
     
      tripId: params.tripId,
    );
  }
}

