import 'package:desktop_app/core/common/app/features/general_auth/domain/entity/users_entity.dart';
import 'package:desktop_app/core/common/app/features/general_auth/domain/repo/auth_repo.dart';
import 'package:desktop_app/core/typedefs/typedefs.dart';
import 'package:desktop_app/core/usecases/usecase.dart';

class UpdateUser extends UsecaseWithParams<GeneralUserEntity, GeneralUserEntity> {
  final GeneralUserRepo _repo;

  const UpdateUser(this._repo);

  @override
  ResultFuture<GeneralUserEntity> call(GeneralUserEntity user) {
    return _repo.updateUser(user);
  }
}
