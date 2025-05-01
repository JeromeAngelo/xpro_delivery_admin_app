import 'package:xpro_delivery_admin_app/core/common/app/features/otp/domain/entity/otp_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/otp/domain/repo/otp_repo.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';
import 'package:xpro_delivery_admin_app/core/usecases/usecase.dart';
import 'package:equatable/equatable.dart';

class CreateOtp implements UsecaseWithParams<OtpEntity, CreateOtpParams> {
  final OtpRepo _repo;

  const CreateOtp(this._repo);

  @override
  ResultFuture<OtpEntity> call(CreateOtpParams params) => 
      _repo.createOtp(
        otpCode: params.otpCode,
        tripId: params.tripId,
        generatedCode: params.generatedCode,
        intransitOdometer: params.intransitOdometer,
        isVerified: params.isVerified,
        verifiedAt: params.verifiedAt,
      );
}

class CreateOtpParams extends Equatable {
  final String otpCode;
  final String tripId;
  final String? generatedCode;
  final String? intransitOdometer;
  final bool isVerified;
  final DateTime? verifiedAt;

  const CreateOtpParams({
    required this.otpCode,
    required this.tripId,
    this.generatedCode,
    this.intransitOdometer,
    this.isVerified = false,
    this.verifiedAt,
  });

  @override
  List<Object?> get props => [
    otpCode,
    tripId,
    generatedCode,
    intransitOdometer,
    isVerified,
    verifiedAt,
  ];
}
