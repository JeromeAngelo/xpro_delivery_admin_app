import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/return_product/domain/entity/return_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/return_product/domain/repo/return_repo.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';
import 'package:xpro_delivery_admin_app/core/usecases/usecase.dart';

class GetAllReturns extends UsecaseWithoutParams<List<ReturnEntity>> {
  const GetAllReturns(this._repo);

  final ReturnRepo _repo;

  @override
  ResultFuture<List<ReturnEntity>> call() => _repo.getAllReturns();
}
