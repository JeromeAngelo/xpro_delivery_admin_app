import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/transaction/domain/repo/transaction_repo.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';
import 'package:xpro_delivery_admin_app/core/usecases/usecase.dart';

class DeleteAllTransactions extends UsecaseWithParams<bool, List<String>> {
  const DeleteAllTransactions(this._repo);

  final TransactionRepo _repo;

  @override
  ResultFuture<bool> call(List<String> transactionIds) => _repo.deleteAllTransactions(transactionIds);
}
