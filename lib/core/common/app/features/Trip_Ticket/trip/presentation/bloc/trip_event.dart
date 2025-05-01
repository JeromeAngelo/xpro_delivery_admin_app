import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/trip/domain/entity/trip_entity.dart';
import 'package:equatable/equatable.dart';

abstract class TripEvent extends Equatable {
  const TripEvent();
}

class GetAllTripTicketsEvent extends TripEvent {
  const GetAllTripTicketsEvent();
  
  @override
  List<Object?> get props => [];
}

class CreateTripTicketEvent extends TripEvent {
  final TripEntity trip;
  
  const CreateTripTicketEvent(this.trip);
  
  @override
  List<Object?> get props => [trip];
}

class SearchTripTicketsEvent extends TripEvent {
  final String? tripNumberId;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool? isAccepted;
  final bool? isEndTrip;
  final String? deliveryTeamId;
  final String? vehicleId;
  final String? personnelId;

  const SearchTripTicketsEvent({
    this.tripNumberId,
    this.startDate,
    this.endDate,
    this.isAccepted,
    this.isEndTrip,
    this.deliveryTeamId,
    this.vehicleId,
    this.personnelId,
  });

  @override
  List<Object?> get props => [
    tripNumberId,
    startDate,
    endDate,
    isAccepted,
    isEndTrip,
    deliveryTeamId,
    vehicleId,
    personnelId,
  ];
}

class GetTripTicketByIdEvent extends TripEvent {
  final String tripId;
  
  const GetTripTicketByIdEvent(this.tripId);
  
  @override
  List<Object?> get props => [tripId];
}

class UpdateTripTicketEvent extends TripEvent {
  final TripEntity trip;
  
  const UpdateTripTicketEvent(this.trip);
  
  @override
  List<Object?> get props => [trip];
}

class DeleteTripTicketEvent extends TripEvent {
  final String tripId;
  
  const DeleteTripTicketEvent(this.tripId);
  
  @override
  List<Object?> get props => [tripId];
}

class DeleteAllTripTicketsEvent extends TripEvent {
  const DeleteAllTripTicketsEvent();
  
  @override
  List<Object?> get props => [];
}
