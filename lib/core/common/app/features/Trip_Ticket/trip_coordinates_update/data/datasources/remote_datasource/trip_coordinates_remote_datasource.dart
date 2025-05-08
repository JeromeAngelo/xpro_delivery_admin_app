import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/trip/data/models/trip_models.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/trip_coordinates_update/data/model/trip_coordinates_model.dart';
import 'package:xpro_delivery_admin_app/core/errors/exceptions.dart';

abstract class TripCoordinatesRemoteDataSource {
  /// Retrieves all trip coordinate updates for a specific trip
  ///
  /// [tripId] The ID of the trip to get coordinates for
  /// Returns a list of [TripCoordinatesModel] objects
  Future<List<TripCoordinatesModel>> getTripCoordinatesByTripId(String tripId);
}

class TripCoordinatesRemoteDataSourceImpl
    implements TripCoordinatesRemoteDataSource {
  const TripCoordinatesRemoteDataSourceImpl({
    required PocketBase pocketBaseClient,
  }) : _pocketBaseClient = pocketBaseClient;

  final PocketBase _pocketBaseClient;

  @override
  Future<List<TripCoordinatesModel>> getTripCoordinatesByTripId(
    String tripId,
  ) async {
    try {
      // Extract trip ID if we received a JSON object
      String actualTripId;
      if (tripId.startsWith('{')) {
        final tripData = jsonDecode(tripId);
        actualTripId = tripData['id'];
      } else {
        actualTripId = tripId;
      }

      debugPrint('🔄 Getting trip coordinates for trip ID: $actualTripId');

      // Get coordinates using trip ID
      final List<RecordModel> records = await _pocketBaseClient
          .collection('trip_coordinates_updates')
          .getFullList(
            filter: 'trip = "$actualTripId"',
            expand: 'trip',
            sort: '-created', // Sort by creation time to get chronological order
          );

      debugPrint(
        '✅ Retrieved ${records.length} coordinate updates for trip: $actualTripId',
      );

      List<TripCoordinatesModel> coordinates = [];

      for (RecordModel record in records) {
        // Process trip data
        TripModel? tripModel;

        // Safely access expand data
        final expandData = record.expand;
        if (expandData.containsKey('trip')) {
          final tripData = expandData['trip'];

          // Handle single record or list of records
          if (tripData is List && tripData!.isNotEmpty) {
            // List of records (take the first one)
            final firstRecord = tripData.first;
            tripModel = TripModel.fromJson({
              'id': firstRecord.id,
              'collectionId': firstRecord.collectionId,
              'collectionName': firstRecord.collectionName,
              ...firstRecord.data,
            });
          }
        }

        // Parse latitude and longitude
        double? latitude;
        if (record.data.containsKey('latitude') &&
            record.data['latitude'] != null) {
          try {
            latitude = double.parse(record.data['latitude'].toString());
          } catch (e) {
            debugPrint('❌ Error parsing latitude: $e');
          }
        }

        double? longitude;
        if (record.data.containsKey('longitude') &&
            record.data['longitude'] != null) {
          try {
            longitude = double.parse(record.data['longitude'].toString());
          } catch (e) {
            debugPrint('❌ Error parsing longitude: $e');
          }
        }

        // Parse dates
        DateTime? created;

        DateTime? updated;

        // Create model from record
        coordinates.add(
          TripCoordinatesModel(
            id: record.id,
            collectionId: record.collectionId,
            collectionName: record.collectionName,
            trip: tripModel,
            tripId: actualTripId,
            latitude: latitude,
            longitude: longitude,
            created: created,
            updated: updated,
          ),
        );
      }

      return coordinates;
    } catch (e) {
      debugPrint('❌ Error getting trip coordinates: ${e.toString()}');
      throw ServerException(
        message: 'Failed to load trip coordinates: ${e.toString()}',
        statusCode: '500',
      );
    }
  }
}
