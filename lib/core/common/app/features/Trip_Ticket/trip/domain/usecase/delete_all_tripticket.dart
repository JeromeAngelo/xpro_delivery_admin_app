import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/trip/domain/repo/trip_repo.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';
import 'package:xpro_delivery_admin_app/core/usecases/usecase.dart';

class DeleteAllTripTickets extends UsecaseWithoutParams<bool> {
  final TripRepo _repo;

  const DeleteAllTripTickets(this._repo);

  @override
  ResultFuture<bool> call() {
    return _repo.deleteAllTripTickets();
  }
}
