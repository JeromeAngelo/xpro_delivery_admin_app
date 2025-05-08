import 'package:equatable/equatable.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/trip_coordinates_update/domain/entity/trip_coordinates_entity.dart';

abstract class TripCoordinatesUpdateState extends Equatable {
  const TripCoordinatesUpdateState();

  @override
  List<Object> get props => [];
}

/// Initial state
class TripCoordinatesUpdateInitial extends TripCoordinatesUpdateState {}

/// Loading state
class TripCoordinatesUpdateLoading extends TripCoordinatesUpdateState {}

/// State when trip coordinates are loaded successfully
class TripCoordinatesUpdateLoaded extends TripCoordinatesUpdateState {
  final List<TripCoordinatesEntity> coordinates;
  
  const TripCoordinatesUpdateLoaded(this.coordinates);
  
  @override
  List<Object> get props => [coordinates];
}

/// State when refreshing trip coordinates
class TripCoordinatesUpdateRefreshing extends TripCoordinatesUpdateState {}

/// State when an error occurs
class TripCoordinatesUpdateError extends TripCoordinatesUpdateState {
  final String message;
  
  const TripCoordinatesUpdateError(this.message);
  
  @override
  List<Object> get props => [message];
}

/// State when no coordinates are found
class TripCoordinatesUpdateEmpty extends TripCoordinatesUpdateState {}
