

import '../../../../../../../typedefs/typedefs.dart';
import '../../../../../../../usecases/usecase.dart';
import '../entity/collection_entity.dart';
import '../repo/collection_repo.dart';

class GetCollectionsByTripId extends UsecaseWithParams<List<CollectionEntity>, String> {
  const GetCollectionsByTripId(this._repo);

  final CollectionRepo _repo;

  @override
  ResultFuture<List<CollectionEntity>> call(String tripId) {
    return _repo.getCollectionsByTripId(tripId);
  }

 
}
