import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:xpro_delivery_admin_app/core/errors/exceptions.dart';
import 'package:xpro_delivery_admin_app/core/errors/failures.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';

import '../../domain/entity/municipality_entity.dart';
import '../../domain/repo/municipality_repo.dart';
import '../datasources/remote_datasource/municipality_remote_datasource.dart';

class MunicipalityRepoImpl implements MunicipalityRepo {
  const MunicipalityRepoImpl({
    required MunicipalityRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final MunicipalityRemoteDataSource _remoteDataSource;

  @override
  ResultFuture<List<MunicipalityEntity>> getAllMunicipalities() async {
    try {
      debugPrint('🔄 REPO: Fetching all municipalities');
      final municipalities = await _remoteDataSource.getAllMunicipalities();
      return Right(municipalities);
    } on ServerException catch (e) {
      debugPrint('❌ REPO: Failed to fetch municipalities: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      debugPrint('❌ REPO: Unexpected error: $e');
      return Left(ServerFailure(message: e.toString(), statusCode: '500'));
    }
  }

  @override
  ResultFuture<List<MunicipalityEntity>> getAllMunicipalitiesByProvinceId(
    String provinceId,
  ) async {
    try {
      debugPrint('🔄 REPO: Fetching municipalities by province: $provinceId');
      final municipalities = await _remoteDataSource
          .getAllMunicipalitiesByProvinceId(provinceId);
      return Right(municipalities);
    } on ServerException catch (e) {
      debugPrint('❌ REPO: Failed to fetch municipalities: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      debugPrint('❌ REPO: Unexpected error: $e');
      return Left(ServerFailure(message: e.toString(), statusCode: '500'));
    }
  }

  @override
  ResultFuture<MunicipalityEntity> getMunicipalityById(String id) async {
    try {
      debugPrint('🔄 REPO: Fetching municipality by id: $id');
      final municipality = await _remoteDataSource.getMunicipalityById(id);
      return Right(municipality);
    } on ServerException catch (e) {
      debugPrint('❌ REPO: Failed to fetch municipality: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      debugPrint('❌ REPO: Unexpected error: $e');
      return Left(ServerFailure(message: e.toString(), statusCode: '500'));
    }
  }

  @override
  ResultFuture<MunicipalityEntity> createMunicipality({
    required String name,
    required String provinceId,
  }) async {
    try {
      debugPrint('🔄 REPO: Creating municipality: $name');
      final municipality = await _remoteDataSource.createMunicipality(
        name: name,
        provinceId: provinceId,
      );
      return Right(municipality);
    } on ServerException catch (e) {
      debugPrint('❌ REPO: Failed to create municipality: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      debugPrint('❌ REPO: Unexpected error: $e');
      return Left(ServerFailure(message: e.toString(), statusCode: '500'));
    }
  }

  @override
  ResultFuture<MunicipalityEntity> updateMunicipality({
    required String id,
    required String name,
    required String provinceId,
  }) async {
    try {
      debugPrint('🔄 REPO: Updating municipality: $id');
      final municipality = await _remoteDataSource.updateMunicipality(
        id: id,
        name: name,
        provinceId: provinceId,
      );
      return Right(municipality);
    } on ServerException catch (e) {
      debugPrint('❌ REPO: Failed to update municipality: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      debugPrint('❌ REPO: Unexpected error: $e');
      return Left(ServerFailure(message: e.toString(), statusCode: '500'));
    }
  }

  @override
  ResultFuture<bool> deleteMunicipality(String id) async {
    try {
      debugPrint('🔄 REPO: Deleting municipality: $id');
      final result = await _remoteDataSource.deleteMunicipality(id);
      return Right(result);
    } on ServerException catch (e) {
      debugPrint('❌ REPO: Failed to delete municipality: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      debugPrint('❌ REPO: Unexpected error: $e');
      return Left(ServerFailure(message: e.toString(), statusCode: '500'));
    }
  }

  @override
  ResultFuture<List<MunicipalityEntity>>
  getAssignedMunicipalitiesByVehicleProfileId(String vehicleProfileId) async {
    try {
      debugPrint(
        '🔄 REPO: Fetching assigned municipalities for vehicle profile: '
        '$vehicleProfileId',
      );
      final municipalities = await _remoteDataSource
          .getAssignedMunicipalitiesByVehicleProfileId(vehicleProfileId);
      return Right(municipalities);
    } on ServerException catch (e) {
      debugPrint(
        '❌ REPO: Failed to fetch assigned municipalities: ${e.message}',
      );
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      debugPrint('❌ REPO: Unexpected error: $e');
      return Left(ServerFailure(message: e.toString(), statusCode: '500'));
    }
  }
}
