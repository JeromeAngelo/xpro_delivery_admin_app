import 'package:desktop_app/core/common/app/features/Trip_Ticket/trip/domain/entity/trip_entity.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/trip/domain/repo/trip_repo.dart';
import 'package:desktop_app/core/typedefs/typedefs.dart';
import 'package:desktop_app/core/usecases/usecase.dart';

class UpdateTripTicket extends UsecaseWithParams<TripEntity, TripEntity> {
  final TripRepo _repo;

  const UpdateTripTicket(this._repo);

  @override
  ResultFuture<TripEntity> call(TripEntity trip) {
    return _repo.updateTripTicket(trip);
  }
}
