

import 'package:xpro_delivery_admin_app/core/common/app/features/end_trip_otp/domain/entity/end_trip_otp_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/end_trip_otp/domain/repo/end_trip_otp_repo.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';
import 'package:xpro_delivery_admin_app/core/usecases/usecase.dart';

class LoadEndTripOtpByTripId
    extends UsecaseWithParams<EndTripOtpEntity, String> {
  final EndTripOtpRepo _repo;

  LoadEndTripOtpByTripId(this._repo);
  @override
  ResultFuture<EndTripOtpEntity> call(String params) =>
      _repo.loadEndTripOtpByTripId(params);
}
