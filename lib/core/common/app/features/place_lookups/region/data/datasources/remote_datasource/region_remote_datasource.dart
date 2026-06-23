import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:xpro_delivery_admin_app/core/errors/exceptions.dart';

import '../../model/region_model.dart';

abstract class RegionRemoteDataSource {
  Future<List<RegionModel>> getAllRegions();
  Future<RegionModel> getRegionById(String id);
  Future<RegionModel> createRegion({required String name, String? alias});
  Future<RegionModel> updateRegion({
    required String id,
    required String name,
    String? alias,
  });
  Future<bool> deleteRegion(String id);

  /// Returns the regions currently assigned to a vehicle profile.
  Future<List<RegionModel>> getAssignedRegionsByVehicleProfileId(
    String vehicleProfileId,
  );
}

class RegionRemoteDataSourceImpl implements RegionRemoteDataSource {
  const RegionRemoteDataSourceImpl({required PocketBase pocketBaseClient})
    : _pocketBaseClient = pocketBaseClient;

  final PocketBase _pocketBaseClient;

  @override
  Future<List<RegionModel>> getAllRegions() async {
    try {
      debugPrint('🔄 Fetching all regions');
      final records = await _pocketBaseClient
          .collection('region')
          .getFullList(sort: 'name', expand: 'provinces');
      debugPrint('✅ Fetched ${records.length} regions');
      return records.map((r) => RegionModel.fromRecord(r)).toList();
    } catch (e) {
      debugPrint('❌ Failed to fetch regions: $e');
      throw ServerException(
        message: 'Failed to fetch regions: ${e.toString()}',
        statusCode: '500',
      );
    }
  }

  @override
  Future<RegionModel> getRegionById(String id) async {
    try {
      debugPrint('🔄 Fetching region with ID: $id');
      final record = await _pocketBaseClient
          .collection('region')
          .getOne(id, expand: 'provinces');
      debugPrint('✅ Fetched region: ${record.id}');
      return RegionModel.fromRecord(record);
    } catch (e) {
      debugPrint('❌ Failed to fetch region: $e');
      throw ServerException(
        message: 'Failed to fetch region: ${e.toString()}',
        statusCode: '500',
      );
    }
  }

  @override
  Future<RegionModel> createRegion({
    required String name,
    String? alias,
  }) async {
    try {
      debugPrint('🆕 Creating region: $name (alias=$alias)');
      final body = <String, dynamic>{'name': name};
      if (alias != null && alias.isNotEmpty) body['alias'] = alias;
      final record = await _pocketBaseClient
          .collection('region')
          .create(body: body);
      debugPrint('✅ Created region: ${record.id}');
      return RegionModel.fromRecord(record);
    } catch (e) {
      debugPrint('❌ Failed to create region: $e');
      throw ServerException(
        message: 'Failed to create region: ${e.toString()}',
        statusCode: '500',
      );
    }
  }

  @override
  Future<RegionModel> updateRegion({
    required String id,
    required String name,
    String? alias,
  }) async {
    try {
      debugPrint('🔄 Updating region: $id');
      final body = <String, dynamic>{'name': name};
      if (alias != null && alias.isNotEmpty) body['alias'] = alias;
      final record = await _pocketBaseClient
          .collection('region')
          .update(id, body: body);
      debugPrint('✅ Updated region: ${record.id}');
      return RegionModel.fromRecord(record);
    } catch (e) {
      debugPrint('❌ Failed to update region: $e');
      throw ServerException(
        message: 'Failed to update region: ${e.toString()}',
        statusCode: '500',
      );
    }
  }

  @override
  Future<bool> deleteRegion(String id) async {
    try {
      debugPrint('🗑 Deleting region: $id');
      await _pocketBaseClient.collection('region').delete(id);
      debugPrint('✅ Deleted region: $id');
      return true;
    } catch (e) {
      debugPrint('❌ Failed to delete region: $e');
      throw ServerException(
        message: 'Failed to delete region: ${e.toString()}',
        statusCode: '500',
      );
    }
  }

  @override
  Future<List<RegionModel>> getAssignedRegionsByVehicleProfileId(
    String vehicleProfileId,
  ) async {
    try {
      debugPrint(
        '🔄 Fetching regions assigned to vehicle profile: $vehicleProfileId',
      );

      // 1. Fetch the vehicle profile with `assignedRegion` expanded.
      final profile = await _pocketBaseClient
          .collection('vehicleProfile')
          .getOne(vehicleProfileId);

      final assigned = profile.expand['assignedRegion'];
      if (assigned == null) {
        debugPrint('ℹ️ No assignedRegion on vehicle profile');
        return <RegionModel>[];
      }

      // 2. For each expanded region, build a RegionModel.
      //    `expand` may be a list of RecordModel (PocketBase) or a
      //    list of plain maps if the SDK ever inlines them.
      final List<dynamic> rawList = assigned;
      final regions = <RegionModel>[];
      for (final item in rawList) {
        if (item is RecordModel) {
          regions.add(RegionModel.fromRecord(item));
        } else if (item is Map) {
          regions.add(RegionModel.fromJson(item.cast<String, dynamic>()));
        }
      }

      debugPrint('✅ Found ${regions.length} regions assigned to profile');
      return regions;
    } catch (e) {
      debugPrint('❌ Failed to fetch assigned regions: $e');
      throw ServerException(
        message: 'Failed to fetch assigned regions: ${e.toString()}',
        statusCode: '500',
      );
    }
  }
}
