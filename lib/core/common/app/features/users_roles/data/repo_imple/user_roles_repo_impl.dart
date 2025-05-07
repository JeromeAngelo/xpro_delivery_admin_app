import 'package:dartz/dartz.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/users_roles/data/datasources/remote_datasource/user_roles_remote_datasource.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/users_roles/domain/entity/user_role_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/users_roles/domain/repo/user_role_repo.dart';
import 'package:xpro_delivery_admin_app/core/errors/exceptions.dart';
import 'package:xpro_delivery_admin_app/core/errors/failures.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';

class UserRolesRepoImpl extends UserRoleRepo {
  UserRolesRepoImpl(this._remoteDatasource);

  final UserRolesRemoteDatasource _remoteDatasource;
  @override
  ResultFuture<List<UserRoleEntity>> getAllRoles() async {
    try {
      final result = await _remoteDatasource.getAllRoles();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }
}
