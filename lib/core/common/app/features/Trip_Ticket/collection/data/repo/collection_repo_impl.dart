import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

import '../../../../../../../errors/exceptions.dart';
import '../../../../../../../errors/failures.dart';
import '../../../../../../../typedefs/typedefs.dart';
import '../../domain/entity/collection_entity.dart';
import '../../domain/repo/collection_repo.dart';
import '../datasource/remote_datasource/collection_remote_datasource.dart';

class CollectionRepoImpl implements CollectionRepo {
  const CollectionRepoImpl({
    required CollectionRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final CollectionRemoteDataSource _remoteDataSource;

  @override
  ResultFuture<List<CollectionEntity>> getCollectionsByTripId(String tripId) async {
    try {
      debugPrint('🔄 REPO: Fetching collections from remote for trip: $tripId');
      
      final remoteCollections = await _remoteDataSource.getCollectionsByTripId(tripId);
      
      debugPrint('✅ REPO: Successfully fetched ${remoteCollections.length} collections from remote');
      return Right(remoteCollections);

    } on ServerException catch (e) {
      debugPrint('❌ REPO: Remote fetch failed: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      debugPrint('❌ REPO: Unexpected error: ${e.toString()}');
      return Left(ServerFailure(message: e.toString(), statusCode: '500'));
    }
  }

  @override
  ResultFuture<CollectionEntity> getCollectionById(String collectionId) async {
    try {
      debugPrint('🔄 REPO: Fetching collection from remote by ID: $collectionId');
      
      final remoteCollection = await _remoteDataSource.getCollectionById(collectionId);
      
      debugPrint('✅ REPO: Successfully fetched collection from remote');
      return Right(remoteCollection);

    } on ServerException catch (e) {
      debugPrint('❌ REPO: Remote fetch failed: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      debugPrint('❌ REPO: Unexpected error: ${e.toString()}');
      return Left(ServerFailure(message: e.toString(), statusCode: '500'));
    }
  }

  @override
  ResultFuture<bool> deleteCollection(String collectionId) async {
    try {
      debugPrint('🔄 REPO: Deleting collection from remote: $collectionId');
      
      final result = await _remoteDataSource.deleteCollection(collectionId);
      
      if (result) {
        debugPrint('✅ REPO: Successfully deleted collection from remote');
        return const Right(true);
      } else {
        debugPrint('⚠️ REPO: Remote deletion returned false');
        return Left(ServerFailure(message: 'Failed to delete collection from remote', statusCode: '500'));
      }

    } on ServerException catch (e) {
      debugPrint('❌ REPO: Remote deletion failed: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      debugPrint('❌ REPO: Unexpected error during deletion: ${e.toString()}');
      return Left(ServerFailure(message: e.toString(), statusCode: '500'));
    }
  }

  @override
ResultFuture<List<CollectionEntity>> getAllCollections() async {
  try {
    debugPrint('🔄 REPO: Fetching all collections from remote');
    
    final remoteCollections = await _remoteDataSource.getAllCollections();
    
    debugPrint('✅ REPO: Successfully fetched ${remoteCollections.length} collections from remote');
    return Right(remoteCollections);

  } on ServerException catch (e) {
    debugPrint('❌ REPO: Remote fetch failed: ${e.message}');
    return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
  } catch (e) {
    debugPrint('❌ REPO: Unexpected error: ${e.toString()}');
    return Left(ServerFailure(message: e.toString(), statusCode: '500'));
  }
}

}
