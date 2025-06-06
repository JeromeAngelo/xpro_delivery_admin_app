

import 'package:xpro_delivery_admin_app/core/common/app/features/otp/domain/repo/otp_repo.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';
import 'package:xpro_delivery_admin_app/core/usecases/usecase.dart';

class GetGeneratedOtp extends UsecaseWithoutParams<String> {
  const GetGeneratedOtp(this._repo);

  final OtpRepo _repo;

  @override
  ResultFuture<String> call() async => _repo.getGeneratedOtp();
}
