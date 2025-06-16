import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/collection/domain/entity/collection_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/collection/domain/repo/collection_repo.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';
import 'package:xpro_delivery_admin_app/core/usecases/usecase.dart';

class GetAllCollections extends UsecaseWithoutParams<List<CollectionEntity>> {

  GetAllCollections(this._repo);
  final CollectionRepo _repo;


  @override
  ResultFuture<List<CollectionEntity>> call() => _repo.getAllCollections();
}
