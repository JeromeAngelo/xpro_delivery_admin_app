import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/trip/data/models/trip_models.dart';
import 'package:xpro_delivery_admin_app/core/enums/otp_type.dart';
import 'package:equatable/equatable.dart';


class OtpEntity extends Equatable {
  String id;
  String otpCode;
  String? generatedCode;
  String? intransitOdometer;
  bool isVerified;
  DateTime createdAt;
  DateTime expiresAt;
  OtpType otpType;
  DateTime? verifiedAt;
  final TripModel? trip;

  OtpEntity({
    required this.id,
    required this.otpCode,
    this.generatedCode,
    this.intransitOdometer,
    required this.isVerified,
    required this.createdAt,
    required this.expiresAt,
    this.otpType = OtpType.inTransit,
    this.verifiedAt,
    this.trip,
  });

  @override
  List<Object?> get props => [
        id,
        otpCode,
        generatedCode,
        intransitOdometer,
        isVerified,
        createdAt,
        expiresAt,
        otpType,
        verifiedAt,
        trip,
      ];
}
