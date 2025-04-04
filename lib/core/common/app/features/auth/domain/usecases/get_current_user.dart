import 'package:desktop_app/core/common/app/features/auth/domain/entity/auth_entity.dart';
import 'package:desktop_app/core/common/app/features/auth/domain/repo/auth_repo.dart';
import 'package:desktop_app/core/typedefs/typedefs.dart';
import 'package:desktop_app/core/usecases/usecase.dart';

class GetCurrentUser extends UsecaseWithoutParams<AuthEntity> {
  final AuthRepo _authRepo;

  const GetCurrentUser(this._authRepo);

  @override
  ResultFuture<AuthEntity> call() async {
    return _authRepo.getCurrentUser();
  }
}
