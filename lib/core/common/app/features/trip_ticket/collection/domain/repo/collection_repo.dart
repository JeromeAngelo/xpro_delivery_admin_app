import '../../../../../../../typedefs/typedefs.dart';
import '../entity/collection_entity.dart';

abstract class CollectionRepo {
  const CollectionRepo();

  /// Load collections by trip ID from remote
  ResultFuture<List<CollectionEntity>> getCollectionsByTripId(String tripId);

  /// Load collection by ID from remote
  ResultFuture<CollectionEntity> getCollectionById(String collectionId);

  /// Load all collections
  ResultFuture<List<CollectionEntity>> getAllCollections();

  /// Delete collection
  ResultFuture<bool> deleteCollection(String collectionId);

  /// Filter collections by date range
  ResultFuture<List<CollectionEntity>> filterCollectionsByDate({
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Update a collection's totalAmount and mop
  ResultFuture<CollectionEntity> updateCollection({
    required String collectionId,
    required double totalAmount,
    required String mop,
  });

  /// Fix delivery collections by matching deliveryData id with deliveryReceipt
  /// and copying totalAmount and mop from deliveryReceipt to collection
  ResultFuture<List<CollectionEntity>> fixDeliveryCollections();
}
