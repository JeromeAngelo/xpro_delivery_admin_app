import 'package:equatable/equatable.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/trip/domain/entity/trip_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/trip/domain/repo/trip_repo.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';
import 'package:xpro_delivery_admin_app/core/usecases/usecase.dart';

class FilterTripsByUser extends UsecaseWithParams<List<TripEntity>, FilterTripsByUserParams> {
  final TripRepo _repo;

  const FilterTripsByUser(this._repo);

  @override
  ResultFuture<List<TripEntity>> call(FilterTripsByUserParams params) async {
    return _repo.filterTripsByUser(
      userId: params.userId,
    );
  }
}

class FilterTripsByUserParams extends Equatable {
  final String userId;

  const FilterTripsByUserParams({
    required this.userId,
  });

  @override
  List<Object?> get props => [userId];

  @override
  String toString() {
    return 'FilterTripsByUserParams(userId: $userId)';
  }
}
