import 'package:equatable/equatable.dart';

abstract class OtpEvent extends Equatable {
  const OtpEvent();
  
  @override
  List<Object?> get props => [];
}

class LoadOtpByIdEvent extends OtpEvent {
  final String otpId;

  const LoadOtpByIdEvent(this.otpId);

  @override
  List<Object?> get props => [otpId];
}

class LoadOtpByTripIdEvent extends OtpEvent {
  final String tripId;

  const LoadOtpByTripIdEvent(this.tripId);

  @override
  List<Object?> get props => [tripId];
}

class GetGeneratedOtpEvent extends OtpEvent {
  const GetGeneratedOtpEvent();
}

class VerifyInTransitOtpEvent extends OtpEvent {
  final String enteredOtp;
  final String generatedOtp;
  final String tripId;
  final String otpId;
  final String odometerReading;

  const VerifyInTransitOtpEvent({
    required this.enteredOtp,
    required this.generatedOtp,
    required this.tripId,
    required this.otpId,
    required this.odometerReading,
  });

  @override
  List<Object?> get props => [enteredOtp, generatedOtp, tripId, otpId, odometerReading];
}

class VerifyEndDeliveryOtpEvent extends OtpEvent {
  final String enteredOtp;
  final String generatedOtp;

  const VerifyEndDeliveryOtpEvent({
    required this.enteredOtp,
    required this.generatedOtp,
  });

  @override
  List<Object?> get props => [enteredOtp, generatedOtp];
}

// New events
class GetAllOtpsEvent extends OtpEvent {
  const GetAllOtpsEvent();
}

class CreateOtpEvent extends OtpEvent {
  final String otpCode;
  final String tripId;
  final String? generatedCode;
  final String? intransitOdometer;
  final bool isVerified;
  final DateTime? verifiedAt;

  const CreateOtpEvent({
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

class UpdateOtpEvent extends OtpEvent {
  final String id;
  final String? otpCode;
  final String? tripId;
  final String? generatedCode;
  final String? intransitOdometer;
  final bool? isVerified;
  final DateTime? verifiedAt;

  const UpdateOtpEvent({
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

class DeleteOtpEvent extends OtpEvent {
  final String id;

  const DeleteOtpEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class DeleteAllOtpsEvent extends OtpEvent {
  final List<String> ids;

  const DeleteAllOtpsEvent(this.ids);

  @override
  List<Object?> get props => [ids];
}
