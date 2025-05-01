import 'package:xpro_delivery_admin_app/core/common/app/features/general_auth/domain/repo/auth_repo.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';
import 'package:xpro_delivery_admin_app/core/usecases/usecase.dart';

class DeleteUser extends UsecaseWithParams<bool, String> {
  final GeneralUserRepo _repo;

  const DeleteUser(this._repo);

  @override
  ResultFuture<bool> call(String userId) {
    return _repo.deleteUser(userId);
  }
}
