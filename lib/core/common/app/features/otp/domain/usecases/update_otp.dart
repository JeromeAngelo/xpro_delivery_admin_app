import 'package:desktop_app/core/common/app/features/otp/domain/entity/otp_entity.dart';
import 'package:desktop_app/core/common/app/features/otp/domain/repo/otp_repo.dart';
import 'package:desktop_app/core/typedefs/typedefs.dart';
import 'package:desktop_app/core/usecases/usecase.dart';
import 'package:equatable/equatable.dart';

class UpdateOtp implements UsecaseWithParams<OtpEntity, UpdateOtpParams> {
  final OtpRepo _repo;

  const UpdateOtp(this._repo);

  @override
  ResultFuture<OtpEntity> call(UpdateOtpParams params) => 
      _repo.updateOtp(
        id: params.id,
        otpCode: params.otpCode,
        tripId: params.tripId,
        generatedCode: params.generatedCode,
        intransitOdometer: params.intransitOdometer,
        isVerified: params.isVerified,
        verifiedAt: params.verifiedAt,
      );
}

class UpdateOtpParams extends Equatable {
  final String id;
  final String? otpCode;
  final String? tripId;
  final String? generatedCode;
  final String? intransitOdometer;
  final bool? isVerified;
  final DateTime? verifiedAt;

  const UpdateOtpParams({
    required this.id,
    this.otpCode,
    this.tripId,
    this.generatedCode,
    this.intransitOdometer,
    this.isVerified,
    this.verifiedAt,
  });

  @override
  List<Object?> get props => [
    id,
    otpCode,
    tripId,
    generatedCode,
    intransitOdometer,
    isVerified,
    verifiedAt,
  ];
}
