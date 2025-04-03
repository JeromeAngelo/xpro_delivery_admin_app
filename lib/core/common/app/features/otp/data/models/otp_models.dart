import 'package:desktop_app/core/common/app/features/Trip_Ticket/trip/data/models/trip_models.dart';
import 'package:desktop_app/core/common/app/features/otp/domain/entity/otp_entity.dart';
import 'package:desktop_app/core/enums/otp_type.dart';

class OtpModel extends OtpEntity {
  String? tripId;
  String _otpTypeString = OtpType.inTransit.toString();

  OtpModel({
    String? id,
    String? otpCode,
    super.intransitOdometer,
    super.generatedCode,
    bool? isVerified,
    DateTime? createdAt,
    DateTime? expiresAt,
    OtpType? otpType,
    super.verifiedAt,
    super.trip,
  }) : tripId = trip?.id,
       _otpTypeString = (otpType ?? OtpType.inTransit).toString(),
       super(
         id: id ?? '',
         otpCode: otpCode ?? '',
         isVerified: isVerified ?? false,
         createdAt: createdAt ?? DateTime.now(),
         expiresAt: expiresAt ?? DateTime.now().add(const Duration(minutes: 5)),
         otpType: otpType ?? OtpType.inTransit,
       );

  @override
  OtpType get otpType => OtpType.values.firstWhere(
        (type) => type.toString() == _otpTypeString,
        orElse: () => OtpType.inTransit,
      );

  @override
  set otpType(OtpType type) {
    _otpTypeString = type.toString();
  }

  factory OtpModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic value) {
      if (value == null || value.toString().isEmpty) return null;
      try {
        return DateTime.parse(value.toString()).toUtc();
      } catch (_) {
        return null;
      }
    }

    return OtpModel(
      id: json['id']?.toString(),
      otpCode: json['otpCode']?.toString(),
      generatedCode: json['generatedCode']?.toString(),
      intransitOdometer: json['intransitOdometer']?.toString(),
      isVerified: json['isVerified'] as bool?,
      createdAt: parseDate(json['createdAt']) ?? DateTime.now().toUtc(),
      expiresAt: parseDate(json['expiresAt']) ??
          DateTime.now().add(const Duration(minutes: 5)).toUtc(),
      verifiedAt: parseDate(json['verifiedAt']),
      otpType: OtpType.values.firstWhere(
        (type) => type.toString() == json['otpType']?.toString(),
        orElse: () => OtpType.inTransit,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'otpCode': otpCode,
      'generatedCode': generatedCode,
      'intransitOdometer': intransitOdometer,
      'isVerified': isVerified,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
      'otpType': _otpTypeString,
      'verifiedAt': verifiedAt?.toIso8601String(),
      'trip': tripId,
    };
  }

  OtpModel copyWith({
    String? id,
    String? otpCode,
    String? generatedCode,
    bool? isVerified,
    DateTime? createdAt,
    String? intransitOdometer,
    DateTime? expiresAt,
    OtpType? otpType,
    DateTime? verifiedAt,
    TripModel? trip,
  }) {
    return OtpModel(
      id: id ?? this.id,
      otpCode: otpCode ?? this.otpCode,
      generatedCode: generatedCode ?? this.generatedCode,
      isVerified: isVerified ?? this.isVerified,
      intransitOdometer: intransitOdometer ?? this.intransitOdometer,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      otpType: otpType ?? this.otpType,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      trip: trip ?? this.trip,
    );
  }
}
