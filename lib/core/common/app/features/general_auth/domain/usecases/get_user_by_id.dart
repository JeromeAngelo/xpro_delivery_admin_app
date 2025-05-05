
import 'package:xpro_delivery_admin_app/core/common/app/features/general_auth/domain/entity/users_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/general_auth/domain/repo/auth_repo.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';
import 'package:xpro_delivery_admin_app/core/usecases/usecase.dart';

class GetUserById extends UsecaseWithParams<GeneralUserEntity, String> {
  const GetUserById(this._repo);
  final GeneralUserRepo _repo;

  @override
  ResultFuture<GeneralUserEntity> call(String params) => _repo.getUserById(params);
}
