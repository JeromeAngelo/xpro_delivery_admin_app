

import 'package:xpro_delivery_admin_app/core/common/app/features/general_auth/domain/repo/auth_repo.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';
import 'package:xpro_delivery_admin_app/core/usecases/usecase.dart';

class SignOut extends UsecaseWithoutParams<void> {
  const SignOut(this._repo);

  final GeneralUserRepo _repo;

  @override
  ResultFuture<void> call() async {
    return _repo.signOut();
  }
}
