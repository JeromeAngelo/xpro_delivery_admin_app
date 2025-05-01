import 'package:xpro_delivery_admin_app/core/common/app/features/general_auth/domain/entity/users_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/general_auth/domain/repo/auth_repo.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';
import 'package:xpro_delivery_admin_app/core/usecases/usecase.dart';

class CreateUser extends UsecaseWithParams<GeneralUserEntity, GeneralUserEntity> {
  final GeneralUserRepo _repo;

  const CreateUser(this._repo);

  @override
  ResultFuture<GeneralUserEntity> call(GeneralUserEntity user) {
    return _repo.createUser(user);
  }
}
