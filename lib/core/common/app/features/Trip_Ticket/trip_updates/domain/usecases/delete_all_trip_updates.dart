import 'package:desktop_app/core/common/app/features/Trip_Ticket/trip_updates/domain/repo/trip_update_repo.dart';
import 'package:desktop_app/core/typedefs/typedefs.dart';
import 'package:desktop_app/core/usecases/usecase.dart';

class DeleteAllTripUpdates extends UsecaseWithoutParams<bool> {
  final TripUpdateRepo _repo;

  const DeleteAllTripUpdates(this._repo);

  @override
  ResultFuture<bool> call() async {
    return _repo.deleteAllTripUpdates();
  }
}
