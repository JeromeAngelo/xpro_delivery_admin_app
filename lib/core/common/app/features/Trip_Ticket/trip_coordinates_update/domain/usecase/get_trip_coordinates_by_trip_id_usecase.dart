import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/trip_coordinates_update/domain/entity/trip_coordinates_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/trip_coordinates_update/domain/repo/trip_coordinates_repo.dart';
import 'package:xpro_delivery_admin_app/core/errors/failures.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';
import 'package:xpro_delivery_admin_app/core/usecases/usecase.dart';

/// Usecase to get all trip coordinates for a specific trip
class GetTripCoordinatesByTripId implements UsecaseWithParams<List<TripCoordinatesEntity>, String> {
  final TripCoordinatesRepo _repo;

  const GetTripCoordinatesByTripId(this._repo);

  /// Gets all trip coordinates for the specified trip ID
  ///
  /// [params] The ID of the trip to get coordinates for
  /// Returns a list of [TripCoordinatesEntity] objects or a [Failure]
  @override
  ResultFuture<List<TripCoordinatesEntity>> call(String params) async {
    return await _repo.getTripCoordinatesByTripId(params);
  }
}
