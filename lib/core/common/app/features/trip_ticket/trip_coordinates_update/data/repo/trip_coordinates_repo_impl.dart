import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/trip_ticket/trip_coordinates_update/data/datasources/remote_datasource/trip_coordinates_remote_datasource.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/trip_ticket/trip_coordinates_update/domain/entity/trip_coordinates_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/trip_ticket/trip_coordinates_update/domain/repo/trip_coordinates_repo.dart';
import 'package:xpro_delivery_admin_app/core/errors/exceptions.dart';
import 'package:xpro_delivery_admin_app/core/errors/failures.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';

class TripCoordinatesRepoImpl implements TripCoordinatesRepo {
  final TripCoordinatesRemoteDataSource _remoteDataSource;

  const TripCoordinatesRepoImpl(this._remoteDataSource);

  @override
  ResultFuture<List<TripCoordinatesEntity>> getTripCoordinatesByTripId(String tripId) async {
    try {
      debugPrint('🌐 Fetching trip coordinates from remote for trip: $tripId');
      final remoteCoordinates = await _remoteDataSource.getTripCoordinatesByTripId(tripId);
      debugPrint('✅ Retrieved ${remoteCoordinates.length} trip coordinates');
      return Right(remoteCoordinates);
    } on ServerException catch (e) {
      debugPrint('⚠️ API Error: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      debugPrint('⚠️ Unexpected Error: $e');
      return Left(ServerFailure(
        message: 'An unexpected error occurred: $e',
        statusCode: '500',
      ));
    }
  }
}
