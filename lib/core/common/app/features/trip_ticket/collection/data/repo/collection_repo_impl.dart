import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

import '../../../../../../../errors/exceptions.dart';
import '../../../../../../../errors/failures.dart';
import '../../../../../../../typedefs/typedefs.dart';
import '../../../trip/domain/entity/trip_entity.dart';
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

  @override
  ResultFuture<List<int>> exportTripCollections({
    required TripEntity trip,
    required List<CollectionEntity> collections,
  }) async {
    try {
      debugPrint('🔄 REPO: Exporting trip collections to CSV');

      final csvBytes = _buildTripCollectionsCsv(trip, collections);

      debugPrint(
        '✅ REPO: Successfully generated CSV (${csvBytes.length} bytes)',
      );
      return Right(csvBytes);
    } catch (e) {
      debugPrint('❌ REPO: Failed to export trip collections: ${e.toString()}');
      return Left(ServerFailure(message: e.toString(), statusCode: '500'));
    }
  }

  /// Build CSV bytes from trip and collections data
  List<int> _buildTripCollectionsCsv(
    TripEntity trip,
    List<CollectionEntity> collections,
  ) {
    String csvEscape(String v) {
      final needsQuotes =
          v.contains(',') ||
          v.contains('"') ||
          v.contains('\n') ||
          v.contains('\r');
      var out = v.replaceAll('"', '""');
      if (needsQuotes) out = '"$out"';
      return out;
    }

    final rows = <List<String>>[
      // Header row
      [
        'Trip Number',
        'Trip Route',
        'Customer RefID',
        'Customer Name',
        'Customer Location',
        'Invoices',
        'Picklist ID Ref',
        'Mode of Payment',
        'Expected Total Amount',
        'Total Amount Collected',
        'Status',
        'Date Created',
      ],
      // Data rows
      ...collections.map((collection) {
        // If collection totalAmount is 0 or null, use deliveryData totalAmount
        final totalAmountCollected =
            (collection.totalAmount != null && collection.totalAmount! > 0)
                ? collection.totalAmount!
                : collection.deliveryData?.totalAmount ?? 0.0;

        // Format invoices list — show all invoice names in one row
        String invoicesText = 'N/A';
        if (collection.invoices != null && collection.invoices!.isNotEmpty) {
          invoicesText = collection.invoices!
              .map((inv) => inv.name ?? 'N/A')
              .join('; ');
        } else if (collection.invoice?.name != null) {
          invoicesText = collection.invoice!.name!;
        }

        return [
          trip.tripNumberId ?? 'N/A',
          trip.name ?? 'N/A',
          collection.customer?.refId ?? 'N/A',
          collection.customer?.name ?? 'N/A',
          collection.customer?.province ?? 'N/A',
          invoicesText,
          collection.deliveryData?.refID ?? 'N/A',
          collection.mop ?? 'N/A',
          (collection.deliveryData?.totalAmount ?? 0.0).toStringAsFixed(2),
          totalAmountCollected.toStringAsFixed(2),
          collection.status ?? 'N/A',
          collection.created != null
              ? collection.created!.toIso8601String()
              : 'N/A',
        ];
      }),
    ];

    final csv = rows.map((r) => r.map(csvEscape).join(',')).join('\r\n');

    return utf8.encode(csv);
  }
}
