import 'package:equatable/equatable.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/trip/domain/entity/trip_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/trip/domain/repo/trip_repo.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';
import 'package:xpro_delivery_admin_app/core/usecases/usecase.dart';

class FilterTripsByDateRange extends UsecaseWithParams<List<TripEntity>, FilterTripsByDateRangeParams> {
  final TripRepo _repo;

  const FilterTripsByDateRange(this._repo);

  @override
  ResultFuture<List<TripEntity>> call(FilterTripsByDateRangeParams params) async {
    return _repo.filterTripsByDateRange(
      startDate: params.startDate,
      endDate: params.endDate,
    );
  }
}

class FilterTripsByDateRangeParams extends Equatable {
  final DateTime startDate;
  final DateTime endDate;

  const FilterTripsByDateRangeParams({
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [startDate, endDate];

  @override
  String toString() {
    return 'FilterTripsByDateRangeParams(startDate: $startDate, endDate: $endDate)';
  }
}
