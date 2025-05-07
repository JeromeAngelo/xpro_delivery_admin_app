import 'package:dartz/dartz.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/users_trip_collection/data/datasources/remote_datasource/users_trip_collection_remote_datasource.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/users_trip_collection/domain/entity/user_trip_collection_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/users_trip_collection/domain/repo/user_trip_collection_repo.dart';
import 'package:xpro_delivery_admin_app/core/errors/exceptions.dart';
import 'package:xpro_delivery_admin_app/core/errors/failures.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';
import 'package:flutter/foundation.dart';

class UsersTripCollectionRepoImpl implements UserTripCollectionRepo {
  final UsersTripCollectionRemoteDataSource _remoteDataSource;

  const UsersTripCollectionRepoImpl(this._remoteDataSource);

  @override
  ResultFuture<List<UserTripCollectionEntity>> getUserTripCollections(String userId) async {
    try {
      debugPrint('🌐 Fetching trip collections from remote for user: $userId');
      final remoteTripCollections = await _remoteDataSource.getUserTripCollections(userId);
      return Right(remoteTripCollections);
    } on ServerException catch (e) {
      debugPrint('⚠️ API Error: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  
}
