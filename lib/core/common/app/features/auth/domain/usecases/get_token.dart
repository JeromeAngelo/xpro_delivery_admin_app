import 'package:xpro_delivery_admin_app/core/common/app/features/auth/domain/repo/auth_repo.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';
import 'package:xpro_delivery_admin_app/core/usecases/usecase.dart';

class GetTokenUsecase extends UsecaseWithoutParams<String?> {
  final AuthRepo _authRepo;

  const GetTokenUsecase(this._authRepo);

  @override
  ResultFuture<String?> call() {
    return _authRepo.getToken();
  }
}
