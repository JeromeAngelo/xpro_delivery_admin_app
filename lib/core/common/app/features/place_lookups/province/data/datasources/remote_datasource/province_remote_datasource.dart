import 'package:flutter/foundation.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:xpro_delivery_admin_app/core/errors/exceptions.dart';

import '../../model/province_model.dart';

abstract class ProvinceRemoteDataSource {
  Future<List<ProvinceModel>> getAllProvinces();
  Future<List<ProvinceModel>> getAllProvincesByRegionId(String regionId);
  Future<ProvinceModel> getProvinceById(String id);
  Future<ProvinceModel> createProvince({
    required String name,
    required String regionId,
  });
  Future<ProvinceModel> updateProvince({
    required String id,
    required String name,
    required String regionId,
  });
  Future<bool> deleteProvince(String id);
  Future<List<ProvinceModel>> getAssignedProvincesByVehicleProfileId(
    String vehicleProfileId,
  );
}

class ProvinceRemoteDataSourceImpl implements ProvinceRemoteDataSource {
  const ProvinceRemoteDataSourceImpl({required PocketBase pocketBaseClient})
    : _pocketBaseClient = pocketBaseClient;

  final PocketBase _pocketBaseClient;

  @override
  Future<List<ProvinceModel>> getAllProvinces() async {
    try {
      debugPrint('🔄 Fetching all provinces');
      final records = await _pocketBaseClient
          .collection('province')
          .getFullList(sort: 'name', expand: 'region');
      debugPrint('✅ Fetched ${records.length} provinces');
      return records.map((r) => ProvinceModel.fromRecord(r)).toList();
    } catch (e) {
      debugPrint('❌ Failed to fetch provinces: $e');
      throw ServerException(
        message: 'Failed to fetch provinces: ${e.toString()}',
        statusCode: '500',
      );
    }
  }

  @override
  Future<List<ProvinceModel>> getAllProvincesByRegionId(String regionId) async {
    try {
      debugPrint('🔄 Fetching provinces for region: $regionId');
      final records = await _pocketBaseClient
          .collection('province')
          .getFullList(
            filter: 'region="$regionId"',
            sort: 'name',
            expand: 'region',
          );
      debugPrint('✅ Fetched ${records.length} provinces for region');
      return records.map((r) => ProvinceModel.fromRecord(r)).toList();
    } catch (e) {
      debugPrint('❌ Failed to fetch provinces for region: $e');
      throw ServerException(
        message: 'Failed to fetch provinces for region: ${e.toString()}',
        statusCode: '500',
      );
    }
  }

  @override
  Future<ProvinceModel> getProvinceById(String id) async {
    try {
      debugPrint('🔄 Fetching province with ID: $id');
      final record = await _pocketBaseClient
          .collection('province')
          .getOne(id, expand: 'region');
      debugPrint('✅ Fetched province: ${record.id}');
      return ProvinceModel.fromRecord(record);
    } catch (e) {
      debugPrint('❌ Failed to fetch province: $e');
      throw ServerException(
        message: 'Failed to fetch province: ${e.toString()}',
        statusCode: '500',
      );
    }
  }

  @override
  Future<ProvinceModel> createProvince({
    required String name,
    required String regionId,
  }) async {
    try {
      debugPrint('🆕 Creating province: $name (region=$regionId)');
      final record = await _pocketBaseClient
          .collection('province')
          .create(body: {'name': name, 'region': regionId});
      debugPrint('✅ Created province: ${record.id}');
      return ProvinceModel.fromRecord(record);
    } catch (e) {
      debugPrint('❌ Failed to create province: $e');
      throw ServerException(
        message: 'Failed to create province: ${e.toString()}',
        statusCode: '500',
      );
    }
  }

  @override
  Future<ProvinceModel> updateProvince({
    required String id,
    required String name,
    required String regionId,
  }) async {
    try {
      debugPrint('🔄 Updating province: $id');
      final record = await _pocketBaseClient
          .collection('province')
          .update(id, body: {'name': name, 'region': regionId});
      debugPrint('✅ Updated province: ${record.id}');
      return ProvinceModel.fromRecord(record);
    } catch (e) {
      debugPrint('❌ Failed to update province: $e');
      throw ServerException(
        message: 'Failed to update province: ${e.toString()}',
        statusCode: '500',
      );
    }
  }

  @override
  Future<bool> deleteProvince(String id) async {
    try {
      debugPrint('🗑 Deleting province: $id');
      await _pocketBaseClient.collection('province').delete(id);
      debugPrint('✅ Deleted province: $id');
      return true;
    } catch (e) {
      debugPrint('❌ Failed to delete province: $e');
      throw ServerException(
        message: 'Failed to delete province: ${e.toString()}',
        statusCode: '500',
      );
    }
  }

  @override
  Future<List<ProvinceModel>> getAssignedProvincesByVehicleProfileId(
    String vehicleProfileId,
  ) async {
    try {
      debugPrint(
        '🔄 Fetching provinces assigned to vehicle profile: '
        '$vehicleProfileId',
      );

      final profile = await _pocketBaseClient
          .collection('vehicleProfile')
          .getOne(vehicleProfileId);

      final assigned = profile.expand['assignedProvince'];
      if (assigned == null) {
        debugPrint('ℹ️ No assignedProvince on vehicle profile');
        return <ProvinceModel>[];
      }

      final List<dynamic> rawList = assigned;
      final provinces = <ProvinceModel>[];
      for (final item in rawList) {
        if (item is RecordModel) {
          provinces.add(ProvinceModel.fromRecord(item));
        } else if (item is Map) {
          provinces.add(ProvinceModel.fromJson(item.cast<String, dynamic>()));
        }
      }

      debugPrint('✅ Found ${provinces.length} provinces assigned to profile');
      return provinces;
    } catch (e) {
      debugPrint('❌ Failed to fetch assigned provinces: $e');
      throw ServerException(
        message: 'Failed to fetch assigned provinces: ${e.toString()}',
        statusCode: '500',
      );
    }
  }
}
