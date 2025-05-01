import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/return_product/domain/repo/return_repo.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';
import 'package:xpro_delivery_admin_app/core/usecases/usecase.dart';

class DeleteReturn extends UsecaseWithParams<bool, String> {
  const DeleteReturn(this._repo);

  final ReturnRepo _repo;

  @override
  ResultFuture<bool> call(String id) => _repo.deleteReturn(id);
}
