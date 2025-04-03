import 'dart:convert';
import 'dart:io';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/trip_updates/data/model/trip_update_model.dart';
import 'package:desktop_app/core/enums/trip_update_status.dart';
import 'package:desktop_app/core/errors/exceptions.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:pocketbase/pocketbase.dart';

abstract class TripUpdateRemoteDatasource {
  Future<List<TripUpdateModel>> getTripUpdates(String tripId);
  Future<void> createTripUpdate({
    required String tripId,
    required String description,
    required String image,
    required String latitude,
    required String longitude,
    required TripUpdateStatus status,
  });
  // New functions
  Future<List<TripUpdateModel>> getAllTripUpdates();
  Future<TripUpdateModel> updateTripUpdate({
    required String updateId,
    String? description,
    String? image,
    String? latitude,
    String? longitude,
    TripUpdateStatus? status,
  });
  Future<bool> deleteTripUpdate(String updateId);
  Future<bool> deleteAllTripUpdates();
}

class TripUpdateRemoteDatasourceImpl implements TripUpdateRemoteDatasource {
  const TripUpdateRemoteDatasourceImpl({required PocketBase pocketBaseClient})
    : _pocketBaseClient = pocketBaseClient;

  final PocketBase _pocketBaseClient;
  @override
  Future<List<TripUpdateModel>> getTripUpdates(String tripId) async {
    try {
      // Extract trip ID if we received a JSON object
      String actualTripId;
      if (tripId.startsWith('{')) {
        final tripData = jsonDecode(tripId);
        actualTripId = tripData['id'];
      } else {
        actualTripId = tripId;
      }

      debugPrint('🎯 Using trip ID: $actualTripId');

      final records = await _pocketBaseClient
          .collection('trip_updates')
          .getFullList(filter: 'trip = "$actualTripId"', expand: 'trip');

      debugPrint('✅ Retrieved ${records.length} trip updates from API');

      final updates =
          records.map((record) {
            debugPrint('🔄 Processing trip update: ${record.id}');

            // Get the image URL if it exists
            String? imageUrl;
            if (record.data['image'] != null &&
                record.data['image'].isNotEmpty) {
              // Construct the full image URL using PocketBase's file URL format
              imageUrl =
                  '${_pocketBaseClient.baseUrl}/api/files/${record.collectionId}/${record.id}/${record.data['image']}';
              debugPrint('🖼️ Found image for update: $imageUrl');
            }

            final mappedData = {
              'id': record.id,
              'collectionId': record.collectionId,
              'collectionName': record.collectionName,
              'description': record.data['description'] ?? '',
              'status': record.data['status'] ?? '',
              'latitude': record.data['latitude'] ?? '',
              'longitude': record.data['longitude'] ?? '',
              'date': record.data['date'],
              'trip': actualTripId,
              'image': imageUrl, // Add the image URL to the mapped data
              'expand': {
                'trip': record.expand['trip']?.map((trip) => trip.data).first,
              },
            };
            return TripUpdateModel.fromJson(mappedData);
          }).toList();

      debugPrint('✨ Successfully mapped ${updates.length} trip updates');
      return updates;
    } catch (e) {
      debugPrint('❌ Trip updates fetch failed: ${e.toString()}');
      throw ServerException(
        message: 'Failed to load trip updates: ${e.toString()}',
        statusCode: '500',
      );
    }
  }

  @override
  Future<void> createTripUpdate({
    required String tripId,
    required String description,
    required String image,
    required String latitude,
    required String longitude,
    required TripUpdateStatus status,
  }) async {
    try {
      // Extract trip ID if we received a JSON object
      String actualTripId;
      if (tripId.startsWith('{')) {
        final tripData = jsonDecode(tripId);
        actualTripId = tripData['id'];
      } else {
        actualTripId = tripId;
      }

      debugPrint('🎯 Using trip ID: $actualTripId');
      debugPrint(
        '🔄 Creating trip update with status: ${status.toString().split('.').last}',
      );

      final files = <String, MultipartFile>{};

      if (image.isNotEmpty) {
        final imageBytes = await File(image).readAsBytes();
        files['image'] = MultipartFile.fromBytes(
          'image',
          imageBytes,
          filename: 'trip_update_image.jpg',
        );
      }

      final tripUpdateRecord = await _pocketBaseClient
          .collection('trip_updates')
          .create(
            body: {
              'trip': actualTripId,
              'description': description,
              'latitude': latitude,
              'longitude': longitude,
              'date': DateTime.now().toIso8601String(),
              'status': status.toString().split('.').last,
            },
            files: files.values.toList(),
          );

      debugPrint('✅ Created trip update: ${tripUpdateRecord.id}');

      await _pocketBaseClient
          .collection('tripticket')
          .update(
            actualTripId,
            body: {
              'trip_update_list+': [tripUpdateRecord.id],
            },
          );

      debugPrint('✅ Updated trip with new update record');
    } catch (e) {
      debugPrint('❌ Failed to create trip update: $e');
      throw ServerException(
        message: 'Failed to create trip update: $e',
        statusCode: '500',
      );
    }
  }

  // New function implementations
  @override
  Future<List<TripUpdateModel>> getAllTripUpdates() async {
    try {
      debugPrint('🔄 Fetching all trip updates');

      final records = await _pocketBaseClient
          .collection('trip_updates')
          .getFullList(expand: 'trip');

      debugPrint('✅ Retrieved ${records.length} trip updates from API');

      final updates =
          records.map((record) {
            debugPrint('🔄 Processing trip update: ${record.id}');

            final mappedData = {
              'id': record.id,
              'collectionId': record.collectionId,
              'collectionName': record.collectionName,
              'description': record.data['description'] ?? '',
              'status': record.data['status'] ?? '',
              'latitude': record.data['latitude'] ?? '',
              'longitude': record.data['longitude'] ?? '',
              'date': record.data['date'],
              'trip': record.data['trip'],
              'expand': {
                'trip': record.expand['trip']?.map((trip) => trip.data).first,
              },
            };
            return TripUpdateModel.fromJson(mappedData);
          }).toList();

      debugPrint('✨ Successfully mapped ${updates.length} trip updates');
      return updates;
    } catch (e) {
      debugPrint('❌ All trip updates fetch failed: ${e.toString()}');
      throw ServerException(
        message: 'Failed to load all trip updates: ${e.toString()}',
        statusCode: '500',
      );
    }
  }

  @override
  Future<TripUpdateModel> updateTripUpdate({
    required String updateId,
    String? description,
    String? image,
    String? latitude,
    String? longitude,
    TripUpdateStatus? status,
  }) async {
    try {
      debugPrint('🔄 Updating trip update: $updateId');

      final body = <String, dynamic>{};

      if (description != null) body['description'] = description;
      if (latitude != null) body['latitude'] = latitude;
      if (longitude != null) body['longitude'] = longitude;
      if (status != null) body['status'] = status.toString().split('.').last;

      final files = <String, MultipartFile>{};

      if (image != null && image.isNotEmpty) {
        final imageBytes = await File(image).readAsBytes();
        files['image'] = MultipartFile.fromBytes(
          'image',
          imageBytes,
          filename: 'trip_update_image.jpg',
        );
      }

      final updatedRecord = await _pocketBaseClient
          .collection('trip_updates')
          .update(
            updateId,
            body: body,
            //files: files.isEmpty ? null : files.values.toList(),
          );

      debugPrint('✅ Updated trip update: ${updatedRecord.id}');

      // Fetch the updated record with expanded relations
      final record = await _pocketBaseClient
          .collection('trip_updates')
          .getOne(updateId, expand: 'trip');

      final mappedData = {
        'id': record.id,
        'collectionId': record.collectionId,
        'collectionName': record.collectionName,
        'description': record.data['description'] ?? '',
        'status': record.data['status'] ?? '',
        'latitude': record.data['latitude'] ?? '',
        'longitude': record.data['longitude'] ?? '',
        'date': record.data['date'],
        'trip': record.data['trip'],
        'expand': {
          'trip': record.expand['trip']?.map((trip) => trip.data).first,
        },
      };

      return TripUpdateModel.fromJson(mappedData);
    } catch (e) {
      debugPrint('❌ Failed to update trip update: $e');
      throw ServerException(
        message: 'Failed to update trip update: $e',
        statusCode: '500',
      );
    }
  }

  @override
  Future<bool> deleteTripUpdate(String updateId) async {
    try {
      debugPrint('🔄 Deleting trip update: $updateId');

      // Get the trip update to find its associated trip
      final record = await _pocketBaseClient
          .collection('trip_updates')
          .getOne(updateId);
      final tripId = record.data['trip'];

      // Delete the trip update
      await _pocketBaseClient.collection('trip_updates').delete(updateId);

      // Update the trip to remove this update from its list
      await _pocketBaseClient
          .collection('tripticket')
          .update(
            tripId,
            body: {
              'trip_update_list-': [updateId],
            },
          );

      debugPrint('✅ Deleted trip update and updated trip record');
      return true;
    } catch (e) {
      debugPrint('❌ Failed to delete trip update: $e');
      throw ServerException(
        message: 'Failed to delete trip update: $e',
        statusCode: '500',
      );
    }
  }

  @override
  Future<bool> deleteAllTripUpdates() async {
    try {
      debugPrint('🔄 Deleting all trip updates');

      // Get all trip updates
      final records =
          await _pocketBaseClient.collection('trip_updates').getFullList();

      // Group updates by trip for efficient trip updates
      final updatesByTrip = <String, List<String>>{};

      for (final record in records) {
        final tripId = record.data['trip'];
        updatesByTrip.putIfAbsent(tripId, () => []).add(record.id);
      }

      // Delete all trip updates
      for (final record in records) {
        await _pocketBaseClient.collection('trip_updates').delete(record.id);
      }

      // Update each trip to remove its updates
      for (final entry in updatesByTrip.entries) {
        await _pocketBaseClient
            .collection('tripticket')
            .update(entry.key, body: {'trip_update_list': []});
      }

      debugPrint('✅ Deleted all trip updates and updated trip records');
      return true;
    } catch (e) {
      debugPrint('❌ Failed to delete all trip updates: $e');
      throw ServerException(
        message: 'Failed to delete all trip updates: $e',
        statusCode: '500',
      );
    }
  }
}
