import 'package:equatable/equatable.dart';

abstract class EndTripOtpEvent extends Equatable {
  const EndTripOtpEvent();
  
  @override
  List<Object?> get props => [];
}

class LoadEndTripOtpByIdEvent extends EndTripOtpEvent {
  final String otpId;

  const LoadEndTripOtpByIdEvent(this.otpId);

  @override
  List<Object?> get props => [otpId];
}

class LoadEndTripOtpByTripIdEvent extends EndTripOtpEvent {
  final String tripId;

  const LoadEndTripOtpByTripIdEvent(this.tripId);

  @override
  List<Object?> get props => [tripId];
}

class GetEndGeneratedOtpEvent extends EndTripOtpEvent {
  const GetEndGeneratedOtpEvent();
}

class VerifyEndTripOtpEvent extends EndTripOtpEvent {
  final String enteredOtp;
  final String generatedOtp;
  final String tripId;
  final String otpId;
  final String odometerReading;

  const VerifyEndTripOtpEvent({
    required this.enteredOtp,
    required this.generatedOtp,
    required this.tripId,
    required this.otpId,
    required this.odometerReading,
  });

  @override
  List<Object?> get props => [
    enteredOtp, 
    generatedOtp, 
    tripId, 
    otpId, 
    odometerReading
  ];
}

// New events
class GetAllEndTripOtpsEvent extends EndTripOtpEvent {
  const GetAllEndTripOtpsEvent();
}

class CreateEndTripOtpEvent extends EndTripOtpEvent {
  final String otpCode;
  final String tripId;
  final String? generatedCode;
  final String? endTripOdometer;
  final bool isVerified;
  final DateTime? verifiedAt;

  const CreateEndTripOtpEvent({
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

class UpdateEndTripOtpEvent extends EndTripOtpEvent {
  final String id;
  final String? otpCode;
  final String? tripId;
  final String? generatedCode;
  final String? endTripOdometer;
  final bool? isVerified;
  final DateTime? verifiedAt;

  const UpdateEndTripOtpEvent({
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

class DeleteEndTripOtpEvent extends EndTripOtpEvent {
  final String id;

  const DeleteEndTripOtpEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class DeleteAllEndTripOtpsEvent extends EndTripOtpEvent {
  final List<String> ids;

  const DeleteAllEndTripOtpsEvent(this.ids);

  @override
  List<Object?> get props => [ids];
}
