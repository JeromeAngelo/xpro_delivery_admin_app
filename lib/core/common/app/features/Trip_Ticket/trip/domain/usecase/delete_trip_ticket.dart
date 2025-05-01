import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/trip/domain/repo/trip_repo.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';
import 'package:xpro_delivery_admin_app/core/usecases/usecase.dart';

class DeleteTripTicket extends UsecaseWithParams<bool, String> {
  final TripRepo _repo;

  const DeleteTripTicket(this._repo);

  @override
  ResultFuture<bool> call(String tripId) {
    return _repo.deleteTripTicket(tripId);
  }
}
