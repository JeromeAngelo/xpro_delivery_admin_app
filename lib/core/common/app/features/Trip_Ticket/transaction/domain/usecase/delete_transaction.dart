import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/transaction/domain/repo/transaction_repo.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';
import 'package:xpro_delivery_admin_app/core/usecases/usecase.dart';

class DeleteTransaction extends UsecaseWithParams<bool, String> {
  const DeleteTransaction(this._repo);

  final TransactionRepo _repo;

  @override
  ResultFuture<bool> call(String transactionId) => _repo.deleteTransaction(transactionId);
}
