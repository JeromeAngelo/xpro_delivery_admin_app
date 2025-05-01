import 'package:dartz/dartz.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/trip_updates/data/datasources/remote_datasource/trip_update_remote_datasource.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/trip_updates/data/model/trip_update_model.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/trip_updates/domain/entity/trip_update_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/trip_updates/domain/repo/trip_update_repo.dart';
import 'package:xpro_delivery_admin_app/core/enums/trip_update_status.dart';
import 'package:xpro_delivery_admin_app/core/errors/exceptions.dart';
import 'package:xpro_delivery_admin_app/core/errors/failures.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';
import 'package:flutter/foundation.dart';

class TripUpdateRepoImpl extends TripUpdateRepo {
  TripUpdateRepoImpl(this._remoteDataSource);

  final TripUpdateRemoteDatasource _remoteDataSource;

  @override
  ResultFuture<List<TripUpdateEntity>> getTripUpdates(String tripId) async {
    try {
      debugPrint('🔄 Fetching trip updates from remote source...');
      final remoteUpdates = await _remoteDataSource.getTripUpdates(tripId);
      debugPrint('✅ Successfully retrieved ${remoteUpdates.length} trip updates');
      return Right(remoteUpdates);
    } on ServerException catch (e) {
      debugPrint('❌ Server error: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  ResultFuture<TripUpdateEntity> createTripUpdate({
    required String tripId,
    required String description,
    required String image,
    required String latitude,
    required String longitude,
    required TripUpdateStatus status,
  }) async {
    try {
      debugPrint('🔄 Creating trip update...');
      await _remoteDataSource.createTripUpdate(
        tripId: tripId,
        description: description,
        image: image,
        latitude: latitude,
        longitude: longitude,
        status: status,
      );
      
      // Since the remote datasource doesn't return the created entity,
      // we'll create a model with the provided data
      final createdUpdate = TripUpdateModel(
        id: 'pending', // This will be replaced when fetched from server
        description: description,
        status: status,
        latitude: latitude,
        longitude: longitude,
        date: DateTime.now(),
      );
      
      debugPrint('✅ Trip update created successfully');
      return Right(createdUpdate);
    } on ServerException catch (e) {
      debugPrint('❌ Server error: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  ResultFuture<List<TripUpdateEntity>> getAllTripUpdates() async {
    try {
      debugPrint('🔄 Fetching all trip updates...');
      final updates = await _remoteDataSource.getAllTripUpdates();
      debugPrint('✅ Successfully retrieved ${updates.length} trip updates');
      return Right(updates);
    } on ServerException catch (e) {
      debugPrint('❌ Server error: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  ResultFuture<TripUpdateEntity> updateTripUpdate({
    required String updateId,
    String? description,
    String? image,
    String? latitude,
    String? longitude,
    TripUpdateStatus? status,
  }) async {
    try {
      debugPrint('🔄 Updating trip update: $updateId');
      final updatedUpdate = await _remoteDataSource.updateTripUpdate(
        updateId: updateId,
        description: description,
        image: image,
        latitude: latitude,
        longitude: longitude,
        status: status,
      );
      debugPrint('✅ Trip update updated successfully');
      return Right(updatedUpdate);
    } on ServerException catch (e) {
      debugPrint('❌ Server error: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  ResultFuture<bool> deleteTripUpdate(String updateId) async {
    try {
      debugPrint('🔄 Deleting trip update: $updateId');
      final result = await _remoteDataSource.deleteTripUpdate(updateId);
      debugPrint('✅ Trip update deleted successfully');
      return Right(result);
    } on ServerException catch (e) {
      debugPrint('❌ Server error: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  ResultFuture<bool> deleteAllTripUpdates() async {
    try {
      debugPrint('🔄 Deleting all trip updates');
      final result = await _remoteDataSource.deleteAllTripUpdates();
      debugPrint('✅ All trip updates deleted successfully');
      return Right(result);
    } on ServerException catch (e) {
      debugPrint('❌ Server error: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }
}
