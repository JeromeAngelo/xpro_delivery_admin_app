import 'package:desktop_app/core/common/app/features/general_auth/domain/entity/users_entity.dart';
import 'package:desktop_app/core/common/app/features/general_auth/domain/repo/auth_repo.dart';
import 'package:desktop_app/core/typedefs/typedefs.dart';
import 'package:desktop_app/core/usecases/usecase.dart';

class GetAllUsers extends UsecaseWithoutParams<List<GeneralUserEntity>> {
  final GeneralUserRepo _repo;

  const GetAllUsers(this._repo);

  @override
  ResultFuture<List<GeneralUserEntity>> call() {
    return _repo.getAllUsers();
  }
}
