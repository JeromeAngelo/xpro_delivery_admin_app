

import 'package:desktop_app/core/common/app/features/end_trip_otp/domain/entity/end_trip_otp_entity.dart';
import 'package:desktop_app/core/common/app/features/end_trip_otp/domain/repo/end_trip_otp_repo.dart';
import 'package:desktop_app/core/typedefs/typedefs.dart';
import 'package:desktop_app/core/usecases/usecase.dart';

class LoadEndTripOtpById extends UsecaseWithParams<EndTripOtpEntity, String> {
  final EndTripOtpRepo _repo;

  LoadEndTripOtpById(this._repo);

  @override
  ResultFuture<EndTripOtpEntity> call(String params) =>
      _repo.loadEndTripOtpById(params);
}
