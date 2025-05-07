import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';

import 'package:xpro_delivery_admin_app/core/common/app/features/users_trip_collection/data/models/users_trip_collection_model.dart';
import 'package:xpro_delivery_admin_app/core/errors/exceptions.dart';

abstract class UsersTripCollectionRemoteDataSource {
  // Get all trip collections for a specific user
  Future<List<UserTripCollectionModel>> getUserTripCollections(String userId);
}

class UsersTripCollectionRemoteDataSourceImpl
    implements UsersTripCollectionRemoteDataSource {
  final PocketBase _pocketBaseClient;

  const UsersTripCollectionRemoteDataSourceImpl({
    required PocketBase pocketBaseClient,
  }) : _pocketBaseClient = pocketBaseClient;

  @override
  Future<List<UserTripCollectionModel>> getUserTripCollections(
    String userId,
  ) async {
    try {
      debugPrint('🔄 Fetching trip collections for user: $userId');

      // Extract user ID if we received a JSON object
      String actualUserId;
      if (userId.startsWith('{')) {
        final userData = jsonDecode(userId);
        actualUserId = userData['id'];
      } else {
        actualUserId = userId;
      }

      // Get trip collections using user ID
      final result = await _pocketBaseClient
          .collection('users_trip_history')
          .getFullList(
            filter: 'user = "$actualUserId"',
            expand: 'user,trips',
            sort: '-created',
          );

      debugPrint(
        '✅ Retrieved ${result.length} trip collections for user: $actualUserId',
      );

      List<UserTripCollectionModel> collections = [];

      for (var record in result) {
        try {
          // Create a detailed map with all fields
          final mappedData = {
            'id': record.id,
            'collectionId': record.collectionId,
            'collectionName': record.collectionName,
            'isActive': record.data['isActive'] ?? false,
            'created': record.created,
            'updated': record.updated,
            'expand': {
              'user': record.expand['user'],
              'trips': record.expand['trips'] ?? [],
            },
          };

          collections.add(UserTripCollectionModel.fromJson(mappedData));
        } catch (e) {
          debugPrint('⚠️ Error processing trip collection record: $e');
        }
      }

      return collections;
    } catch (e) {
      debugPrint('❌ Failed to fetch user trip collections: ${e.toString()}');
      throw ServerException(
        message: 'Failed to load trip collections: ${e.toString()}',
        statusCode: '500',
      );
    }
  }
}
