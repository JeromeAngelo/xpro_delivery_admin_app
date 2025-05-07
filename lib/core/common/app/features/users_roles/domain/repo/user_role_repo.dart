import 'package:xpro_delivery_admin_app/core/common/app/features/users_roles/domain/entity/user_role_entity.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';

abstract class UserRoleRepo {
  ResultFuture<List<UserRoleEntity>> getAllRoles();
}
