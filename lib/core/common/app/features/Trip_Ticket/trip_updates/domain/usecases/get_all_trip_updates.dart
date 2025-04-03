import 'package:desktop_app/core/common/app/features/Trip_Ticket/trip_updates/domain/entity/trip_update_entity.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/trip_updates/domain/repo/trip_update_repo.dart';
import 'package:desktop_app/core/typedefs/typedefs.dart';
import 'package:desktop_app/core/usecases/usecase.dart';

class GetAllTripUpdates extends UsecaseWithoutParams<List<TripUpdateEntity>> {
  final TripUpdateRepo _repo;

  const GetAllTripUpdates(this._repo);

  @override
  ResultFuture<List<TripUpdateEntity>> call() async {
    return _repo.getAllTripUpdates();
  }
}
