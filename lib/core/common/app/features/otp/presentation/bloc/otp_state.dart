import 'package:xpro_delivery_admin_app/core/common/app/features/otp/domain/entity/otp_entity.dart';
import 'package:equatable/equatable.dart';

abstract class OtpState extends Equatable {
  const OtpState();
  
  @override
  List<Object?> get props => [];
}

class OtpInitial extends OtpState {
  const OtpInitial();
}

class OtpLoading extends OtpState {
  const OtpLoading();
}

class OtpDataLoaded extends OtpState {
  final OtpEntity otp;
  
  const OtpDataLoaded(this.otp);
  
  @override
  List<Object?> get props => [otp];
}

class OtpByIdLoaded extends OtpState {
  final OtpEntity otp;
  
  const OtpByIdLoaded(this.otp);
  
  @override
  List<Object?> get props => [otp];
}

class OtpVerified extends OtpState {
  final bool isVerified;
  final String otpType;
  final String? odometerReading;

  const OtpVerified({
    required this.isVerified,
    required this.otpType,
    this.odometerReading,
  });

  @override
  List<Object?> get props => [isVerified, otpType, odometerReading];
}

class OtpLoaded extends OtpState {
  final String generatedOtp;
  final String? otpId;
  final String? tripId;

  const OtpLoaded({
    required this.generatedOtp,
    this.otpId,
    this.tripId,
  });

  @override
  List<Object?> get props => [generatedOtp, otpId, tripId];
}

// New states
class AllOtpsLoaded extends OtpState {
  final List<OtpEntity> otps;
  
  const AllOtpsLoaded(this.otps);
  
  @override
  List<Object?> get props => [otps];
}

class OtpCreated extends OtpState {
  final OtpEntity otp;
  
  const OtpCreated(this.otp);
  
  @override
  List<Object?> get props => [otp];
}

class OtpUpdated extends OtpState {
  final OtpEntity otp;
  
  const OtpUpdated(this.otp);
  
  @override
  List<Object?> get props => [otp];
}

class OtpDeleted extends OtpState {
  final String id;
  
  const OtpDeleted(this.id);
  
  @override
  List<Object?> get props => [id];
}

class AllOtpsDeleted extends OtpState {
  final List<String> ids;
  
  const AllOtpsDeleted(this.ids);
  
  @override
  List<Object?> get props => [ids];
}

class OtpError extends OtpState {
  final String message;

  const OtpError({required this.message});

  @override
  List<Object?> get props => [message];
}
