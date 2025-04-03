import 'package:desktop_app/core/common/app/features/end_trip_otp/domain/entity/end_trip_otp_entity.dart';
import 'package:desktop_app/core/common/app/features/end_trip_otp/domain/repo/end_trip_otp_repo.dart';
import 'package:desktop_app/core/typedefs/typedefs.dart';
import 'package:desktop_app/core/usecases/usecase.dart';
import 'package:equatable/equatable.dart';

class UpdateEndTripOtp implements UsecaseWithParams<EndTripOtpEntity, UpdateEndTripOtpParams> {
  final EndTripOtpRepo _repo;

  const UpdateEndTripOtp(this._repo);

  @override
  ResultFuture<EndTripOtpEntity> call(UpdateEndTripOtpParams params) => 
      _repo.updateEndTripOtp(
        id: params.id,
        otpCode: params.otpCode,
        tripId: params.tripId,
        generatedCode: params.generatedCode,
        endTripOdometer: params.endTripOdometer,
        isVerified: params.isVerified,
        verifiedAt: params.verifiedAt,
      );
}

class UpdateEndTripOtpParams extends Equatable {
  final String id;
  final String? otpCode;
  final String? tripId;
  final String? generatedCode;
  final String? endTripOdometer;
  final bool? isVerified;
  final DateTime? verifiedAt;

  const UpdateEndTripOtpParams({
    required this.id,
    this.otpCode,
    this.tripId,
    this.generatedCode,
    this.endTripOdometer,
    this.isVerified,
    this.verifiedAt,
  });

  @override
  List<Object?> get props => [
    id,
    otpCode,
    tripId,
    generatedCode,
    endTripOdometer,
    isVerified,
    verifiedAt,
  ];
}
