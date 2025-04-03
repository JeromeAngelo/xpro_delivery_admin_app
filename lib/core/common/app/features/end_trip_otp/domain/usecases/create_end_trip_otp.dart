import 'package:desktop_app/core/common/app/features/end_trip_otp/domain/entity/end_trip_otp_entity.dart';
import 'package:desktop_app/core/common/app/features/end_trip_otp/domain/repo/end_trip_otp_repo.dart';
import 'package:desktop_app/core/typedefs/typedefs.dart';
import 'package:desktop_app/core/usecases/usecase.dart';
import 'package:equatable/equatable.dart';

class CreateEndTripOtp implements UsecaseWithParams<EndTripOtpEntity, CreateEndTripOtpParams> {
  final EndTripOtpRepo _repo;

  const CreateEndTripOtp(this._repo);

  @override
  ResultFuture<EndTripOtpEntity> call(CreateEndTripOtpParams params) => 
      _repo.createEndTripOtp(
        otpCode: params.otpCode,
        tripId: params.tripId,
        generatedCode: params.generatedCode,
        endTripOdometer: params.endTripOdometer,
        isVerified: params.isVerified,
        verifiedAt: params.verifiedAt,
      );
}

class CreateEndTripOtpParams extends Equatable {
  final String otpCode;
  final String tripId;
  final String? generatedCode;
  final String? endTripOdometer;
  final bool isVerified;
  final DateTime? verifiedAt;

  const CreateEndTripOtpParams({
    required this.otpCode,
    required this.tripId,
    this.generatedCode,
    this.endTripOdometer,
    this.isVerified = false,
    this.verifiedAt,
  });

  @override
  List<Object?> get props => [
    otpCode,
    tripId,
    generatedCode,
    endTripOdometer,
    isVerified,
    verifiedAt,
  ];
}
