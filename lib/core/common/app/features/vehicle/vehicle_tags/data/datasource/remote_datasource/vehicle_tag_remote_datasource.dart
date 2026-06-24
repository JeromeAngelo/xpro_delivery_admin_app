import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import '../../../../../../../../errors/exceptions.dart';
import '../../model/vehicle_tag_model.dart';

abstract class VehicleTagRemoteDataSource {
  Future<List<VehicleTagModel>> getVehicleTags();
  Future<VehicleTagModel> loadVehicleTagById(String tagId);
  Future<VehicleTagModel> createVehicleTag({
    required String label,
    required List<String> tagType,
    String? description,
  });
  Future<VehicleTagModel> updateVehicleTag({
    required String tagId,
    String? label,
    List<String>? tagType,
    String? description,
  });
  Future<bool> deleteVehicleTag(String tagId);

  Future<bool> assignTagToVehicle({
    required String vehicleId,
    required String tagId,
  });
  Future<bool> unassignTagFromVehicle({
    required String vehicleId,
    required String tagId,
  });
}

class VehicleTagRemoteDataSourceImpl implements VehicleTagRemoteDataSource {
  const VehicleTagRemoteDataSourceImpl({required PocketBase pocketBaseClient})
    : _pocketBaseClient = pocketBaseClient;

  final PocketBase _pocketBaseClient;

  @override
  Future<List<VehicleTagModel>> getVehicleTags() async {
    try {
      debugPrint('🔄 Fetching all vehicle tags from remote');
      final records = await _pocketBaseClient
          .collection('vehicleTags')
          .getFullList(sort: '-created');
      debugPrint('✅ Fetched ${records.length} vehicle tags from remote');
      return records
          .map((record) => VehicleTagModel.fromRecord(record))
          .toList();
    } catch (e) {
      debugPrint('❌ Failed to fetch vehicle tags: ${e.toString()}');
      throw ServerException(
        message: 'Failed to fetch vehicle tags: ${e.toString()}',
        statusCode: '500',
      );
    }
  }

  @override
  Future<VehicleTagModel> loadVehicleTagById(String tagId) async {
    try {
      debugPrint('🔄 Fetching vehicle tag by ID: $tagId');
      final record = await _pocketBaseClient
          .collection('vehicleTags')
          .getOne(tagId);
      debugPrint('✅ Fetched vehicle tag: ${record.id}');
      return VehicleTagModel.fromRecord(record);
    } catch (e) {
      debugPrint('❌ Failed to fetch vehicle tag: ${e.toString()}');
      throw ServerException(
        message: 'Failed to fetch vehicle tag: ${e.toString()}',
        statusCode: '500',
      );
    }
  }

  @override
  Future<VehicleTagModel> createVehicleTag({
    required String label,
    required List<String> tagType,
    String? description,
  }) async {
    try {
      debugPrint('🔄 Creating vehicle tag: $label');
      final body = {
        'label': label,
        'types': tagType,
        if (description != null) 'description': description,
      };
      final record = await _pocketBaseClient
          .collection('vehicleTags')
          .create(body: body);
      debugPrint('✅ Created vehicle tag: ${record.id}');
      return VehicleTagModel.fromRecord(record);
    } catch (e) {
      debugPrint('❌ Failed to create vehicle tag: ${e.toString()}');
      throw ServerException(
        message: 'Failed to create vehicle tag: ${e.toString()}',
        statusCode: '500',
      );
    }
  }

  @override
  Future<VehicleTagModel> updateVehicleTag({
    required String tagId,
    String? label,
    List<String>? tagType,
    String? description,
  }) async {
    try {
      debugPrint('🔄 Updating vehicle tag: $tagId');
      final body = <String, dynamic>{};
      if (label != null) body['label'] = label;
      if (tagType != null) body['types'] = tagType;
      if (description != null) body['description'] = description;

      final record = await _pocketBaseClient
          .collection('vehicleTags')
          .update(tagId, body: body);
      debugPrint('✅ Updated vehicle tag: ${record.id}');
      return VehicleTagModel.fromRecord(record);
    } catch (e) {
      debugPrint('❌ Failed to update vehicle tag: ${e.toString()}');
      throw ServerException(
        message: 'Failed to update vehicle tag: ${e.toString()}',
        statusCode: '500',
      );
    }
  }

  @override
  Future<bool> deleteVehicleTag(String tagId) async {
    try {
      debugPrint('🔄 Deleting vehicle tag: $tagId');
      await _pocketBaseClient.collection('vehicleTags').delete(tagId);
      debugPrint('✅ Deleted vehicle tag: $tagId');
      return true;
    } catch (e) {
      debugPrint('❌ Failed to delete vehicle tag: ${e.toString()}');
      throw ServerException(
        message: 'Failed to delete vehicle tag: ${e.toString()}',
        statusCode: '500',
      );
    }
  }

  @override
  Future<bool> assignTagToVehicle({
    required String vehicleId,
    required String tagId,
  }) async {
    try {
      debugPrint('🔄 Assigning tag $tagId to vehicle $vehicleId');
      final vehicleRecord = await _pocketBaseClient
          .collection('vehicle')
          .getOne(vehicleId, expand: 'vehicleTags');

      final currentTags =
          (vehicleRecord.data['vehicleTags'] as List<dynamic>? ?? [])
              .map((e) => e.toString())
              .toList();

      if (!currentTags.contains(tagId)) {
        currentTags.add(tagId);
        await _pocketBaseClient
            .collection('vehicle')
            .update(vehicleId, body: {'vehicleTags': currentTags});
      }

      debugPrint('✅ Assigned tag $tagId to vehicle $vehicleId');
      return true;
    } catch (e) {
      debugPrint('❌ Failed to assign tag to vehicle: ${e.toString()}');
      throw ServerException(
        message: 'Failed to assign tag to vehicle: ${e.toString()}',
        statusCode: '500',
      );
    }
  }

  @override
  Future<bool> unassignTagFromVehicle({
    required String vehicleId,
    required String tagId,
  }) async {
    try {
      debugPrint('🔄 Unassigning tag $tagId from vehicle $vehicleId');
      final vehicleRecord = await _pocketBaseClient
          .collection('vehicle')
          .getOne(vehicleId, expand: 'vehicleTags');

      final currentTags =
          (vehicleRecord.data['vehicleTags'] as List<dynamic>? ?? [])
              .map((e) => e.toString())
              .toList();

      if (currentTags.contains(tagId)) {
        currentTags.remove(tagId);
        await _pocketBaseClient
            .collection('vehicle')
            .update(vehicleId, body: {'vehicleTags': currentTags});
      }

      debugPrint('✅ Unassigned tag $tagId from vehicle $vehicleId');
      return true;
    } catch (e) {
      debugPrint('❌ Failed to unassign tag from vehicle: ${e.toString()}');
      throw ServerException(
        message: 'Failed to unassign tag from vehicle: ${e.toString()}',
        statusCode: '500',
      );
    }
  }
}
