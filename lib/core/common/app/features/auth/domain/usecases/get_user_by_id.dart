import 'package:desktop_app/core/common/app/features/auth/domain/entity/auth_entity.dart';
import 'package:desktop_app/core/common/app/features/auth/domain/repo/auth_repo.dart';
import 'package:desktop_app/core/typedefs/typedefs.dart';
import 'package:desktop_app/core/usecases/usecase.dart';

class GetUserByIdParams {
  final String userId;

  const GetUserByIdParams({required this.userId});
}

class GetUserByIdUsecase extends UsecaseWithParams<AuthEntity, GetUserByIdParams> {
  final AuthRepo _authRepo;

  const GetUserByIdUsecase(this._authRepo);

  @override
  ResultFuture<AuthEntity> call(GetUserByIdParams params) {
    return _authRepo.getUserById(params.userId);
  }
}
