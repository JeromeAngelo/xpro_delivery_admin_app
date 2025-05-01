import 'package:dartz/dartz.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/end_trip_otp/data/datasources/remote_datasource/end_trip_otp_remote_datasource.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/end_trip_otp/domain/entity/end_trip_otp_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/end_trip_otp/domain/repo/end_trip_otp_repo.dart';
import 'package:xpro_delivery_admin_app/core/errors/exceptions.dart';
import 'package:xpro_delivery_admin_app/core/errors/failures.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';
import 'package:flutter/material.dart';

class EndTripOtpRepoImpl implements EndTripOtpRepo {
  const EndTripOtpRepoImpl(this._remoteDataSource);

  final EndTripOtpRemoteDataSource _remoteDataSource;

  @override
  ResultFuture<String> getEndGeneratedOtp() async {
    try {
      debugPrint('🔄 Fetching end trip OTP from remote');
      final remoteOtp = await _remoteDataSource.getEndGeneratedOtp();
      return Right(remoteOtp);
    } on ServerException catch (e) {
      debugPrint('❌ Remote fetch failed: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  ResultFuture<EndTripOtpEntity> loadEndTripOtpByTripId(String tripId) async {
    try {
      debugPrint('🔄 Loading OTP data for trip: $tripId');
      final remoteOtp = await _remoteDataSource.loadEndTripOtpByTripId(tripId);
      return Right(remoteOtp);
    } on ServerException catch (e) {
      debugPrint('❌ Failed to load OTP: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  ResultFuture<EndTripOtpEntity> loadEndTripOtpById(String otpId) async {
    try {
      debugPrint('🔄 Loading OTP by ID: $otpId');
      final remoteOtp = await _remoteDataSource.loadEndTripOtpById(otpId);
      return Right(remoteOtp);
    } on ServerException catch (e) {
      debugPrint('❌ Failed to load OTP: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  ResultFuture<bool> verifyEndTripOtp({
    required String enteredOtp,
    required String generatedOtp,
    required String tripId,
    required String otpId,
    required String odometerReading,
  }) async {
    try {
      debugPrint('🔐 Verifying end trip OTP');
      final remoteResult = await _remoteDataSource.verifyEndTripOtp(
        enteredOtp: enteredOtp,
        generatedOtp: generatedOtp,
        tripId: tripId,
        otpId: otpId,
        odometerReading: odometerReading,
      );
      return Right(remoteResult);
    } on ServerException catch (e) {
      debugPrint('❌ Remote verification failed: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  ResultFuture<List<EndTripOtpEntity>> getAllEndTripOtps() async {
    try {
      debugPrint('🔄 Getting all end trip OTPs from remote');
      final remoteOtps = await _remoteDataSource.getAllEndTripOtps();
      debugPrint('✅ Successfully retrieved ${remoteOtps.length} OTPs');
      return Right(remoteOtps);
    } on ServerException catch (e) {
      debugPrint('❌ Server error getting all OTPs: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  ResultFuture<EndTripOtpEntity> createEndTripOtp({
    required String otpCode,
    required String tripId,
    String? generatedCode,
    String? endTripOdometer,
    bool isVerified = false,
    DateTime? verifiedAt,
  }) async {
    try {
      debugPrint('🔄 Creating new end trip OTP');
      final createdOtp = await _remoteDataSource.createEndTripOtp(
        otpCode: otpCode,
        tripId: tripId,
        generatedCode: generatedCode,
        endTripOdometer: endTripOdometer,
        isVerified: isVerified,
        verifiedAt: verifiedAt,
      );
      debugPrint('✅ Successfully created OTP with ID: ${createdOtp.id}');
      return Right(createdOtp);
    } on ServerException catch (e) {
      debugPrint('❌ Server error creating OTP: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  ResultFuture<EndTripOtpEntity> updateEndTripOtp({
    required String id,
    String? otpCode,
    String? tripId,
    String? generatedCode,
    String? endTripOdometer,
    bool? isVerified,
    DateTime? verifiedAt,
  }) async {
    try {
      debugPrint('🔄 Updating end trip OTP: $id');
      final updatedOtp = await _remoteDataSource.updateEndTripOtp(
        id: id,
        otpCode: otpCode,
        tripId: tripId,
        generatedCode: generatedCode,
        endTripOdometer: endTripOdometer,
        isVerified: isVerified,
        verifiedAt: verifiedAt,
      );
      debugPrint('✅ Successfully updated OTP');
      return Right(updatedOtp);
    } on ServerException catch (e) {
      debugPrint('❌ Server error updating OTP: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  ResultFuture<bool> deleteEndTripOtp(String id) async {
    try {
      debugPrint('🔄 Deleting end trip OTP: $id');
      final result = await _remoteDataSource.deleteEndTripOtp(id);
      debugPrint('✅ Successfully deleted OTP');
      return Right(result);
    } on ServerException catch (e) {
      debugPrint('❌ Server error deleting OTP: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  ResultFuture<bool> deleteAllEndTripOtps(List<String> ids) async {
    try {
      debugPrint('🔄 Deleting multiple end trip OTPs: ${ids.length} items');
      final result = await _remoteDataSource.deleteAllEndTripOtps(ids);
      debugPrint('✅ Successfully deleted all OTPs');
      return Right(result);
    } on ServerException catch (e) {
      debugPrint('❌ Server error deleting multiple OTPs: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }
}
