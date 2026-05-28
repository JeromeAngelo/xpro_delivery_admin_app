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
  ResultFuture<List<CollectionEntity>> getCollectionsByTripId(
    String tripId,
  ) async {
    try {
      debugPrint('🔄 REPO: Fetching collections from remote for trip: $tripId');

      final remoteCollections = await _remoteDataSource.getCollectionsByTripId(
        tripId,
      );

      debugPrint(
        '✅ REPO: Successfully fetched ${remoteCollections.length} collections from remote',
      );
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
      debugPrint(
        '🔄 REPO: Fetching collection from remote by ID: $collectionId',
      );

      final remoteCollection = await _remoteDataSource.getCollectionById(
        collectionId,
      );

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
        return Left(
          ServerFailure(
            message: 'Failed to delete collection from remote',
            statusCode: '500',
          ),
        );
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

      debugPrint(
        '✅ REPO: Successfully fetched ${remoteCollections.length} collections from remote',
      );
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
  ResultFuture<List<CollectionEntity>> filterCollectionsByDate({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      debugPrint('🔄 REPO: Filtering collections by date range');
      debugPrint('📅 REPO: Start Date: ${startDate.toIso8601String()}');
      debugPrint('📅 REPO: End Date: ${endDate.toIso8601String()}');

      final remoteCollections = await _remoteDataSource.filterCollectionsByDate(
        startDate: startDate,
        endDate: endDate,
      );

      debugPrint(
        '✅ REPO: Successfully filtered ${remoteCollections.length} collections by date range',
      );
      return Right(remoteCollections);
    } on ServerException catch (e) {
      debugPrint('❌ REPO: Date filtering failed: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      debugPrint(
        '❌ REPO: Unexpected error during date filtering: ${e.toString()}',
      );
      return Left(ServerFailure(message: e.toString(), statusCode: '500'));
    }
  }

  @override
  ResultFuture<CollectionEntity> updateCollection({
    required String collectionId,
    required double totalAmount,
    required String mop,
  }) async {
    try {
      debugPrint('🔄 REPO: Updating collection: $collectionId');
      debugPrint('💰 REPO: totalAmount: $totalAmount, mop: $mop');

      final updatedCollection = await _remoteDataSource.updateCollection(
        collectionId: collectionId,
        totalAmount: totalAmount,
        mop: mop,
      );

      debugPrint(
        '✅ REPO: Successfully updated collection: ${updatedCollection.id}',
      );
      return Right(updatedCollection);
    } on ServerException catch (e) {
      debugPrint('❌ REPO: Collection update failed: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      debugPrint(
        '❌ REPO: Unexpected error during collection update: ${e.toString()}',
      );
      return Left(ServerFailure(message: e.toString(), statusCode: '500'));
    }
  }

  @override
  ResultFuture<List<CollectionEntity>> fixDeliveryCollections() async {
    try {
      debugPrint('🔄 REPO: Starting fix delivery collections');

      final updatedCollections =
          await _remoteDataSource.fixDeliveryCollections();

      debugPrint(
        '✅ REPO: Successfully fixed ${updatedCollections.length} delivery collections',
      );
      return Right(updatedCollections);
    } on ServerException catch (e) {
      debugPrint('❌ REPO: Fix delivery collections failed: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      debugPrint(
        '❌ REPO: Unexpected error during fix delivery collections: ${e.toString()}',
      );
      return Left(ServerFailure(message: e.toString(), statusCode: '500'));
    }
  }
}
