import 'package:desktop_app/core/common/app/features/Trip_Ticket/trip/data/models/trip_models.dart';
import 'package:desktop_app/core/enums/otp_type.dart';
import 'package:equatable/equatable.dart';


class EndTripOtpEntity extends Equatable {
  String id;
  String otpCode;
  String? generatedCode;
  String? endTripOdometer;
  bool isVerified;
  DateTime createdAt;
  DateTime expiresAt;
  OtpType otpType;
  DateTime? verifiedAt;
  final TripModel? trip;

  EndTripOtpEntity({
    required this.id,
    required this.otpCode,
    this.endTripOdometer,
    this.generatedCode,
    required this.isVerified,
    required this.createdAt,
    required this.expiresAt,
    this.otpType = OtpType.endDelivery,
    this.verifiedAt,
    this.trip,
  });

  @override
  List<Object?> get props => [
        id,
        otpCode,
        generatedCode,
        endTripOdometer,
        isVerified,
        createdAt,
        expiresAt,
        otpType,
        verifiedAt,
        trip,
      ];
}
