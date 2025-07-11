import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/trip/data/models/trip_models.dart';
import 'package:xpro_delivery_admin_app/core/errors/exceptions.dart';
import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';

import '../../model/end_trip_model.dart';
abstract class EndTripOtpRemoteDataSource {
  Future<String> getEndGeneratedOtp();
  Future<EndTripOtpModel> loadEndTripOtpByTripId(String tripId);
  Future<EndTripOtpModel> loadEndTripOtpById(String otpId);
  Future<bool> verifyEndTripOtp({
    required String enteredOtp,
    required String generatedOtp,
    required String tripId,
    required String otpId,
    required String odometerReading,
  });
   // New functions
  Future<List<EndTripOtpModel>> getAllEndTripOtps();
  Future<EndTripOtpModel> createEndTripOtp({
    required String otpCode,
    required String tripId,
    String? generatedCode,
    String? endTripOdometer,
    bool isVerified = false,
    DateTime? verifiedAt,
  });
  Future<EndTripOtpModel> updateEndTripOtp({
    required String id,
    String? otpCode,
    String? tripId,
    String? generatedCode,
    String? endTripOdometer,
    bool? isVerified,
    DateTime? verifiedAt,
  });
  Future<bool> deleteEndTripOtp(String id);
  Future<bool> deleteAllEndTripOtps(List<String> ids);
}

class EndTripOtpRemoteDataSourceImpl implements EndTripOtpRemoteDataSource {
  const EndTripOtpRemoteDataSourceImpl({required PocketBase pocketBaseClient})
      : _pocketBaseClient = pocketBaseClient;

  final PocketBase _pocketBaseClient;

  @override
  Future<bool> verifyEndTripOtp({
    required String enteredOtp,
    required String generatedOtp,
    required String tripId,
    required String otpId,
    required String odometerReading,
  }) async {
    try {
      debugPrint('🔍 Verifying End-Trip OTP...');
      debugPrint('Entered OTP: $enteredOtp');
      debugPrint('Generated OTP: $generatedOtp');
      debugPrint('Trip ID: $tripId');
      debugPrint('OTP ID: $otpId');
      debugPrint('Odometer Reading: $odometerReading');

      final otpRecord = await _pocketBaseClient.collection('endTripOtp').getOne(otpId);
      final backendGeneratedCode = otpRecord.data['generatedCode'] as String;
      debugPrint('Backend Generated Code: $backendGeneratedCode');

      if (enteredOtp == backendGeneratedCode) {
        await _pocketBaseClient.collection('endTripOtp').update(
          otpId,
          body: {
            'otpCode': enteredOtp,
            'isVerified': true,
            'verifiedAt': DateTime.now().toIso8601String(),
            'otpType': 'endDelivery',
            'trip': tripId,
            'endTripOdometer': odometerReading,
          },
        );

        await _pocketBaseClient.collection('tripticket').update(
          tripId,
          body: {
            'endTripOtp': otpId,
            'isEndTrip': true,
            'timeEndTrip': DateTime.now().toUtc().toIso8601String(),
            'isAccepted': false,
          },
        );

        final currentUser = _pocketBaseClient.authStore.model;
        if (currentUser != null) {
          debugPrint('🔄 Clearing trip assignment for user: ${currentUser.id}');
          await _pocketBaseClient.collection('users').update(
            currentUser.id,
            body: {
              'tripNumberId': null,
            },
          );
          debugPrint('✅ User trip assignment cleared');
        }

        debugPrint('✅ End Trip OTP verified successfully');
        return true;
      }

      debugPrint('❌ End Trip OTP verification failed: Code mismatch');
      return false;
    } catch (e) {
      debugPrint('❌ End Trip OTP verification error: ${e.toString()}');
      throw ServerException(
        message: 'Failed to verify End Trip OTP: ${e.toString()}',
        statusCode: '500',
      );
    }
  }

  @override
  Future<String> getEndGeneratedOtp() async {
    try {
      final otpRecords = await _pocketBaseClient.collection('endTripOtp').getFullList();

      if (otpRecords.isNotEmpty) {
        final generatedCode = otpRecords.first.data['generatedCode'];
        if (generatedCode != null) {
          return generatedCode.toString();
        }
        throw const ServerException(
          message: 'Generated End Trip OTP code is null',
          statusCode: '404',
        );
      }
      throw const ServerException(
        message: 'No End Trip OTP records found',
        statusCode: '404',
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to get End Trip OTP: ${e.toString()}',
        statusCode: '500',
      );
    }
  }

  @override
  Future<EndTripOtpModel> loadEndTripOtpByTripId(String tripId) async {
    try {
      debugPrint('🔍 Loading End Trip OTP for trip: $tripId');

      final otpRecords = await _pocketBaseClient.collection('endTripOtp').getFullList(
        expand: 'trip',
        filter: 'trip = "$tripId"',
      );

      if (otpRecords.isEmpty) {
        throw const ServerException(
          message: 'No End Trip OTP found for this trip',
          statusCode: '404',
        );
      }

      final record = otpRecords.first;
      debugPrint('✅ Found End Trip OTP record: ${record.id}');

      return EndTripOtpModel(
        id: record.id,
        generatedCode: record.data['generatedCode'],
        otpCode: record.data['otpCode'],
        isVerified: record.data['isVerified'] ?? false,
        verifiedAt: DateTime.tryParse(record.data['verifiedAt'] ?? ''),
        expiresAt: DateTime.now().add(const Duration(minutes: 5)),
        trip: TripModel(id: tripId),
        endTripOdometer: record.data['endTripOdometer'],
      );
    } catch (e) {
      debugPrint('❌ Error loading End Trip OTP: ${e.toString()}');
      throw ServerException(
        message: 'Failed to load End Trip OTP: ${e.toString()}',
        statusCode: '500',
      );
    }
  }

  @override
  Future<EndTripOtpModel> loadEndTripOtpById(String otpId) async {
    try {
      debugPrint('🔍 Loading End Trip OTP by ID: $otpId');

      final record = await _pocketBaseClient.collection('endTripOtp').getOne(
        otpId,
        expand: 'trip',
      );

      return EndTripOtpModel(
        id: record.id,
        generatedCode: record.data['generatedCode'],
        otpCode: record.data['otpCode'],
        isVerified: record.data['isVerified'] ?? false,
        verifiedAt: DateTime.tryParse(record.data['verifiedAt'] ?? ''),
        expiresAt: DateTime.now().add(const Duration(minutes: 5)),
        trip: TripModel(id: record.data['trip']),
        endTripOdometer: record.data['endTripOdometer'],
      );
    } catch (e) {
      debugPrint('❌ Error loading End Trip OTP by ID: ${e.toString()}');
      throw ServerException(
        message: 'Failed to load End Trip OTP by ID: ${e.toString()}',
        statusCode: '500',
      );
    }
  }
  
  @override
  Future<List<EndTripOtpModel>> getAllEndTripOtps() async {
    try {
      debugPrint('🔄 Fetching all end trip OTPs');
      
      final records = await _pocketBaseClient.collection('endTripOtp').getFullList(
        expand: 'trip',
      );
      
      debugPrint('✅ Successfully fetched ${records.length} end trip OTPs');
      
      return records.map((record) {
        return EndTripOtpModel(
          id: record.id,
          generatedCode: record.data['generatedCode'],
          otpCode: record.data['otpCode'],
          isVerified: record.data['isVerified'] ?? false,
          verifiedAt: DateTime.tryParse(record.data['verifiedAt'] ?? ''),
          expiresAt: DateTime.now().add(const Duration(minutes: 5)),
          trip: TripModel(id: record.data['trip']),
          endTripOdometer: record.data['endTripOdometer'],
        );
      }).toList();
    } catch (e) {
      debugPrint('❌ Error fetching all end trip OTPs: ${e.toString()}');
      throw ServerException(
        message: 'Failed to fetch all end trip OTPs: ${e.toString()}',
        statusCode: '500',
      );
    }
  }
  
  @override
  Future<EndTripOtpModel> createEndTripOtp({
    required String otpCode,
    required String tripId,
    String? generatedCode,
    String? endTripOdometer,
    bool isVerified = false,
    DateTime? verifiedAt,
  }) async {
    try {
      debugPrint('🔄 Creating new end trip OTP for trip: $tripId');
      
      final body = {
        'otpCode': otpCode,
        'trip': tripId,
        'isVerified': isVerified,
        'otpType': 'endDelivery',
      };
      
      if (generatedCode != null) {
        body['generatedCode'] = generatedCode;
      }
      
      if (endTripOdometer != null) {
        body['endTripOdometer'] = endTripOdometer;
      }
      
      if (verifiedAt != null) {
        body['verifiedAt'] = verifiedAt.toIso8601String();
      }
      
      final record = await _pocketBaseClient.collection('endTripOtp').create(
        body: body,
      );
      
      // Get the created record with expanded relations
      final createdRecord = await _pocketBaseClient.collection('endTripOtp').getOne(
        record.id,
        expand: 'trip',
      );
      
      debugPrint('✅ Successfully created end trip OTP with ID: ${record.id}');
      
      return EndTripOtpModel(
        id: createdRecord.id,
        generatedCode: createdRecord.data['generatedCode'],
        otpCode: createdRecord.data['otpCode'],
        isVerified: createdRecord.data['isVerified'] ?? false,
        verifiedAt: DateTime.tryParse(createdRecord.data['verifiedAt'] ?? ''),
        expiresAt: DateTime.now().add(const Duration(minutes: 5)),
        trip: TripModel(id: tripId),
        endTripOdometer: createdRecord.data['endTripOdometer'],
      );
    } catch (e) {
      debugPrint('❌ Error creating end trip OTP: ${e.toString()}');
      throw ServerException(
        message: 'Failed to create end trip OTP: ${e.toString()}',
        statusCode: '500',
      );
    }
  }
  
  @override
  Future<EndTripOtpModel> updateEndTripOtp({
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
      
      final body = <String, dynamic>{};
      
      if (otpCode != null) {
        body['otpCode'] = otpCode;
      }
      
      if (tripId != null) {
        body['trip'] = tripId;
      }
      
      if (generatedCode != null) {
        body['generatedCode'] = generatedCode;
      }
      
      if (endTripOdometer != null) {
        body['endTripOdometer'] = endTripOdometer;
      }
      
      if (isVerified != null) {
        body['isVerified'] = isVerified;
      }
      
      if (verifiedAt != null) {
        body['verifiedAt'] = verifiedAt.toIso8601String();
      }
      
      await _pocketBaseClient.collection('endTripOtp').update(
        id,
        body: body,
      );
      
      // Get the updated record with expanded relations
      final updatedRecord = await _pocketBaseClient.collection('endTripOtp').getOne(
        id,
        expand: 'trip',
      );
      
      debugPrint('✅ Successfully updated end trip OTP');
      
      return EndTripOtpModel(
        id: updatedRecord.id,
        generatedCode: updatedRecord.data['generatedCode'],
        otpCode: updatedRecord.data['otpCode'],
        isVerified: updatedRecord.data['isVerified'] ?? false,
        verifiedAt: DateTime.tryParse(updatedRecord.data['verifiedAt'] ?? ''),
        expiresAt: DateTime.now().add(const Duration(minutes: 5)),
        trip: TripModel(id: updatedRecord.data['trip']),
        endTripOdometer: updatedRecord.data['endTripOdometer'],
      );
    } catch (e) {
      debugPrint('❌ Error updating end trip OTP: ${e.toString()}');
      throw ServerException(
        message: 'Failed to update end trip OTP: ${e.toString()}',
        statusCode: '500',
      );
    }
  }
  
  @override
  Future<bool> deleteEndTripOtp(String id) async {
    try {
      debugPrint('🔄 Deleting end trip OTP: $id');
      
      await _pocketBaseClient.collection('endTripOtp').delete(id);
      
      debugPrint('✅ Successfully deleted end trip OTP');
      return true;
    } catch (e) {
      debugPrint('❌ Error deleting end trip OTP: ${e.toString()}');
      throw ServerException(
        message: 'Failed to delete end trip OTP: ${e.toString()}',
        statusCode: '500',
      );
    }
  }
  
  @override
  Future<bool> deleteAllEndTripOtps(List<String> ids) async {
    try {
      debugPrint('🔄 Deleting multiple end trip OTPs: ${ids.length} items');
      
      // Use Future.wait to delete all items in parallel
      await Future.wait(
        ids.map((id) => _pocketBaseClient.collection('endTripOtp').delete(id))
      );
      
      debugPrint('✅ Successfully deleted all end trip OTPs');
      return true;
    } catch (e) {
      debugPrint('❌ Error deleting multiple end trip OTPs: ${e.toString()}');
      throw ServerException(
        message: 'Failed to delete multiple end trip OTPs: ${e.toString()}',
        statusCode: '500',
      );
    }
  }
}
