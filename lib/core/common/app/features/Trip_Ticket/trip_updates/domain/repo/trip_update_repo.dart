import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/trip_updates/domain/entity/trip_update_entity.dart';
import 'package:xpro_delivery_admin_app/core/enums/trip_update_status.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';

abstract class TripUpdateRepo {
  const TripUpdateRepo();

  // Get all trip updates
  ResultFuture<List<TripUpdateEntity>> getAllTripUpdates();

  // Load trip updates for a specific trip
  ResultFuture<List<TripUpdateEntity>> getTripUpdates(String tripId);

 // In trip_update_repo.dart
ResultFuture<TripUpdateEntity> createTripUpdate({
  required String tripId,
  required String description,
  required String image,
  required String latitude,
  required String longitude,
  required TripUpdateStatus status,
});


  // Update existing trip update
  ResultFuture<TripUpdateEntity> updateTripUpdate({
    required String updateId,
    String? description,
    String? image,
    String? latitude,
    String? longitude,
    TripUpdateStatus? status,
  });

  // Delete a specific trip update
  ResultFuture<bool> deleteTripUpdate(String updateId);

  // Delete all trip updates
  ResultFuture<bool> deleteAllTripUpdates();
}
