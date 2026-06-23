import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:xpro_delivery_admin_app/core/errors/exceptions.dart';
import 'package:xpro_delivery_admin_app/core/errors/failures.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';

import '../../domain/entity/region_entity.dart';
import '../../domain/repo/region_repo.dart';
import '../datasources/remote_datasource/region_remote_datasource.dart';

class RegionRepoImpl implements RegionRepo {
  const RegionRepoImpl({required RegionRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  final RegionRemoteDataSource _remoteDataSource;

  @override
  ResultFuture<List<RegionEntity>> getAllRegions() async {
    try {
      debugPrint('🔄 REPO: Fetching all regions');
      final regions = await _remoteDataSource.getAllRegions();
      return Right(regions);
    } on ServerException catch (e) {
      debugPrint('❌ REPO: Failed to fetch regions: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      debugPrint('❌ REPO: Unexpected error: $e');
      return Left(ServerFailure(message: e.toString(), statusCode: '500'));
    }
  }

  @override
  ResultFuture<RegionEntity> getRegionById(String id) async {
    try {
      debugPrint('🔄 REPO: Fetching region by id: $id');
      final region = await _remoteDataSource.getRegionById(id);
      return Right(region);
    } on ServerException catch (e) {
      debugPrint('❌ REPO: Failed to fetch region: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      debugPrint('❌ REPO: Unexpected error: $e');
      return Left(ServerFailure(message: e.toString(), statusCode: '500'));
    }
  }

  @override
  ResultFuture<RegionEntity> createRegion({
    required String name,
    String? alias,
  }) async {
    try {
      debugPrint('🔄 REPO: Creating region: $name');
      final region = await _remoteDataSource.createRegion(
        name: name,
        alias: alias,
      );
      return Right(region);
    } on ServerException catch (e) {
      debugPrint('❌ REPO: Failed to create region: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      debugPrint('❌ REPO: Unexpected error: $e');
      return Left(ServerFailure(message: e.toString(), statusCode: '500'));
    }
  }

  @override
  ResultFuture<RegionEntity> updateRegion({
    required String id,
    required String name,
    String? alias,
  }) async {
    try {
      debugPrint('🔄 REPO: Updating region: $id');
      final region = await _remoteDataSource.updateRegion(
        id: id,
        name: name,
        alias: alias,
      );
      return Right(region);
    } on ServerException catch (e) {
      debugPrint('❌ REPO: Failed to update region: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      debugPrint('❌ REPO: Unexpected error: $e');
      return Left(ServerFailure(message: e.toString(), statusCode: '500'));
    }
  }

  @override
  ResultFuture<bool> deleteRegion(String id) async {
    try {
      debugPrint('🔄 REPO: Deleting region: $id');
      final result = await _remoteDataSource.deleteRegion(id);
      return Right(result);
    } on ServerException catch (e) {
      debugPrint('❌ REPO: Failed to delete region: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      debugPrint('❌ REPO: Unexpected error: $e');
      return Left(ServerFailure(message: e.toString(), statusCode: '500'));
    }
  }

  @override
  ResultFuture<List<RegionEntity>> getAssignedRegionsByVehicleProfileId(
    String vehicleProfileId,
  ) async {
    try {
      debugPrint(
        '🔄 REPO: Fetching assigned regions for vehicle profile: '
        '$vehicleProfileId',
      );
      final regions = await _remoteDataSource
          .getAssignedRegionsByVehicleProfileId(vehicleProfileId);
      return Right(regions);
    } on ServerException catch (e) {
      debugPrint('❌ REPO: Failed to fetch assigned regions: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      debugPrint('❌ REPO: Unexpected error: $e');
      return Left(ServerFailure(message: e.toString(), statusCode: '500'));
    }
  }
}
