

import 'package:desktop_app/core/common/app/features/Trip_Ticket/transaction/domain/repo/transaction_repo.dart';
import 'package:desktop_app/core/typedefs/typedefs.dart';
import 'package:desktop_app/core/usecases/usecase.dart';

class DeleteTransactionUseCase extends UsecaseWithParams<void, String> {
  final TransactionRepo _repo;

  const DeleteTransactionUseCase(this._repo);

  @override
  ResultFuture<void> call(String params) async {
    return _repo.deleteTransaction(params);
  }
}
