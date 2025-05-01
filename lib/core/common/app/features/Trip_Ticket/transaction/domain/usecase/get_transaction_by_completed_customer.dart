
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/transaction/domain/entity/transaction_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/transaction/domain/repo/transaction_repo.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';
import 'package:xpro_delivery_admin_app/core/usecases/usecase.dart';

class GetTransactionsByCompletedCustomer extends UsecaseWithParams<List<TransactionEntity>, String> {
  const GetTransactionsByCompletedCustomer(this._repo);

  final TransactionRepo _repo;

  @override
  ResultFuture<List<TransactionEntity>> call(String params) {
    return _repo.getTransactionsByCompletedCustomer(params);
  }
}
