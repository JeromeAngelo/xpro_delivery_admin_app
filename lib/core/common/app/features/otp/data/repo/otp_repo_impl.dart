import 'package:dartz/dartz.dart';
import 'package:desktop_app/core/common/app/features/otp/data/datasource/remote_data_source/otp_remote_datasource.dart';
import 'package:desktop_app/core/common/app/features/otp/domain/entity/otp_entity.dart';
import 'package:desktop_app/core/common/app/features/otp/domain/repo/otp_repo.dart';
import 'package:desktop_app/core/errors/exceptions.dart';
import 'package:desktop_app/core/errors/failures.dart';
import 'package:desktop_app/core/typedefs/typedefs.dart';
import 'package:flutter/material.dart';

class OtpRepoImpl implements OtpRepo {
  const OtpRepoImpl(this._remoteDataSource);

  final OtpRemoteDataSource _remoteDataSource;

  @override
  ResultFuture<String> getGeneratedOtp() async {
    try {
      final remoteOtp = await _remoteDataSource.getGeneratedOtp();
      return Right(remoteOtp);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  ResultFuture<bool> verifyInTransitOtp({
    required String enteredOtp,
    required String generatedOtp,
    required String tripId,
    required String otpId,
    required String odometerReading,
  }) async {
    try {
      debugPrint('🔐 Verifying in-transit OTP');
      final remoteResult = await _remoteDataSource.verifyInTransitOtp(
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
  ResultFuture<bool> verifyEndDeliveryOtp({
    required String enteredOtp,
    required String generatedOtp,
  }) async {
    try {
      final remoteResult = await _remoteDataSource.verifyEndDeliveryOtp(
        enteredOtp: enteredOtp,
        generatedOtp: generatedOtp,
      );
      return Right(remoteResult);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  ResultFuture<OtpEntity> loadOtpByTripId(String tripId) async {
    try {
      debugPrint('🔄 Loading OTP data for trip: $tripId');
      final remoteOtp = await _remoteDataSource.loadOtpByTripId(tripId);
      debugPrint('✅ OTP data loaded successfully');
      return Right(remoteOtp);
    } on ServerException catch (e) {
      debugPrint('❌ Failed to load OTP: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  ResultFuture<OtpEntity> loadOtpById(String otpId) async {
    try {
      debugPrint('🔄 Loading OTP data for ID: $otpId');
      final remoteOtp = await _remoteDataSource.loadOtpById(otpId);
      return Right(remoteOtp);
    } on ServerException catch (e) {
       debugPrint('❌ Failed to load OTP: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  ResultFuture<List<OtpEntity>> getAllOtps() async {
    try {
      debugPrint('🔄 Getting all OTPs from remote');
      final remoteOtps = await _remoteDataSource.getAllOtps();
      debugPrint('✅ Successfully retrieved ${remoteOtps.length} OTPs');
      return Right(remoteOtps);
    } on ServerException catch (e) {
      debugPrint('❌ Server error getting all OTPs: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  ResultFuture<OtpEntity> createOtp({
    required String otpCode,
    required String tripId,
    String? generatedCode,
    String? intransitOdometer,
    bool isVerified = false,
    DateTime? verifiedAt,
  }) async {
    try {
      debugPrint('🔄 Creating new OTP');
      final createdOtp = await _remoteDataSource.createOtp(
        otpCode: otpCode,
        tripId: tripId,
        generatedCode: generatedCode,
        intransitOdometer: intransitOdometer,
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
  ResultFuture<OtpEntity> updateOtp({
    required String id,
    String? otpCode,
    String? tripId,
    String? generatedCode,
    String? intransitOdometer,
    bool? isVerified,
    DateTime? verifiedAt,
  }) async {
    try {
      debugPrint('🔄 Updating OTP: $id');
      final updatedOtp = await _remoteDataSource.updateOtp(
        id: id,
        otpCode: otpCode,
        tripId: tripId,
        generatedCode: generatedCode,
        intransitOdometer: intransitOdometer,
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
  ResultFuture<bool> deleteOtp(String id) async {
    try {
      debugPrint('🔄 Deleting OTP: $id');
      final result = await _remoteDataSource.deleteOtp(id);
      debugPrint('✅ Successfully deleted OTP');
      return Right(result);
    } on ServerException catch (e) {
      debugPrint('❌ Server error deleting OTP: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  ResultFuture<bool> deleteAllOtps(List<String> ids) async {
    try {
      debugPrint('🔄 Deleting multiple OTPs: ${ids.length} items');
      final result = await _remoteDataSource.deleteAllOtps(ids);
      debugPrint('✅ Successfully deleted all OTPs');
      return Right(result);
    } on ServerException catch (e) {
      debugPrint('❌ Server error deleting multiple OTPs: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }
}
