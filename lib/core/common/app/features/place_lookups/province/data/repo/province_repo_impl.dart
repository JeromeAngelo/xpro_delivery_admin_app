import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:xpro_delivery_admin_app/core/errors/exceptions.dart';
import 'package:xpro_delivery_admin_app/core/errors/failures.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';

import '../../domain/entity/province_entity.dart';
import '../../domain/repo/province_repo.dart';
import '../datasources/remote_datasource/province_remote_datasource.dart';

class ProvinceRepoImpl implements ProvinceRepo {
  const ProvinceRepoImpl({required ProvinceRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  final ProvinceRemoteDataSource _remoteDataSource;

  @override
  ResultFuture<List<ProvinceEntity>> getAllProvinces() async {
    try {
      debugPrint('🔄 REPO: Fetching all provinces');
      final provinces = await _remoteDataSource.getAllProvinces();
      return Right(provinces);
    } on ServerException catch (e) {
      debugPrint('❌ REPO: Failed to fetch provinces: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      debugPrint('❌ REPO: Unexpected error: $e');
      return Left(ServerFailure(message: e.toString(), statusCode: '500'));
    }
  }

  @override
  ResultFuture<List<ProvinceEntity>> getAllProvincesByRegionId(
    String regionId,
  ) async {
    try {
      debugPrint('🔄 REPO: Fetching provinces by region: $regionId');
      final provinces = await _remoteDataSource.getAllProvincesByRegionId(
        regionId,
      );
      return Right(provinces);
    } on ServerException catch (e) {
      debugPrint('❌ REPO: Failed to fetch provinces: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      debugPrint('❌ REPO: Unexpected error: $e');
      return Left(ServerFailure(message: e.toString(), statusCode: '500'));
    }
  }

  @override
  ResultFuture<ProvinceEntity> getProvinceById(String id) async {
    try {
      debugPrint('🔄 REPO: Fetching province by id: $id');
      final province = await _remoteDataSource.getProvinceById(id);
      return Right(province);
    } on ServerException catch (e) {
      debugPrint('❌ REPO: Failed to fetch province: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      debugPrint('❌ REPO: Unexpected error: $e');
      return Left(ServerFailure(message: e.toString(), statusCode: '500'));
    }
  }

  @override
  ResultFuture<ProvinceEntity> createProvince({
    required String name,
    required String regionId,
  }) async {
    try {
      debugPrint('🔄 REPO: Creating province: $name');
      final province = await _remoteDataSource.createProvince(
        name: name,
        regionId: regionId,
      );
      return Right(province);
    } on ServerException catch (e) {
      debugPrint('❌ REPO: Failed to create province: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      debugPrint('❌ REPO: Unexpected error: $e');
      return Left(ServerFailure(message: e.toString(), statusCode: '500'));
    }
  }

  @override
  ResultFuture<ProvinceEntity> updateProvince({
    required String id,
    required String name,
    required String regionId,
  }) async {
    try {
      debugPrint('🔄 REPO: Updating province: $id');
      final province = await _remoteDataSource.updateProvince(
        id: id,
        name: name,
        regionId: regionId,
      );
      return Right(province);
    } on ServerException catch (e) {
      debugPrint('❌ REPO: Failed to update province: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      debugPrint('❌ REPO: Unexpected error: $e');
      return Left(ServerFailure(message: e.toString(), statusCode: '500'));
    }
  }

  @override
  ResultFuture<bool> deleteProvince(String id) async {
    try {
      debugPrint('🔄 REPO: Deleting province: $id');
      final result = await _remoteDataSource.deleteProvince(id);
      return Right(result);
    } on ServerException catch (e) {
      debugPrint('❌ REPO: Failed to delete province: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      debugPrint('❌ REPO: Unexpected error: $e');
      return Left(ServerFailure(message: e.toString(), statusCode: '500'));
    }
  }

  @override
  ResultFuture<List<ProvinceEntity>> getAssignedProvincesByVehicleProfileId(
    String vehicleProfileId,
  ) async {
    try {
      debugPrint(
        '🔄 REPO: Fetching assigned provinces for vehicle profile: '
        '$vehicleProfileId',
      );
      final provinces = await _remoteDataSource
          .getAssignedProvincesByVehicleProfileId(vehicleProfileId);
      return Right(provinces);
    } on ServerException catch (e) {
      debugPrint('❌ REPO: Failed to fetch assigned provinces: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      debugPrint('❌ REPO: Unexpected error: $e');
      return Left(ServerFailure(message: e.toString(), statusCode: '500'));
    }
  }
}
