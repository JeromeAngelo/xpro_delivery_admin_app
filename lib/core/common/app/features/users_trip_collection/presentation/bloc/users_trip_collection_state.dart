import 'package:equatable/equatable.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/users_trip_collection/domain/entity/user_trip_collection_entity.dart';

abstract class UsersTripCollectionState extends Equatable {
  const UsersTripCollectionState();

  @override
  List<Object?> get props => [];
}

class UsersTripCollectionInitial extends UsersTripCollectionState {
  const UsersTripCollectionInitial();
}

class UsersTripCollectionLoading extends UsersTripCollectionState {
  const UsersTripCollectionLoading();
}

class UsersTripCollectionsLoaded extends UsersTripCollectionState {
  final List<UserTripCollectionEntity> tripCollections;

  const UsersTripCollectionsLoaded(this.tripCollections);

  @override
  List<Object?> get props => [tripCollections];
}

class UsersTripCollectionError extends UsersTripCollectionState {
  final String message;

  const UsersTripCollectionError(this.message);

  @override
  List<Object?> get props => [message];
}

class UsersTripCollectionStreamStarted extends UsersTripCollectionState {
  const UsersTripCollectionStreamStarted();
}

class UsersTripCollectionStreamError extends UsersTripCollectionState {
  final String message;

  const UsersTripCollectionStreamError(this.message);

  @override
  List<Object?> get props => [message];
}

class UsersTripCollectionStreamEnded extends UsersTripCollectionState {
  const UsersTripCollectionStreamEnded();
}
