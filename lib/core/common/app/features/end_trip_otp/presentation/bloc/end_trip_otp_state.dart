import 'package:xpro_delivery_admin_app/core/common/app/features/end_trip_otp/domain/entity/end_trip_otp_entity.dart';
import 'package:equatable/equatable.dart';

abstract class EndTripOtpState extends Equatable {
  const EndTripOtpState();
  
  @override
  List<Object?> get props => [];
}

class EndTripOtpInitial extends EndTripOtpState {
  const EndTripOtpInitial();
}

class EndTripOtpLoading extends EndTripOtpState {
  const EndTripOtpLoading();
}

class EndTripOtpDataLoaded extends EndTripOtpState {
  final EndTripOtpEntity otp;
  
  const EndTripOtpDataLoaded(this.otp);
  
  @override
  List<Object?> get props => [otp];
}

class EndTripOtpByIdLoaded extends EndTripOtpState {
  final EndTripOtpEntity otp;
  
  const EndTripOtpByIdLoaded(this.otp);
  
  @override
  List<Object?> get props => [otp];
}

class EndTripOtpVerified extends EndTripOtpState {
  final bool isVerified;
  final String otpType;
  final String odometerReading;

  const EndTripOtpVerified({
    required this.isVerified,
    required this.otpType,
    required this.odometerReading,
  });

  @override
  List<Object?> get props => [isVerified, otpType, odometerReading];
}

class EndTripOtpLoaded extends EndTripOtpState {
  final String generatedOtp;
  final String? otpId;
  final String? tripId;

  const EndTripOtpLoaded({
    required this.generatedOtp,
    this.otpId,
    this.tripId,
  });

  @override
  List<Object?> get props => [generatedOtp, otpId, tripId];
}

// New states
class AllEndTripOtpsLoaded extends EndTripOtpState {
  final List<EndTripOtpEntity> otps;
  
  const AllEndTripOtpsLoaded(this.otps);
  
  @override
  List<Object?> get props => [otps];
}

class EndTripOtpCreated extends EndTripOtpState {
  final EndTripOtpEntity otp;
  
  const EndTripOtpCreated(this.otp);
  
  @override
  List<Object?> get props => [otp];
}

class EndTripOtpUpdated extends EndTripOtpState {
  final EndTripOtpEntity otp;
  
  const EndTripOtpUpdated(this.otp);
  
  @override
  List<Object?> get props => [otp];
}

class EndTripOtpDeleted extends EndTripOtpState {
  final String id;
  
  const EndTripOtpDeleted(this.id);
  
  @override
  List<Object?> get props => [id];
}

class AllEndTripOtpsDeleted extends EndTripOtpState {
  final List<String> ids;
  
  const AllEndTripOtpsDeleted(this.ids);
  
  @override
  List<Object?> get props => [ids];
}

class EndTripOtpError extends EndTripOtpState {
  final String message;

  const EndTripOtpError({required this.message});

  @override
  List<Object?> get props => [message];
}
