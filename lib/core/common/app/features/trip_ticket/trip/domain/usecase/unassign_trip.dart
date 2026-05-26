import 'package:equatable/equatable.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/trip_ticket/trip/domain/entity/trip_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/trip_ticket/trip/domain/repo/trip_repo.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';
import 'package:xpro_delivery_admin_app/core/usecases/usecase.dart';

class UnassignTrip extends UsecaseWithParams<TripEntity, UnassignTripParams> {
  final TripRepo _repo;

  const UnassignTrip(this._repo);

  @override
  ResultFuture<TripEntity> call(UnassignTripParams params) {
    return _repo.unassignTrip(tripId: params.tripId, remarks: params.remarks);
  }
}

class UnassignTripParams extends Equatable {
  final String tripId;
  final String remarks;

  const UnassignTripParams({required this.tripId, required this.remarks});

  @override
  List<Object?> get props => [tripId, remarks];

  @override
  String toString() {
    return 'UnassignTripParams(tripId: $tripId, remarks: $remarks)';
  }
}
