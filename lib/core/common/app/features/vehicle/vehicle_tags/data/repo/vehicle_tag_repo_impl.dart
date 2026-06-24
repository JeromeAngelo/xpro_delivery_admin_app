import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

import '../../../../../../../enums/vehicle_tags_enums.dart';
import '../../../../../../../errors/exceptions.dart';
import '../../../../../../../errors/failures.dart';
import '../../../../../../../typedefs/typedefs.dart';
import '../../domain/entity/vehicle_tag_entity.dart';
import '../../domain/repo/vehicle_tag_repo.dart';
import '../datasource/remote_datasource/vehicle_tag_remote_datasource.dart';

class VehicleTagRepoImpl implements VehicleTagRepo {
  const VehicleTagRepoImpl({
    required VehicleTagRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final VehicleTagRemoteDataSource _remoteDataSource;

  @override
  ResultFuture<List<VehicleTagEntity>> getVehicleTags() async {
    try {
      debugPrint('🔄 REPO: Fetching all vehicle tags from remote');
      final remoteTags = await _remoteDataSource.getVehicleTags();
      debugPrint(
        '✅ REPO: Successfully fetched ${remoteTags.length} vehicle tags',
      );
      return Right(remoteTags);
    } on ServerException catch (e) {
      debugPrint('❌ REPO: Remote fetch failed: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      debugPrint('❌ REPO: Unexpected error: ${e.toString()}');
      return Left(ServerFailure(message: e.toString(), statusCode: '500'));
    }
  }

  @override
  ResultFuture<VehicleTagEntity> loadVehicleTagById(String tagId) async {
    try {
      debugPrint('🔄 REPO: Fetching vehicle tag by ID: $tagId');
      final remoteTag = await _remoteDataSource.loadVehicleTagById(tagId);
      debugPrint('✅ REPO: Successfully fetched vehicle tag');
      return Right(remoteTag);
    } on ServerException catch (e) {
      debugPrint('❌ REPO: Remote fetch failed: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      debugPrint('❌ REPO: Unexpected error: ${e.toString()}');
      return Left(ServerFailure(message: e.toString(), statusCode: '500'));
    }
  }

  @override
  ResultFuture<VehicleTagEntity> createVehicleTag({
    required String label,
    required List<VehicleTagType> tagType,
    String? description,
  }) async {
    try {
      debugPrint('🔄 REPO: Creating vehicle tag: $label');
      final createdTag = await _remoteDataSource.createVehicleTag(
        label: label,
        tagType: tagType.map((e) => e.name).toList(),
        description: description,
      );
      debugPrint('✅ REPO: Successfully created vehicle tag: ${createdTag.id}');
      return Right(createdTag);
    } on ServerException catch (e) {
      debugPrint('❌ REPO: Remote create failed: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      debugPrint('❌ REPO: Unexpected error: ${e.toString()}');
      return Left(ServerFailure(message: e.toString(), statusCode: '500'));
    }
  }

  @override
  ResultFuture<VehicleTagEntity> updateVehicleTag({
    required String tagId,
    String? label,
    List<VehicleTagType>? tagType,
    String? description,
  }) async {
    try {
      debugPrint('🔄 REPO: Updating vehicle tag: $tagId');
      final updatedTag = await _remoteDataSource.updateVehicleTag(
        tagId: tagId,
        label: label,
        tagType: tagType?.map((e) => e.name).toList(),
        description: description,
      );
      debugPrint('✅ REPO: Successfully updated vehicle tag: ${updatedTag.id}');
      return Right(updatedTag);
    } on ServerException catch (e) {
      debugPrint('❌ REPO: Remote update failed: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      debugPrint('❌ REPO: Unexpected error: ${e.toString()}');
      return Left(ServerFailure(message: e.toString(), statusCode: '500'));
    }
  }

  @override
  ResultFuture<bool> deleteVehicleTag(String tagId) async {
    try {
      debugPrint('🔄 REPO: Deleting vehicle tag: $tagId');
      final result = await _remoteDataSource.deleteVehicleTag(tagId);
      if (result) {
        debugPrint('✅ REPO: Successfully deleted vehicle tag');
        return const Right(true);
      } else {
        debugPrint('⚠️ REPO: Remote deletion returned false');
        return Left(
          ServerFailure(
            message: 'Failed to delete vehicle tag',
            statusCode: '500',
          ),
        );
      }
    } on ServerException catch (e) {
      debugPrint('❌ REPO: Remote deletion failed: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      debugPrint('❌ REPO: Unexpected error: ${e.toString()}');
      return Left(ServerFailure(message: e.toString(), statusCode: '500'));
    }
  }

  @override
  ResultFuture<bool> assignTagToVehicle({
    required String vehicleId,
    required String tagId,
  }) async {
    try {
      debugPrint('🔄 REPO: Assigning tag $tagId to vehicle $vehicleId');
      final result = await _remoteDataSource.assignTagToVehicle(
        vehicleId: vehicleId,
        tagId: tagId,
      );
      if (result) {
        debugPrint('✅ REPO: Successfully assigned tag to vehicle');
        return const Right(true);
      } else {
        debugPrint('⚠️ REPO: Remote assignment returned false');
        return Left(
          ServerFailure(
            message: 'Failed to assign tag to vehicle',
            statusCode: '500',
          ),
        );
      }
    } on ServerException catch (e) {
      debugPrint('❌ REPO: Remote assignment failed: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      debugPrint('❌ REPO: Unexpected error: ${e.toString()}');
      return Left(ServerFailure(message: e.toString(), statusCode: '500'));
    }
  }

  @override
  ResultFuture<bool> unassignTagFromVehicle({
    required String vehicleId,
    required String tagId,
  }) async {
    try {
      debugPrint('🔄 REPO: Unassigning tag $tagId from vehicle $vehicleId');
      final result = await _remoteDataSource.unassignTagFromVehicle(
        vehicleId: vehicleId,
        tagId: tagId,
      );
      if (result) {
        debugPrint('✅ REPO: Successfully unassigned tag from vehicle');
        return const Right(true);
      } else {
        debugPrint('⚠️ REPO: Remote unassignment returned false');
        return Left(
          ServerFailure(
            message: 'Failed to unassign tag from vehicle',
            statusCode: '500',
          ),
        );
      }
    } on ServerException catch (e) {
      debugPrint('❌ REPO: Remote unassignment failed: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      debugPrint('❌ REPO: Unexpected error: ${e.toString()}');
      return Left(ServerFailure(message: e.toString(), statusCode: '500'));
    }
  }
}
