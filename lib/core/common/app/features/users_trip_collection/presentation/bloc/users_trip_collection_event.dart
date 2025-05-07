import 'package:equatable/equatable.dart';

abstract class UsersTripCollectionEvent extends Equatable {
  const UsersTripCollectionEvent();

  @override
  List<Object?> get props => [];
}

class GetUserTripCollectionsEvent extends UsersTripCollectionEvent {
  final String userId;

  const GetUserTripCollectionsEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}

class WatchUserTripCollectionsEvent extends UsersTripCollectionEvent {
  final String userId;

  const WatchUserTripCollectionsEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}

class ClearUserTripCollectionsEvent extends UsersTripCollectionEvent {
  const ClearUserTripCollectionsEvent();
}
