import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/trip/domain/entity/trip_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/trip/domain/repo/trip_repo.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';
import 'package:xpro_delivery_admin_app/core/usecases/usecase.dart';

class GetTripTicketById extends UsecaseWithParams<TripEntity, String> {
  final TripRepo _repo;

  const GetTripTicketById(this._repo);

  @override
  ResultFuture<TripEntity> call(String tripId) {
    return _repo.getTripTicketById(tripId);
  }
}
