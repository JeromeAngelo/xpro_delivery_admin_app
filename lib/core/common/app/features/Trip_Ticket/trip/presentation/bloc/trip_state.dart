import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/trip/domain/entity/trip_entity.dart';
import 'package:equatable/equatable.dart';

abstract class TripState extends Equatable {
  const TripState();

  @override
  List<Object?> get props => [];
}

class TripInitial extends TripState {}

class TripLoading extends TripState {}

class AllTripTicketsLoaded extends TripState {
  final List<TripEntity> trips;
  
  const AllTripTicketsLoaded(this.trips);
  
  @override
  List<Object?> get props => [trips];
}

class TripTicketCreated extends TripState {
  final TripEntity trip;
  
  const TripTicketCreated(this.trip);
  
  @override
  List<Object?> get props => [trip];
}

class TripTicketsSearchResults extends TripState {
  final List<TripEntity> trips;
  
  const TripTicketsSearchResults(this.trips);
  
  @override
  List<Object?> get props => [trips];
}

class TripTicketLoaded extends TripState {
  final TripEntity trip;
  
  const TripTicketLoaded(this.trip);
  
  @override
  List<Object?> get props => [trip];
}

class TripTicketUpdated extends TripState {
  final TripEntity trip;
  
  const TripTicketUpdated(this.trip);
  
  @override
  List<Object?> get props => [trip];
}

class TripTicketDeleted extends TripState {
  final String tripId;
  
  const TripTicketDeleted(this.tripId);
  
  @override
  List<Object?> get props => [tripId];
}

class AllTripTicketsDeleted extends TripState {}

class TripError extends TripState {
  final String message;
  
  const TripError(this.message);
  
  @override
  List<Object?> get props => [message];
}
