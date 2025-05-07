import 'package:equatable/equatable.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/trip/domain/entity/trip_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/general_auth/domain/entity/users_entity.dart';

class UserTripCollectionEntity extends Equatable {
  final String? id;
  final String? collectionId;
  final String? collectionName;
  final GeneralUserEntity? user;
  final List<TripEntity> trips;
  final bool? isActive;
  final DateTime? created;
  final DateTime? updated;

  const UserTripCollectionEntity({
    this.id,
    this.collectionId,
    this.collectionName,
    this.user,
    List<TripEntity>? trips,
    this.isActive,
    this.created,
    this.updated,
  }) : trips = trips ?? const [];

  @override
  List<Object?> get props => [
        id,
        collectionId,
        collectionName,
        user?.id,
        trips,
        isActive,
        created,
        updated,
      ];

  @override
  String toString() {
    return 'UserTripCollectionEntity(id: $id, user: ${user?.name}, trips: ${trips.length}, isActive: $isActive)';
  }
}
