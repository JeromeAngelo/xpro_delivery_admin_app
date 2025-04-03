import 'package:dartz/dartz.dart';
import 'package:desktop_app/core/common/app/features/end_trip_checklist/data/datasources/remote_datasource/end_trip_checklist_remote_data_src.dart';
import 'package:desktop_app/core/common/app/features/end_trip_checklist/domain/entity/end_checklist_entity.dart';
import 'package:desktop_app/core/common/app/features/end_trip_checklist/domain/repo/end_trip_checklist_repo.dart';
import 'package:desktop_app/core/errors/exceptions.dart';
import 'package:desktop_app/core/errors/failures.dart';
import 'package:desktop_app/core/typedefs/typedefs.dart';
import 'package:flutter/material.dart';

class EndTripChecklistRepoImpl implements EndTripChecklistRepo {
  EndTripChecklistRepoImpl(this._remoteDataSource);

  final EndTripChecklistRemoteDataSource _remoteDataSource;

  @override
  ResultFuture<List<EndChecklistEntity>> getAllEndTripChecklists() async {
    try {
      debugPrint('🔄 Getting all end trip checklists from remote');
      final remoteChecklists = await _remoteDataSource.getAllEndTripChecklists();
      debugPrint('✅ Successfully retrieved ${remoteChecklists.length} checklists');
      return Right(remoteChecklists);
    } on ServerException catch (e) {
      debugPrint('❌ Server error getting all checklists: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  ResultFuture<List<EndChecklistEntity>> generateEndTripChecklist(String tripId) async {
    try {
      debugPrint('🔄 Generating checklist for trip: $tripId');
      final remoteChecklist = await _remoteDataSource.generateEndTripChecklist(tripId);
      debugPrint('✅ Successfully generated ${remoteChecklist.length} checklist items');
      return Right(remoteChecklist);
    } on ServerException catch (e) {
      debugPrint('❌ Server error generating checklist: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  ResultFuture<bool> checkEndTripChecklistItem(String id) async {
    try {
      debugPrint('🔄 Checking checklist item: $id');
      final result = await _remoteDataSource.checkEndTripChecklistItem(id);
      debugPrint('✅ Successfully checked checklist item');
      return Right(result);
    } on ServerException catch (e) {
      debugPrint('❌ Server error checking checklist item: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  ResultFuture<List<EndChecklistEntity>> loadEndTripChecklist(String tripId) async {
    try {
      debugPrint('🔄 Loading checklist for trip: $tripId');
      final remoteChecklist = await _remoteDataSource.loadEndTripChecklist(tripId);
      debugPrint('✅ Successfully loaded ${remoteChecklist.length} checklist items');
      return Right(remoteChecklist);
    } on ServerException catch (e) {
      debugPrint('❌ Server error loading checklist: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  ResultFuture<EndChecklistEntity> createEndTripChecklistItem({
    required String objectName,
    required bool isChecked,
    required String tripId,
    String? status,
    DateTime? timeCompleted,
  }) async {
    try {
      debugPrint('🔄 Creating new checklist item: $objectName');
      final createdItem = await _remoteDataSource.createEndTripChecklistItem(
        objectName: objectName,
        isChecked: isChecked,
        tripId: tripId,
        status: status,
        timeCompleted: timeCompleted,
      );
      debugPrint('✅ Successfully created checklist item with ID: ${createdItem.id}');
      return Right(createdItem);
    } on ServerException catch (e) {
      debugPrint('❌ Server error creating checklist item: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  ResultFuture<EndChecklistEntity> updateEndTripChecklistItem({
    required String id,
    String? objectName,
    bool? isChecked,
    String? tripId,
    String? status,
    DateTime? timeCompleted,
  }) async {
    try {
      debugPrint('🔄 Updating checklist item: $id');
      final updatedItem = await _remoteDataSource.updateEndTripChecklistItem(
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
  ResultFuture<bool> deleteEndTripChecklistItem(String id) async {
    try {
      debugPrint('🔄 Deleting checklist item: $id');
      final result = await _remoteDataSource.deleteEndTripChecklistItem(id);
      debugPrint('✅ Successfully deleted checklist item');
      return Right(result);
    } on ServerException catch (e) {
      debugPrint('❌ Server error deleting checklist item: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  ResultFuture<bool> deleteAllEndTripChecklistItems(List<String> ids) async {
    try {
      debugPrint('🔄 Deleting multiple checklist items: ${ids.length} items');
      final result = await _remoteDataSource.deleteAllEndTripChecklistItems(ids);
      debugPrint('✅ Successfully deleted all checklist items');
      return Right(result);
    } on ServerException catch (e) {
      debugPrint('❌ Server error deleting multiple checklist items: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }
}
