import 'package:xpro_delivery_admin_app/core/common/app/features/end_trip_otp/domain/entity/end_trip_otp_entity.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';

abstract class EndTripOtpRepo {
  // Existing functions to keep
  ResultFuture<String> getEndGeneratedOtp();
  ResultFuture<EndTripOtpEntity> loadEndTripOtpByTripId(String tripId);
  ResultFuture<EndTripOtpEntity> loadEndTripOtpById(String otpId);
  ResultFuture<bool> verifyEndTripOtp({
    required String enteredOtp,
    required String generatedOtp,
    required String tripId,
    required String otpId,
    required String odometerReading,
  });

  // New functions
  // Get all end trip OTPs
  ResultFuture<List<EndTripOtpEntity>> getAllEndTripOtps();
  
  // Create a new end trip OTP
  ResultFuture<EndTripOtpEntity> createEndTripOtp({
    required String otpCode,
    required String tripId,
    String? generatedCode,
    String? endTripOdometer,
    bool isVerified = false,
    DateTime? verifiedAt,
  });
  
  // Update an existing end trip OTP
  ResultFuture<EndTripOtpEntity> updateEndTripOtp({
    required String id,
    String? otpCode,
    String? tripId,
    String? generatedCode,
    String? endTripOdometer,
    bool? isVerified,
    DateTime? verifiedAt,
  });
  
  // Delete a single end trip OTP
  ResultFuture<bool> deleteEndTripOtp(String id);
  
  // Delete multiple end trip OTPs
  ResultFuture<bool> deleteAllEndTripOtps(List<String> ids);
}
