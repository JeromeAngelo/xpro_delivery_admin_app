import 'package:dartz/dartz.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/checklist/data/datasource/remote_datasource/checklist_datasource.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/checklist/domain/entity/checklist_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/checklist/domain/repo/checklist_repo.dart';
import 'package:xpro_delivery_admin_app/core/errors/exceptions.dart';
import 'package:xpro_delivery_admin_app/core/errors/failures.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';
import 'package:flutter/material.dart';

class ChecklistRepoImpl implements ChecklistRepo {
  final ChecklistDatasource _remoteDatasource;

  ChecklistRepoImpl(this._remoteDatasource);

  @override
  ResultFuture<List<ChecklistEntity>> getAllChecklists() async {
    try {
      debugPrint('🔄 Getting all checklists from remote');
      final remoteChecklists = await _remoteDatasource.getAllChecklists();
      debugPrint(
        '✅ Successfully retrieved ${remoteChecklists.length} checklists',
      );
      return Right(remoteChecklists);
    } on ServerException catch (e) {
      debugPrint('❌ Server error getting all checklists: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  ResultFuture<bool> checkItem(String id) async {
    try {
      debugPrint('🔄 Checking item remotely: $id');
      final remoteResult = await _remoteDatasource.checkItem(id);
      debugPrint('✅ Successfully checked item');
      return Right(remoteResult);
    } on ServerException catch (e) {
      debugPrint('❌ Remote check failed: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  ResultFuture<List<ChecklistEntity>> loadChecklistByTripId(
    String? tripId,
  ) async {
    try {
      if (tripId == null) {
        debugPrint('⚠️ Trip ID is null, returning empty list');
        return const Right([]);
      }

      debugPrint('🔄 Loading checklist from remote for trip: $tripId');
      final remoteChecklist = await _remoteDatasource.loadChecklistByTripId(
        tripId,
      );
      debugPrint(
        '✅ Successfully loaded ${remoteChecklist.length} checklist items for trip',
      );
      return Right(remoteChecklist);
    } on ServerException catch (e) {
      debugPrint('❌ Failed to load checklist for trip: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  ResultFuture<ChecklistEntity> createChecklistItem({
    required String objectName,
    required bool isChecked,
    String? tripId,
    String? status,
    DateTime? timeCompleted,
  }) async {
    try {
      debugPrint('🔄 Creating new checklist item: $objectName');
      final createdItem = await _remoteDatasource.createChecklistItem(
        objectName: objectName,
        isChecked: isChecked,
        tripId: tripId,
        status: status,
        timeCompleted: timeCompleted,
      );
      debugPrint(
        '✅ Successfully created checklist item with ID: ${createdItem.id}',
      );
      return Right(createdItem);
    } on ServerException catch (e) {
      debugPrint('❌ Server error creating checklist item: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  ResultFuture<ChecklistEntity> updateChecklistItem({
    required String id,
    String? objectName,
    bool? isChecked,
    String? tripId,
    String? status,
    DateTime? timeCompleted,
  }) async {
    try {
      debugPrint('🔄 Updating checklist item: $id');
      final updatedItem = await _remoteDatasource.updateChecklistItem(
        id: id,
        objectName: objectName,
        isChecked: isChecked,
        tripId: tripId,
        status: status,
        timeCompleted: timeCompleted,
      );
      debugPrint('✅ Successfully updated checklist item');
      return Right(updatedItem);
    } on ServerException catch (e) {
      debugPrint('❌ Server error updating checklist item: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  ResultFuture<bool> deleteChecklistItem(String id) async {
    try {
      debugPrint('🔄 Deleting checklist item: $id');
      final result = await _remoteDatasource.deleteChecklistItem(id);
      debugPrint('✅ Successfully deleted checklist item');
      return Right(result);
    } on ServerException catch (e) {
      debugPrint('❌ Server error deleting checklist item: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  ResultFuture<bool> deleteAllChecklistItems(List<String> ids) async {
    try {
      debugPrint('🔄 Deleting multiple checklist items: ${ids.length} items');
      final result = await _remoteDatasource.deleteAllChecklistItems(ids);
      debugPrint('✅ Successfully deleted all checklist items');
      return Right(result);
    } on ServerException catch (e) {
      debugPrint(
        '❌ Server error deleting multiple checklist items: ${e.message}',
      );
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }
}
