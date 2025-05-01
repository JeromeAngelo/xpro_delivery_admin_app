import 'package:xpro_delivery_admin_app/core/common/app/features/auth/domain/entity/auth_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/auth/domain/repo/auth_repo.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';
import 'package:xpro_delivery_admin_app/core/usecases/usecase.dart';


class GetAllUsersUsecase extends UsecaseWithoutParams<List<AuthEntity>> {
  final AuthRepo _authRepo;

  const GetAllUsersUsecase(this._authRepo);

  @override
  ResultFuture<List<AuthEntity>> call() {
    return _authRepo.getAllUsers();
  }
}
