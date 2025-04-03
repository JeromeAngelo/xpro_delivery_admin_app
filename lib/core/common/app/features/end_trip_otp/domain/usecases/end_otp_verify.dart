

import 'package:desktop_app/core/common/app/features/end_trip_otp/domain/repo/end_trip_otp_repo.dart';
import 'package:desktop_app/core/typedefs/typedefs.dart';
import 'package:desktop_app/core/usecases/usecase.dart';

class EndOTPVerify implements UsecaseWithParams<bool, EndOTPVerifyParams> {
  EndOTPVerify(this._repo);

  final EndTripOtpRepo _repo;
  @override
  ResultFuture<bool> call(params) => _repo.verifyEndTripOtp(
       enteredOtp: params.enteredOtp,
        generatedOtp: params.generatedOtp,
        tripId: params.tripId,
        otpId: params.otpId,
        odometerReading: params.odometerReading,
      );
}

class EndOTPVerifyParams {
 final String enteredOtp;
  final String generatedOtp;
  final String tripId;
  final String otpId;
  final String odometerReading;

  const EndOTPVerifyParams({
   required this.enteredOtp,
    required this.generatedOtp,
    required this.tripId,
    required this.otpId,
    required this.odometerReading,
  });
}
