import 'package:desktop_app/core/common/app/features/otp/domain/repo/otp_repo.dart';
import 'package:desktop_app/core/typedefs/typedefs.dart';
import 'package:desktop_app/core/usecases/usecase.dart';


class VerifyInEndDeliveryParams {
  final String enteredOtp;
  final String generatedOtp;

  const VerifyInEndDeliveryParams({
    required this.enteredOtp,
    required this.generatedOtp,
  });
}

class VerifyInEndDelivery implements UsecaseWithParams<bool, VerifyInEndDeliveryParams> {
  const VerifyInEndDelivery(this._otpRepo);

  final OtpRepo _otpRepo;

  @override
  ResultFuture<bool> call(VerifyInEndDeliveryParams params) => _otpRepo.verifyEndDeliveryOtp(
        enteredOtp: params.enteredOtp,
        generatedOtp: params.generatedOtp,
      );
}
