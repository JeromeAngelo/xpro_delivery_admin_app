import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/trip_updates/domain/entity/trip_update_entity.dart';
import 'package:equatable/equatable.dart';

abstract class TripUpdatesState extends Equatable {
  const TripUpdatesState();

  @override
  List<Object> get props => [];
}

class TripUpdatesInitial extends TripUpdatesState {}

class TripUpdatesLoading extends TripUpdatesState {}

class TripUpdatesLoaded extends TripUpdatesState {
  final List<TripUpdateEntity> updates;
  
  const TripUpdatesLoaded(this.updates);
  
  @override
  List<Object> get props => [updates];
}

class AllTripUpdatesLoaded extends TripUpdatesState {
  final List<TripUpdateEntity> updates;
  
  const AllTripUpdatesLoaded(this.updates);
  
  @override
  List<Object> get props => [updates];
}

class TripUpdateCreated extends TripUpdatesState {
  final TripUpdateEntity update;
  
  const TripUpdateCreated(this.update);
  
  @override
  List<Object> get props => [update];
}

class TripUpdateUpdated extends TripUpdatesState {
  final TripUpdateEntity update;
  
  const TripUpdateUpdated(this.update);
  
  @override
  List<Object> get props => [update];
}

class TripUpdateDeleted extends TripUpdatesState {
  final String updateId;
  
  const TripUpdateDeleted(this.updateId);
  
  @override
  List<Object> get props => [updateId];
}

class AllTripUpdatesDeleted extends TripUpdatesState {}

class TripUpdatesError extends TripUpdatesState {
  final String message;
  
  const TripUpdatesError(this.message);
  
  @override
  List<Object> get props => [message];
}
