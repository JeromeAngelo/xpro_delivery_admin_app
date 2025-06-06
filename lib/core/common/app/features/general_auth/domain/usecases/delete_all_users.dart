import 'package:xpro_delivery_admin_app/core/common/app/features/general_auth/domain/repo/auth_repo.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';
import 'package:xpro_delivery_admin_app/core/usecases/usecase.dart';

class DeleteAllUsers extends UsecaseWithoutParams<bool> {
  final GeneralUserRepo _repo;

  const DeleteAllUsers(this._repo);

  @override
  ResultFuture<bool> call() {
    return _repo.deleteAllUsers();
  }
}
