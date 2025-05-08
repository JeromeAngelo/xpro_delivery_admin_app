import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/trip_coordinates_update/domain/entity/trip_coordinates_entity.dart';
import 'package:xpro_delivery_admin_app/core/errors/failures.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';

abstract class TripCoordinatesRepo {
  const TripCoordinatesRepo();

  /// Retrieves all trip coordinate updates for a specific trip
  ///
  /// [tripId] The ID of the trip to get coordinates for
  /// Returns a list of [TripCoordinatesEntity] objects or a [Failure]
  ResultFuture<List<TripCoordinatesEntity>> getTripCoordinatesByTripId(String tripId);
}
