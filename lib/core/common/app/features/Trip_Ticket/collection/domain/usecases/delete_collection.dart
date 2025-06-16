

import '../../../../../../../typedefs/typedefs.dart';
import '../../../../../../../usecases/usecase.dart';
import '../repo/collection_repo.dart';

class DeleteCollection extends UsecaseWithParams<bool, String> {
  const DeleteCollection(this._repo);

  final CollectionRepo _repo;

  @override
  ResultFuture<bool> call(String collectionId) {
    return _repo.deleteCollection(collectionId);
  }
}
