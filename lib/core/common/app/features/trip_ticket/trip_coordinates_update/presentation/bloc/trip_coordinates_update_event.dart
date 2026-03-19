import 'package:equatable/equatable.dart';

abstract class TripCoordinatesUpdateEvent extends Equatable {
  const TripCoordinatesUpdateEvent();
}

/// Event to get trip coordinates for a specific trip
class GetTripCoordinatesByTripIdEvent extends TripCoordinatesUpdateEvent {
  final String tripId;
  
  const GetTripCoordinatesByTripIdEvent(this.tripId);
  
  @override
  List<Object?> get props => [tripId];
}

/// Event to refresh trip coordinates for a specific trip
class RefreshTripCoordinatesEvent extends TripCoordinatesUpdateEvent {
  final String tripId;
  
  const RefreshTripCoordinatesEvent(this.tripId);
  
  @override
  List<Object?> get props => [tripId];
}

/// Event to handle errors
class TripCoordinatesErrorEvent extends TripCoordinatesUpdateEvent {
  final String message;
  
  const TripCoordinatesErrorEvent(this.message);
  
  @override
  List<Object?> get props => [message];
}
