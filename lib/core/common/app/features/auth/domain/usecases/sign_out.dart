import 'package:xpro_delivery_admin_app/core/common/app/features/auth/domain/repo/auth_repo.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';
import 'package:xpro_delivery_admin_app/core/usecases/usecase.dart';

class SignOutUsecase extends UsecaseWithoutParams<void> {
  final AuthRepo _repo;

  const SignOutUsecase(this._repo);

  @override
  ResultFuture<void> call() => _repo.signOut();
}
