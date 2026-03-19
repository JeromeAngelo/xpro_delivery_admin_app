import 'package:equatable/equatable.dart';
import 'package:xpro_delivery_admin_app/core/usecases/usecase.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';
import '../entity/collection_entity.dart';
import '../repo/collection_repo.dart';

class FilterCollectionsByDate extends UsecaseWithParams<List<CollectionEntity>, FilterCollectionsByDateParams> {
  const FilterCollectionsByDate(this._repo);

  final CollectionRepo _repo;

  @override
  ResultFuture<List<CollectionEntity>> call(FilterCollectionsByDateParams params) =>
      _repo.filterCollectionsByDate(
        startDate: params.startDate,
        endDate: params.endDate,
      );
}

class FilterCollectionsByDateParams extends Equatable {
  const FilterCollectionsByDateParams({
    required this.startDate,
    required this.endDate,
  });

  final DateTime startDate;
  final DateTime endDate;

  @override
  List<Object> get props => [startDate, endDate];
}
