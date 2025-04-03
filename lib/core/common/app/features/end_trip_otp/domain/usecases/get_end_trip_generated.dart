

import 'package:desktop_app/core/common/app/features/end_trip_otp/domain/repo/end_trip_otp_repo.dart';
import 'package:desktop_app/core/typedefs/typedefs.dart';
import 'package:desktop_app/core/usecases/usecase.dart';

class GetEndTripGeneratedOtp extends UsecaseWithoutParams<String> {
  const GetEndTripGeneratedOtp(this._repo);

  final EndTripOtpRepo _repo;

  @override
  ResultFuture<String> call() async => _repo.getEndGeneratedOtp();
}
