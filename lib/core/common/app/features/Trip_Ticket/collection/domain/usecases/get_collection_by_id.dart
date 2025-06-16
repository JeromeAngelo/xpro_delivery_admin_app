

import '../../../../../../../typedefs/typedefs.dart';
import '../../../../../../../usecases/usecase.dart';
import '../entity/collection_entity.dart';
import '../repo/collection_repo.dart';

class GetCollectionById extends UsecaseWithParams<CollectionEntity, String> {
  const GetCollectionById(this._repo);

  final CollectionRepo _repo;

  @override
  ResultFuture<CollectionEntity> call(String collectionId) {
    return _repo.getCollectionById(collectionId);
  }

 
}
