import 'package:equatable/equatable.dart';

import 'package:xpro_delivery_admin_app/core/common/app/features/general_auth/domain/entity/users_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/general_auth/domain/repo/auth_repo.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';
import 'package:xpro_delivery_admin_app/core/usecases/usecase.dart';

class SignIn extends UsecaseWithParams<GeneralUserEntity, SignInParams> {
  const SignIn(this._repo);

  final GeneralUserRepo _repo;

  @override
  ResultFuture<GeneralUserEntity> call(SignInParams params)  =>
      _repo.signIn(email: params.email, password: params.password);
}

class SignInParams extends Equatable {
  const SignInParams({required this.email, required this.password});

  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}
