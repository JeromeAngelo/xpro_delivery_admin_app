import 'package:flutter/foundation.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:xpro_delivery_admin_app/core/errors/exceptions.dart';

import '../../model/municipality_model.dart';

abstract class MunicipalityRemoteDataSource {
  Future<List<MunicipalityModel>> getAllMunicipalities();
  Future<List<MunicipalityModel>> getAllMunicipalitiesByProvinceId(
    String provinceId,
  );
  Future<MunicipalityModel> getMunicipalityById(String id);
  Future<MunicipalityModel> createMunicipality({
    required String name,
    required String provinceId,
  });
  Future<MunicipalityModel> updateMunicipality({
    required String id,
    required String name,
    required String provinceId,
  });
  Future<bool> deleteMunicipality(String id);
  Future<List<MunicipalityModel>> getAssignedMunicipalitiesByVehicleProfileId(
    String vehicleProfileId,
  );
}

class MunicipalityRemoteDataSourceImpl implements MunicipalityRemoteDataSource {
  const MunicipalityRemoteDataSourceImpl({required PocketBase pocketBaseClient})
    : _pocketBaseClient = pocketBaseClient;

  final PocketBase _pocketBaseClient;

  @override
  Future<List<MunicipalityModel>> getAllMunicipalities() async {
    try {
      debugPrint('🔄 Fetching all municipalities');
      final records = await _pocketBaseClient
          .collection('municipality')
          .getFullList(sort: 'name');
      debugPrint('✅ Fetched ${records.length} municipalities');
      return records.map((r) => MunicipalityModel.fromRecord(r)).toList();
    } catch (e) {
      debugPrint('❌ Failed to fetch municipalities: $e');
      throw ServerException(
        message: 'Failed to fetch municipalities: ${e.toString()}',
        statusCode: '500',
      );
    }
  }

  @override
  Future<List<MunicipalityModel>> getAllMunicipalitiesByProvinceId(
    String provinceId,
  ) async {
    try {
      debugPrint('🔄 Fetching municipalities for province: $provinceId');
      final records = await _pocketBaseClient
          .collection('municipality')
          .getFullList(filter: 'province="$provinceId"', sort: 'name');
      debugPrint('✅ Fetched ${records.length} municipalities for province');
      return records.map((r) => MunicipalityModel.fromRecord(r)).toList();
    } catch (e) {
      debugPrint('❌ Failed to fetch municipalities for province: $e');
      throw ServerException(
        message: 'Failed to fetch municipalities for province: ${e.toString()}',
        statusCode: '500',
      );
    }
  }

  @override
  Future<MunicipalityModel> getMunicipalityById(String id) async {
    try {
      debugPrint('🔄 Fetching municipality with ID: $id');
      final record = await _pocketBaseClient
          .collection('municipality')
          .getOne(id);
      debugPrint('✅ Fetched municipality: ${record.id}');
      return MunicipalityModel.fromRecord(record);
    } catch (e) {
      debugPrint('❌ Failed to fetch municipality: $e');
      throw ServerException(
        message: 'Failed to fetch municipality: ${e.toString()}',
        statusCode: '500',
      );
    }
  }

  @override
  Future<MunicipalityModel> createMunicipality({
    required String name,
    required String provinceId,
  }) async {
    try {
      debugPrint('🆕 Creating municipality: $name (province=$provinceId)');
      final record = await _pocketBaseClient
          .collection('municipality')
          .create(body: {'name': name, 'province': provinceId});
      debugPrint('✅ Created municipality: ${record.id}');
      return MunicipalityModel.fromRecord(record);
    } catch (e) {
      debugPrint('❌ Failed to create municipality: $e');
      throw ServerException(
        message: 'Failed to create municipality: ${e.toString()}',
        statusCode: '500',
      );
    }
  }

  @override
  Future<MunicipalityModel> updateMunicipality({
    required String id,
    required String name,
    required String provinceId,
  }) async {
    try {
      debugPrint('🔄 Updating municipality: $id');
      final record = await _pocketBaseClient
          .collection('municipality')
          .update(id, body: {'name': name, 'province': provinceId});
      debugPrint('✅ Updated municipality: ${record.id}');
      return MunicipalityModel.fromRecord(record);
    } catch (e) {
      debugPrint('❌ Failed to update municipality: $e');
      throw ServerException(
        message: 'Failed to update municipality: ${e.toString()}',
        statusCode: '500',
      );
    }
  }

  @override
  Future<bool> deleteMunicipality(String id) async {
    try {
      debugPrint('🗑 Deleting municipality: $id');
      await _pocketBaseClient.collection('municipality').delete(id);
      debugPrint('✅ Deleted municipality: $id');
      return true;
    } catch (e) {
      debugPrint('❌ Failed to delete municipality: $e');
      throw ServerException(
        message: 'Failed to delete municipality: ${e.toString()}',
        statusCode: '500',
      );
    }
  }

  @override
  Future<List<MunicipalityModel>> getAssignedMunicipalitiesByVehicleProfileId(
    String vehicleProfileId,
  ) async {
    try {
      debugPrint(
        '🔄 Fetching municipalities assigned to vehicle profile: '
        '$vehicleProfileId',
      );

      final profile = await _pocketBaseClient
          .collection('vehicleProfile')
          .getOne(vehicleProfileId);

      final assigned = profile.expand['assignedMunicipality'];
      if (assigned == null) {
        debugPrint('ℹ️ No assignedMunicipality on vehicle profile');
        return <MunicipalityModel>[];
      }

      // `expand` returns `Map<String, List<dynamic>>` in PocketBase,
      // so `assigned` is always a list of records here.
      final List<dynamic> rawList = assigned as List;
      final municipalities = <MunicipalityModel>[];
      for (final item in rawList) {
        if (item is RecordModel) {
          municipalities.add(MunicipalityModel.fromRecord(item));
        } else if (item is Map) {
          municipalities.add(
            MunicipalityModel.fromJson(item.cast<String, dynamic>()),
          );
        }
      }

      debugPrint(
        '✅ Found ${municipalities.length} municipalities assigned to profile',
      );
      return municipalities;
    } catch (e) {
      debugPrint('❌ Failed to fetch assigned municipalities: $e');
      throw ServerException(
        message: 'Failed to fetch assigned municipalities: ${e.toString()}',
        statusCode: '500',
      );
    }
  }
}
