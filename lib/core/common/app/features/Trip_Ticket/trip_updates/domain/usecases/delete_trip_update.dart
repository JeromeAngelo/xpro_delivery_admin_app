import 'package:desktop_app/core/common/app/features/Trip_Ticket/trip_updates/domain/repo/trip_update_repo.dart';
import 'package:desktop_app/core/typedefs/typedefs.dart';
import 'package:desktop_app/core/usecases/usecase.dart';

class DeleteTripUpdate extends UsecaseWithParams<bool, String> {
  final TripUpdateRepo _repo;

  const DeleteTripUpdate(this._repo);

  @override
  ResultFuture<bool> call(String updateId) async {
    return _repo.deleteTripUpdate(updateId);
  }
}
