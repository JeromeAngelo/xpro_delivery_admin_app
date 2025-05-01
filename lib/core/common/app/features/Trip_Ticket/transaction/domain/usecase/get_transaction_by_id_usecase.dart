
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/transaction/domain/entity/transaction_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/transaction/domain/repo/transaction_repo.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';
import 'package:xpro_delivery_admin_app/core/usecases/usecase.dart';

class GetTransactionByIdUseCase extends UsecaseWithParams<TransactionEntity, String> {
  final TransactionRepo _repo;

  const GetTransactionByIdUseCase(this._repo);

  @override
  ResultFuture<TransactionEntity> call(String params) async {
    return _repo.getTransactionById(params);
  }
}
