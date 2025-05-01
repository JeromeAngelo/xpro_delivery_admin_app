
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/transaction/domain/entity/transaction_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/transaction/domain/repo/transaction_repo.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';
import 'package:xpro_delivery_admin_app/core/usecases/usecase.dart';

class GetTransactionByDateRangeParams {
  final DateTime startDate;
  final DateTime endDate;
  final String customerId;

  const GetTransactionByDateRangeParams({
    required this.startDate,
    required this.endDate,
    required this.customerId,
  });
}

class GetTransactionByDateRangeUseCase extends UsecaseWithParams<List<TransactionEntity>, GetTransactionByDateRangeParams> {
  final TransactionRepo _repo;

  const GetTransactionByDateRangeUseCase(this._repo);

  @override
  ResultFuture<List<TransactionEntity>> call(GetTransactionByDateRangeParams params) async {
    return _repo.getTransactionsByDateRange(
      params.startDate,
      params.endDate,
      params.customerId,
    );
  }
}
