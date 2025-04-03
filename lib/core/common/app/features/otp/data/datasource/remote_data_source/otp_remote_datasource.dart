
import 'package:desktop_app/core/common/app/features/Trip_Ticket/trip/data/models/trip_models.dart';
import 'package:desktop_app/core/common/app/features/otp/data/models/otp_models.dart';
import 'package:desktop_app/core/enums/otp_type.dart';
import 'package:desktop_app/core/errors/exceptions.dart';
import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';


abstract class OtpRemoteDataSource {
  Future<bool> verifyInTransitOtp({
    required String enteredOtp,
    required String generatedOtp,
    required String tripId,
    required String otpId,
    required String odometerReading,
  });

  Future<bool> verifyEndDeliveryOtp({
    required String enteredOtp,
    required String generatedOtp,
  });

  Future<String> getGeneratedOtp();

  Future<OtpModel> loadOtpByTripId(String tripId);

  Future<OtpModel> loadOtpById(String otpId);

  // New functions
  Future<List<OtpModel>> getAllOtps();
  
  Future<OtpModel> createOtp({
    required String otpCode,
    required String tripId,
    String? generatedCode,
    String? intransitOdometer,
    bool isVerified = false,
    DateTime? verifiedAt,
  });
  
  Future<OtpModel> updateOtp({
    required String id,
    String? otpCode,
    String? tripId,
    String? generatedCode,
    String? intransitOdometer,
    bool? isVerified,
    DateTime? verifiedAt,
  });
  
  Future<bool> deleteOtp(String id);
  
  Future<bool> deleteAllOtps(List<String> ids);
}

class OtpRemoteDataSourceImpl implements OtpRemoteDataSource {
  const OtpRemoteDataSourceImpl({required PocketBase pocketBaseClient})
      : _pocketBaseClient = pocketBaseClient;

  final PocketBase _pocketBaseClient;
  @override
  Future<bool> verifyInTransitOtp({
    required String enteredOtp,
    required String generatedOtp,
    required String tripId,
    required String otpId,
    required String odometerReading,
  }) async {
    try {
      debugPrint('🔍 Verifying In-Transit OTP...');
      debugPrint('Trip ID: $tripId');
      debugPrint('OTP ID: $otpId');
      debugPrint('Odometer Reading: $odometerReading');

      final otpRecord = await _pocketBaseClient.collection('otp').getOne(otpId);
      final backendGeneratedCode = otpRecord.data['generatedCode'] as String;
      debugPrint('Backend Generated Code: $backendGeneratedCode');

      if (enteredOtp == backendGeneratedCode) {
        await _pocketBaseClient.collection('otp').update(
          otpId,
          body: {
            'otpCode': enteredOtp,
            'isVerified': true,
            'verifiedAt': DateTime.now().toIso8601String(),
            'otpType': 'inTransit',
            'trip': tripId,
            'intransitOdometer': odometerReading,
          },
        );

        debugPrint('✅ OTP verified and odometer reading saved successfully');
        return true;
      }

      debugPrint('❌ OTP verification failed: Code mismatch');
      return false;
    } catch (e) {
      debugPrint('❌ Verification error: ${e.toString()}');
      throw ServerException(
        message: 'Failed to verify OTP: ${e.toString()}',
        statusCode: '500',
      );
    }
  }

  @override
  Future<OtpModel> loadOtpById(String otpId) async {
    try {
      debugPrint('🔍 Loading OTP by ID: $otpId');

      // Add delay between requests
      await Future.delayed(const Duration(milliseconds: 500));

      final record = await _pocketBaseClient.collection('otp').getOne(
            otpId,
            expand: 'trip',
          );

      debugPrint('✅ Found OTP record: ${record.id}');
      debugPrint('📄 Full OTP Data: ${record.data}');

      return OtpModel(
        id: record.id,
        generatedCode: record.data['generatedCode'],
        otpCode: record.data['otpCode'],
        isVerified: record.data['isVerified'] ?? false,
        verifiedAt: DateTime.now().toUtc(),
        createdAt: DateTime.now().toUtc(),
        expiresAt: DateTime.now().add(const Duration(minutes: 5)).toUtc(),
        otpType: record.data['otpType']?.toString().isNotEmpty == true
            ? OtpType.values.firstWhere(
                (type) =>
                    type.toString() == 'OtpType.${record.data['otpType']}',
                orElse: () => OtpType.inTransit,
              )
            : OtpType.inTransit,
        trip: TripModel(id: record.data['trip']),
        intransitOdometer: record.data['intransitOdometer'],
      );
    } catch (e) {
      if (e.toString().contains('429')) {
        debugPrint('⚠️ Rate limit hit, retrying after delay...');
        await Future.delayed(const Duration(seconds: 2));
        return loadOtpById(otpId);
      }
      debugPrint('❌ Failed to load OTP by ID: $e');
      throw ServerException(
        message: 'Failed to load OTP by ID: ${e.toString()}',
        statusCode: '500',
      );
    }
  }

  @override
  Future<bool> verifyEndDeliveryOtp({
    required String enteredOtp,
    required String generatedOtp,
  }) async {
    try {
      print('🔍 Verifying End-Delivery OTP...');
      print('Entered OTP: $enteredOtp');
      print('Generated OTP: $generatedOtp');

      final otpRecords =
          await _pocketBaseClient.collection('otp').getFullList();

      if (otpRecords.isNotEmpty) {
        final record = otpRecords.first;
        final backendGeneratedCode = record.data['generatedCode'] as String;

        if (enteredOtp == backendGeneratedCode) {
          await _pocketBaseClient.collection('otp').update(
            record.id,
            body: {
              'otpCode': enteredOtp,
            },
          );
          print('✅ End-Delivery OTP verification successful!');
          return true;
        }
      }
      print('❌ End-Delivery OTP verification failed: OTP mismatch');
      return false;
    } catch (e) {
      print('❌ End-Delivery OTP verification error: ${e.toString()}');
      throw ServerException(
        message: 'Failed to verify end-delivery OTP: ${e.toString()}',
        statusCode: '500',
      );
    }
  }

  @override
  Future<String> getGeneratedOtp() async {
    try {
      final otpRecords =
          await _pocketBaseClient.collection('otp').getFullList();
      if (otpRecords.isNotEmpty) {
        final generatedCode = otpRecords.first.data['generatedCode'];
        if (generatedCode != null) {
          return generatedCode.toString();
        }
        throw const ServerException(
          message: 'Generated OTP code is null',
          statusCode: '404',
        );
      }
      throw const ServerException(
        message: 'No OTP records found',
        statusCode: '404',
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to get OTP: ${e.toString()}',
        statusCode: '500',
      );
    }
  }
@override
Future<OtpModel> loadOtpByTripId(String tripId) async {
  try {
    debugPrint('🔍 Starting OTP load process for trip: $tripId');

    // Direct query using provided trip ID without requiring user data
    debugPrint('🎯 Using direct trip ID on OTP: $tripId');
    final otpRecords = await _pocketBaseClient.collection('otp').getFullList(
          expand: 'trip',
          filter: 'trip = "$tripId"',
        );

    if (otpRecords.isEmpty) {
      debugPrint('⚠️ No OTP records found');
      throw const ServerException(
        message: 'No OTP found for this trip',
        statusCode: '404',
      );
    }

    final record = otpRecords.first;
    debugPrint('✅ Found OTP record ID: ${record.id}');
    debugPrint('📄 OTP Data: ${record.data}');

    return OtpModel(
      id: record.id,
      generatedCode: record.data['generatedCode'],
      otpCode: record.data['otpCode'],
      isVerified: record.data['isVerified'] ?? false,
      verifiedAt: DateTime.tryParse(record.data['verifiedAt'] ?? ''),
      createdAt: DateTime.parse(record.created),
      expiresAt: DateTime.now().add(const Duration(minutes: 5)),
      otpType: record.data['otpType']?.toString().isNotEmpty == true
          ? OtpType.values.firstWhere(
              (type) =>
                  type.toString() == 'OtpType.${record.data['otpType']}',
              orElse: () => OtpType.inTransit,
            )
          : OtpType.inTransit,
      trip: TripModel(id: tripId),
      intransitOdometer: record.data['intransitOdometer'],
    );
  } catch (e) {
    debugPrint('❌ Error in loadOtpByTripId: $e');
    throw ServerException(
      message: 'Failed to load OTP by trip id: ${e.toString()}',
      statusCode: '500',
    );
  }
}

  
  @override
  Future<List<OtpModel>> getAllOtps() async {
    try {
      debugPrint('🔄 Fetching all OTPs');
      
      final records = await _pocketBaseClient.collection('otp').getFullList(
        expand: 'trip',
      );
      
      debugPrint('✅ Successfully fetched ${records.length} OTPs');
      
      return records.map((record) {
        return OtpModel(
          id: record.id,
          generatedCode: record.data['generatedCode'],
          otpCode: record.data['otpCode'],
          isVerified: record.data['isVerified'] ?? false,
          verifiedAt: DateTime.tryParse(record.data['verifiedAt'] ?? ''),
          createdAt: DateTime.parse(record.created),
          expiresAt: DateTime.now().add(const Duration(minutes: 5)),
          otpType: record.data['otpType']?.toString().isNotEmpty == true
              ? OtpType.values.firstWhere(
                  (type) => type.toString() == 'OtpType.${record.data['otpType']}',
                  orElse: () => OtpType.inTransit,
                )
              : OtpType.inTransit,
          trip: TripModel(id: record.data['trip']),
          intransitOdometer: record.data['intransitOdometer'],
        );
      }).toList();
    } catch (e) {
      debugPrint('❌ Error fetching all OTPs: ${e.toString()}');
      throw ServerException(
        message: 'Failed to fetch all OTPs: ${e.toString()}',
        statusCode: '500',
      );
    }
  }
  
  @override
  Future<OtpModel> createOtp({
    required String otpCode,
    required String tripId,
    String? generatedCode,
    String? intransitOdometer,
    bool isVerified = false,
    DateTime? verifiedAt,
  }) async {
    try {
      debugPrint('🔄 Creating new OTP for trip: $tripId');
      
      final body = {
        'otpCode': otpCode,
        'trip': tripId,
        'isVerified': isVerified,
        'otpType': 'inTransit',
      };
      
      if (generatedCode != null) {
        body['generatedCode'] = generatedCode;
      }
      
      if (intransitOdometer != null) {
        body['intransitOdometer'] = intransitOdometer;
      }
      
      if (verifiedAt != null) {
        body['verifiedAt'] = verifiedAt.toIso8601String();
      }
      
      final record = await _pocketBaseClient.collection('otp').create(
        body: body,
      );
      
      // Get the created record with expanded relations
      final createdRecord = await _pocketBaseClient.collection('otp').getOne(
        record.id,
        expand: 'trip',
      );
      
      debugPrint('✅ Successfully created OTP with ID: ${record.id}');
      
      return OtpModel(
        id: createdRecord.id,
        generatedCode: createdRecord.data['generatedCode'],
        otpCode: createdRecord.data['otpCode'],
        isVerified: createdRecord.data['isVerified'] ?? false,
        verifiedAt: DateTime.tryParse(createdRecord.data['verifiedAt'] ?? ''),
        createdAt: DateTime.parse(createdRecord.created),
        expiresAt: DateTime.now().add(const Duration(minutes: 5)),
        otpType: createdRecord.data['otpType']?.toString().isNotEmpty == true
            ? OtpType.values.firstWhere(
                (type) => type.toString() == 'OtpType.${createdRecord.data['otpType']}',
                orElse: () => OtpType.inTransit,
              )
            : OtpType.inTransit,
        trip: TripModel(id: tripId),
        intransitOdometer: createdRecord.data['intransitOdometer'],
      );
    } catch (e) {
      debugPrint('❌ Error creating OTP: ${e.toString()}');
      throw ServerException(
        message: 'Failed to create OTP: ${e.toString()}',
        statusCode: '500',
      );
    }
  }
  
  @override
  Future<OtpModel> updateOtp({
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
      
      if (intransitOdometer != null) {
        body['intransitOdometer'] = intransitOdometer;
      }
      
      if (isVerified != null) {
        body['isVerified'] = isVerified;
      }
      
      if (verifiedAt != null) {
        body['verifiedAt'] = verifiedAt.toIso8601String();
      }
      
      await _pocketBaseClient.collection('otp').update(
        id,
        body: body,
      );
      
      // Get the updated record with expanded relations
      final updatedRecord = await _pocketBaseClient.collection('otp').getOne(
        id,
        expand: 'trip',
      );
      
      debugPrint('✅ Successfully updated OTP');
      
      return OtpModel(
        id: updatedRecord.id,
        generatedCode: updatedRecord.data['generatedCode'],
        otpCode: updatedRecord.data['otpCode'],
        isVerified: updatedRecord.data['isVerified'] ?? false,
        verifiedAt: DateTime.tryParse(updatedRecord.data['verifiedAt'] ?? ''),
        createdAt: DateTime.parse(updatedRecord.created),
        expiresAt: DateTime.now().add(const Duration(minutes: 5)),
        otpType: updatedRecord.data['otpType']?.toString().isNotEmpty == true
            ? OtpType.values.firstWhere(
                (type) => type.toString() == 'OtpType.${updatedRecord.data['otpType']}',
                orElse: () => OtpType.inTransit,
              )
            : OtpType.inTransit,
        trip: TripModel(id: updatedRecord.data['trip']),
        intransitOdometer: updatedRecord.data['intransitOdometer'],
      );
    } catch (e) {
      debugPrint('❌ Error updating OTP: ${e.toString()}');
      throw ServerException(
        message: 'Failed to update OTP: ${e.toString()}',
        statusCode: '500',
      );
    }
  }
  
  @override
  Future<bool> deleteOtp(String id) async {
    try {
      debugPrint('🔄 Deleting OTP: $id');
      
      await _pocketBaseClient.collection('otp').delete(id);
      
      debugPrint('✅ Successfully deleted OTP');
      return true;
    } catch (e) {
      debugPrint('❌ Error deleting OTP: ${e.toString()}');
      throw ServerException(
        message: 'Failed to delete OTP: ${e.toString()}',
        statusCode: '500',
      );
    }
  }
  
  @override
  Future<bool> deleteAllOtps(List<String> ids) async {
    try {
      debugPrint('🔄 Deleting multiple OTPs: ${ids.length} items');
      
      // Use Future.wait to delete all items in parallel
      await Future.wait(
        ids.map((id) => _pocketBaseClient.collection('otp').delete(id))
      );
      
      debugPrint('✅ Successfully deleted all OTPs');
      return true;
    } catch (e) {
      debugPrint('❌ Error deleting multiple OTPs: ${e.toString()}');
      throw ServerException(
        message: 'Failed to delete multiple OTPs: ${e.toString()}',
        statusCode: '500',
      );
    }
  }
}
