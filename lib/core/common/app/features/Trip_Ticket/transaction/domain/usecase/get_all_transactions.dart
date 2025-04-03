import 'package:desktop_app/core/common/app/features/Trip_Ticket/transaction/domain/entity/transaction_entity.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/transaction/domain/repo/transaction_repo.dart';
import 'package:desktop_app/core/typedefs/typedefs.dart';
import 'package:desktop_app/core/usecases/usecase.dart';

class GetAllTransactions extends UsecaseWithoutParams<List<TransactionEntity>> {
  const GetAllTransactions(this._repo);

  final TransactionRepo _repo;

  @override
  ResultFuture<List<TransactionEntity>> call() => _repo.getAllTransactions();
}
