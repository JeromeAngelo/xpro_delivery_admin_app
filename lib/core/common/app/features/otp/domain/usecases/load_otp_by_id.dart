

import 'package:xpro_delivery_admin_app/core/common/app/features/otp/domain/entity/otp_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/otp/domain/repo/otp_repo.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';
import 'package:xpro_delivery_admin_app/core/usecases/usecase.dart';

class LoadOtpById extends UsecaseWithParams<OtpEntity, String> {
  const LoadOtpById(this._repo);
  
  final OtpRepo _repo;

  @override
  ResultFuture<OtpEntity> call(String params) => _repo.loadOtpById(params);
}
