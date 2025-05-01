import 'package:xpro_delivery_admin_app/core/common/app/features/auth/domain/entity/auth_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/auth/domain/repo/auth_repo.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';
import 'package:xpro_delivery_admin_app/core/usecases/usecase.dart';


class SignInParams {
  final String email;
  final String password;

  const SignInParams({
    required this.email,
    required this.password,
  });
}

class SignInUsecase extends UsecaseWithParams<AuthEntity, SignInParams> {
  final AuthRepo _authRepo;

  const SignInUsecase(this._authRepo);

  @override
  ResultFuture<AuthEntity> call(SignInParams params) {
    return _authRepo.signIn(
      email: params.email,
      password: params.password,
    );
  }
}
