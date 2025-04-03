import 'package:desktop_app/core/common/app/features/otp/domain/entity/otp_entity.dart';
import 'package:desktop_app/core/typedefs/typedefs.dart';

abstract class OtpRepo {
  // Existing functions to keep
  ResultFuture<String> getGeneratedOtp();
  ResultFuture<OtpEntity> loadOtpByTripId(String tripId);
  ResultFuture<OtpEntity> loadOtpById(String otpId);
  ResultFuture<bool> verifyInTransitOtp({
    required String enteredOtp,
    required String generatedOtp,
    required String tripId,
    required String otpId,
    required String odometerReading,
  });
  ResultFuture<bool> verifyEndDeliveryOtp({
    required String enteredOtp,
    required String generatedOtp,
  });

  // New functions
  // Get all OTPs
  ResultFuture<List<OtpEntity>> getAllOtps();
  
  // Create a new OTP
  ResultFuture<OtpEntity> createOtp({
    required String otpCode,
    required String tripId,
    String? generatedCode,
    String? intransitOdometer,
    bool isVerified = false,
    DateTime? verifiedAt,
  });
  
  // Update an existing OTP
  ResultFuture<OtpEntity> updateOtp({
    required String id,
    String? otpCode,
    String? tripId,
    String? generatedCode,
    String? intransitOdometer,
    bool? isVerified,
    DateTime? verifiedAt,
  });
  
  // Delete a single OTP
  ResultFuture<bool> deleteOtp(String id);
  
  // Delete multiple OTPs
  ResultFuture<bool> deleteAllOtps(List<String> ids);
}
