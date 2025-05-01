import 'package:xpro_delivery_admin_app/core/enums/trip_update_status.dart';
import 'package:equatable/equatable.dart';

abstract class TripUpdatesEvent extends Equatable {
  const TripUpdatesEvent();
}

class GetTripUpdatesEvent extends TripUpdatesEvent {
  final String tripId;
  const GetTripUpdatesEvent(this.tripId);
  
  @override
  List<Object?> get props => [tripId];
}

class GetAllTripUpdatesEvent extends TripUpdatesEvent {
  const GetAllTripUpdatesEvent();
  
  @override
  List<Object?> get props => [];
}

class CreateTripUpdateEvent extends TripUpdatesEvent {
  final String tripId;
  final String description;
  final String image;
  final String latitude;
  final String longitude;
  final TripUpdateStatus status;

  const CreateTripUpdateEvent({
    required this.tripId,
    required this.description,
    required this.image,
    required this.latitude,
    required this.longitude,
    required this.status
  });

  @override
  List<Object?> get props => [tripId, description, image, latitude, longitude, status];
}

class UpdateTripUpdateEvent extends TripUpdatesEvent {
  final String updateId;
  final String? description;
  final String? image;
  final String? latitude;
  final String? longitude;
  final TripUpdateStatus? status;

  const UpdateTripUpdateEvent({
    required this.updateId,
    this.description,
    this.image,
    this.latitude,
    this.longitude,
    this.status,
  });

  @override
  List<Object?> get props => [updateId, description, image, latitude, longitude, status];
}

class DeleteTripUpdateEvent extends TripUpdatesEvent {
  final String updateId;
  
  const DeleteTripUpdateEvent(this.updateId);
  
  @override
  List<Object?> get props => [updateId];
}

class DeleteAllTripUpdatesEvent extends TripUpdatesEvent {
  const DeleteAllTripUpdatesEvent();
  
  @override
  List<Object?> get props => [];
}
