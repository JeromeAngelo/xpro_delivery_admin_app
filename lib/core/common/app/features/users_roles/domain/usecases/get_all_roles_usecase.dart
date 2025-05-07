import 'package:xpro_delivery_admin_app/core/common/app/features/users_roles/domain/entity/user_role_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/users_roles/domain/repo/user_role_repo.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';
import 'package:xpro_delivery_admin_app/core/usecases/usecase.dart';

class GetAllRolesUsecase extends UsecaseWithoutParams<List<UserRoleEntity>> {
  final UserRoleRepo _repo;

  const GetAllRolesUsecase(this._repo);

  @override
  ResultFuture<List<UserRoleEntity>> call() => _repo.getAllRoles();
}
