import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/trip_updates/domain/entity/trip_update_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/trip_updates/domain/repo/trip_update_repo.dart';
import 'package:xpro_delivery_admin_app/core/enums/trip_update_status.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';
import 'package:xpro_delivery_admin_app/core/usecases/usecase.dart';
import 'package:equatable/equatable.dart';

class UpdateTripUpdate extends UsecaseWithParams<TripUpdateEntity, UpdateTripUpdateParams> {
  final TripUpdateRepo _repo;

  const UpdateTripUpdate(this._repo);

  @override
  ResultFuture<TripUpdateEntity> call(UpdateTripUpdateParams params) async {
    return _repo.updateTripUpdate(
      updateId: params.updateId,
      description: params.description,
      image: params.image,
      latitude: params.latitude,
      longitude: params.longitude,
      status: params.status,
    );
  }
}

class UpdateTripUpdateParams extends Equatable {
  final String updateId;
  final String? description;
  final String? image;
  final String? latitude;
  final String? longitude;
  final TripUpdateStatus? status;

  const UpdateTripUpdateParams({
    required this.updateId,
    this.description,
    this.image,
    this.latitude,
    this.longitude,
    this.status,
  });

  @override
  List<Object?> get props => [
    updateId,
    description,
    image,
    latitude,
    longitude,
    status,
  ];
}
