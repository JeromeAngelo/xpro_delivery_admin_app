import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/trip_updates/domain/entity/trip_update_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/trip_updates/domain/repo/trip_update_repo.dart';
import 'package:xpro_delivery_admin_app/core/enums/trip_update_status.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';
import 'package:xpro_delivery_admin_app/core/usecases/usecase.dart';
import 'package:equatable/equatable.dart';

class CreateTripUpdateParams extends Equatable {
  final String tripId;
  final String description;
  final String image;
  final String latitude;
  final String longitude;
  final TripUpdateStatus status;

  const CreateTripUpdateParams({
    required this.tripId,
    required this.description,
    required this.image,
    required this.latitude,
    required this.longitude,
    required this.status,
  });
  
  @override
  List<Object?> get props => [tripId, description, image, latitude, longitude, status];
}

class CreateTripUpdate extends UsecaseWithParams<TripUpdateEntity, CreateTripUpdateParams> {
  const CreateTripUpdate(this._repo);

  final TripUpdateRepo _repo;

  @override
  ResultFuture<TripUpdateEntity> call(CreateTripUpdateParams params) => _repo.createTripUpdate(
        tripId: params.tripId,
        description: params.description,
        image: params.image,
        latitude: params.latitude,
        longitude: params.longitude,
        status: params.status
      );
}
