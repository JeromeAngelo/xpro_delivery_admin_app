import 'dart:convert';

import 'package:desktop_app/core/common/app/features/end_trip_checklist/data/model/end_trip_checklist_model.dart';
import 'package:desktop_app/core/errors/exceptions.dart';
import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';


abstract class EndTripChecklistRemoteDataSource {
  Future<List<EndTripChecklistModel>> generateEndTripChecklist(String tripId);
  Future<bool> checkEndTripChecklistItem(String id);
  Future<List<EndTripChecklistModel>> loadEndTripChecklist(String tripId);
   // New functions
  Future<List<EndTripChecklistModel>> getAllEndTripChecklists();
  Future<EndTripChecklistModel> createEndTripChecklistItem({
    required String objectName,
    required bool isChecked,
    required String tripId,
    String? status,
    DateTime? timeCompleted,
  });
  Future<EndTripChecklistModel> updateEndTripChecklistItem({
    required String id,
    String? objectName,
    bool? isChecked,
    String? tripId,
    String? status,
    DateTime? timeCompleted,
  });
  Future<bool> deleteEndTripChecklistItem(String id);
  Future<bool> deleteAllEndTripChecklistItems(List<String> ids);
}

class EndTripChecklistRemoteDataSourceImpl
    implements EndTripChecklistRemoteDataSource {
  const EndTripChecklistRemoteDataSourceImpl({
    required PocketBase pocketBaseClient,
  }) : _pocketBaseClient = pocketBaseClient;

  final PocketBase _pocketBaseClient;
@override
Future<List<EndTripChecklistModel>> generateEndTripChecklist(String tripId) async {
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

    // Check for existing checklists
    final existingChecklists = await _pocketBaseClient
        .collection('end_trip_checklist')
        .getList(filter: 'trip = "$actualTripId"');

    if (existingChecklists.items.isNotEmpty) {
      debugPrint('📝 Found existing checklists, returning those');
      return existingChecklists.items
          .map((record) => EndTripChecklistModel.fromJson(record.toJson()))
          .toList();
    }

    // Create new checklist items with trip reference
    final checklistItems = [
      {
        'trip': actualTripId,
        'objectName': 'Collections',
        'isChecked': false,
        'status': 'pending',
        'created': DateTime.now().toIso8601String(),
      },
      {
        'trip': actualTripId,
        'objectName': 'Pushcarts',
        'isChecked': false,
        'status': 'pending',
        'created': DateTime.now().toIso8601String(),
      },
      {
        'trip': actualTripId,
        'objectName': 'Remittance',
        'isChecked': false,
        'status': 'pending',
        'created': DateTime.now().toIso8601String(),
      }
    ];

    debugPrint('📝 Creating new checklist items');
    final createdItems = await Future.wait(checklistItems.map((item) async {
      final response = await _pocketBaseClient
          .collection('end_trip_checklist')
          .create(body: item);
      debugPrint('✅ Created item: ${response.id}');
      return response;
    }));

    // Update tripticket with checklist references
    final checklistIds = createdItems.map((item) => item.id).toList();
    await _pocketBaseClient.collection('tripticket').update(
      actualTripId,
      body: {
        'end_trip_checklists': checklistIds,
      },
    );
    debugPrint('✅ Updated tripticket with checklist IDs: $checklistIds');

    return createdItems
        .map((record) => EndTripChecklistModel.fromJson(record.toJson()))
        .toList();
  } catch (e) {
    debugPrint('❌ Remote: Generation failed - ${e.toString()}');
    throw ServerException(message: e.toString(), statusCode: '500');
  }
}


@override
Future<bool> checkEndTripChecklistItem(String id) async {
  try {
    debugPrint('🔄 Updating checklist item: $id');

    await _pocketBaseClient.collection('end_trip_checklist').update(
      id,
      body: {
        'isChecked': true,
        'status': 'completed',
        'timeCompleted': DateTime.now().toIso8601String(),
      },
    );

    debugPrint('✅ Checklist item updated successfully');
    return true;
  } catch (e) {
    debugPrint('❌ Failed to update checklist item: ${e.toString()}');
    throw ServerException(message: e.toString(), statusCode: '500');
  }
}

@override
Future<List<EndTripChecklistModel>> loadEndTripChecklist(String tripId) async {
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
        .collection('end_trip_checklist')
        .getFullList(
          filter: 'trip = "$actualTripId"',
          expand: 'trip',
        );

    debugPrint('✅ Retrieved ${records.length} end trip checklist items');

    final checklists = records.map((record) {
      final mappedData = {
        'id': record.id,
        'collectionId': record.collectionId,
        'collectionName': record.collectionName,
        'objectName': record.data['objectName'] ?? '',
        'isChecked': record.data['isChecked'] ?? false,
        'status': record.data['status'] ?? 'pending',
        'timeCompleted': record.data['timeCompleted'],
        'trip': actualTripId,
        'expand': {
          'trip': record.expand['trip']?.map((trip) => trip.data).first,
        }
      };
      return EndTripChecklistModel.fromJson(mappedData);
    }).toList();

    debugPrint('✨ Successfully mapped ${checklists.length} end trip checklist items');
    return checklists;
  } catch (e) {
    debugPrint('❌ End trip checklist fetch failed: ${e.toString()}');
    throw ServerException(
      message: 'Failed to load end trip checklist: ${e.toString()}',
      statusCode: '500',
    );
  }
}
 @override
  Future<List<EndTripChecklistModel>> getAllEndTripChecklists() async {
    try {
      debugPrint('🔄 Fetching all end trip checklist items');
      
      final records = await _pocketBaseClient
          .collection('end_trip_checklist')
          .getFullList(
            expand: 'trip',
          );

      debugPrint('✅ Retrieved ${records.length} end trip checklist items');

      final checklists = records.map((record) {
        final mappedData = {
          'id': record.id,
          'collectionId': record.collectionId,
          'collectionName': record.collectionName,
          'objectName': record.data['objectName'] ?? '',
          'isChecked': record.data['isChecked'] ?? false,
          'status': record.data['status'] ?? 'pending',
          'timeCompleted': record.data['timeCompleted'],
          'trip': record.data['trip'],
          'expand': record.expand.isNotEmpty ? {
            'trip': record.expand['trip']?.map((trip) => trip.data).first,
          } : null,
        };
        return EndTripChecklistModel.fromJson(mappedData);
      }).toList();

      debugPrint('✨ Successfully mapped ${checklists.length} end trip checklist items');
      return checklists;
    } catch (e) {
      debugPrint('❌ Failed to fetch all end trip checklists: ${e.toString()}');
      throw ServerException(
        message: 'Failed to fetch all end trip checklists: ${e.toString()}',
        statusCode: '500',
      );
    }
  }
  
  @override
  Future<EndTripChecklistModel> createEndTripChecklistItem({
    required String objectName,
    required bool isChecked,
    required String tripId,
    String? status,
    DateTime? timeCompleted,
  }) async {
    try {
      debugPrint('🔄 Creating new end trip checklist item: $objectName');
      
      final body = {
        'objectName': objectName,
        'isChecked': isChecked,
        'trip': tripId,
        'status': status ?? 'pending',
      };
      
      if (timeCompleted != null) {
        body['timeCompleted'] = timeCompleted.toIso8601String();
      }
      
      final record = await _pocketBaseClient
          .collection('end_trip_checklist')
          .create(body: body);
      
      // Get the created record with expanded relations
      final createdRecord = await _pocketBaseClient
          .collection('end_trip_checklist')
          .getOne(
            record.id,
            expand: 'trip',
          );
      
      debugPrint('✅ Successfully created end trip checklist item with ID: ${record.id}');
      
      final mappedData = {
        'id': createdRecord.id,
        'collectionId': createdRecord.collectionId,
        'collectionName': createdRecord.collectionName,
        'objectName': createdRecord.data['objectName'] ?? '',
        'isChecked': createdRecord.data['isChecked'] ?? false,
        'status': createdRecord.data['status'] ?? 'pending',
        'timeCompleted': createdRecord.data['timeCompleted'],
        'trip': tripId,
        'expand': createdRecord.expand.isNotEmpty ? {
          'trip': createdRecord.expand['trip']?.map((trip) => trip.data).first,
        } : null,
      };
      
      return EndTripChecklistModel.fromJson(mappedData);
    } catch (e) {
      debugPrint('❌ Failed to create end trip checklist item: ${e.toString()}');
      throw ServerException(
        message: 'Failed to create end trip checklist item: ${e.toString()}',
        statusCode: '500',
      );
    }
  }
  
  @override
  Future<EndTripChecklistModel> updateEndTripChecklistItem({
    required String id,
    String? objectName,
    bool? isChecked,
    String? tripId,
    String? status,
    DateTime? timeCompleted,
  }) async {
    try {
      debugPrint('🔄 Updating end trip checklist item: $id');
      
      final body = <String, dynamic>{};
      
      if (objectName != null) {
        body['objectName'] = objectName;
      }
      
      if (isChecked != null) {
        body['isChecked'] = isChecked;
      }
      
      if (tripId != null) {
        body['trip'] = tripId;
      }
      
      if (status != null) {
        body['status'] = status;
      }
      
      if (timeCompleted != null) {
        body['timeCompleted'] = timeCompleted.toIso8601String();
      }
      
      await _pocketBaseClient
          .collection('end_trip_checklist')
          .update(id, body: body);
      
      // Get the updated record with expanded relations
      final updatedRecord = await _pocketBaseClient
          .collection('end_trip_checklist')
          .getOne(
            id,
            expand: 'trip',
          );
      
      debugPrint('✅ Successfully updated end trip checklist item');
      
      final mappedData = {
        'id': updatedRecord.id,
        'collectionId': updatedRecord.collectionId,
        'collectionName': updatedRecord.collectionName,
        'objectName': updatedRecord.data['objectName'] ?? '',
        'isChecked': updatedRecord.data['isChecked'] ?? false,
        'status': updatedRecord.data['status'] ?? 'pending',
        'timeCompleted': updatedRecord.data['timeCompleted'],
        'trip': updatedRecord.data['trip'],
        'expand': updatedRecord.expand.isNotEmpty ? {
          'trip': updatedRecord.expand['trip']?.map((trip) => trip.data).first,
        } : null,
      };
      
      return EndTripChecklistModel.fromJson(mappedData);
    } catch (e) {
      debugPrint('❌ Failed to update end trip checklist item: ${e.toString()}');
      throw ServerException(
        message: 'Failed to update end trip checklist item: ${e.toString()}',
        statusCode: '500',
      );
    }
  }
  
  @override
  Future<bool> deleteEndTripChecklistItem(String id) async {
    try {
      debugPrint('🔄 Deleting end trip checklist item: $id');
      
      await _pocketBaseClient
          .collection('end_trip_checklist')
          .delete(id);
      
      debugPrint('✅ Successfully deleted end trip checklist item');
      return true;
    } catch (e) {
      debugPrint('❌ Failed to delete end trip checklist item: ${e.toString()}');
      throw ServerException(
        message: 'Failed to delete end trip checklist item: ${e.toString()}',
        statusCode: '500',
      );
    }
  }
  
  @override
  Future<bool> deleteAllEndTripChecklistItems(List<String> ids) async {
    try {
      debugPrint('🔄 Deleting multiple end trip checklist items: ${ids.length} items');
      
      // Use Future.wait to delete all items in parallel
      await Future.wait(
        ids.map((id) => _pocketBaseClient.collection('end_trip_checklist').delete(id))
      );
      
      debugPrint('✅ Successfully deleted all end trip checklist items');
      return true;
    } catch (e) {
      debugPrint('❌ Failed to delete multiple end trip checklist items: ${e.toString()}');
      throw ServerException(
        message: 'Failed to delete multiple end trip checklist items: ${e.toString()}',
        statusCode: '500',
      );
    }
  }

}
