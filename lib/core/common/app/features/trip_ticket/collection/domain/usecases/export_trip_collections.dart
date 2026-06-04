import 'package:xpro_delivery_admin_app/core/common/app/features/trip_ticket/collection/domain/entity/collection_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/trip_ticket/collection/domain/repo/collection_repo.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/trip_ticket/trip/domain/entity/trip_entity.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';
import 'package:xpro_delivery_admin_app/core/usecases/usecase.dart';

class ExportTripCollections
    extends UsecaseWithParams<List<int>, ExportTripCollectionsParams> {
  ExportTripCollections(this._repo);

  final CollectionRepo _repo;

  @override
  ResultFuture<List<int>> call(ExportTripCollectionsParams params) =>
      _repo.exportTripCollections(
        trip: params.trip,
        collections: params.collections,
      );
}

class ExportTripCollectionsParams {
  const ExportTripCollectionsParams({
    required this.trip,
    required this.collections,
  });

  final TripEntity trip;
  final List<CollectionEntity> collections;
}
