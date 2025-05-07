import 'package:xpro_delivery_admin_app/core/common/app/features/Delivery_Team/delivery_team/data/models/delivery_team_model.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/trip/data/models/trip_models.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/users_roles/domain/entity/user_role_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/users_trip_collection/domain/entity/user_trip_collection_entity.dart';
import 'package:equatable/equatable.dart';
import 'package:xpro_delivery_admin_app/core/enums/user_status_enum.dart';

class GeneralUserEntity extends Equatable {
  final String? id;
  final String? collectionId;
  final String? collectionName;
  final String? email;
  final String? profilePic;
  final String? name;
  final String? tripNumberId;
  final String? token;
  final String? password; // Password field
  final String? passwordConfirm; // Add passwordConfirm field
  UserStatusEnum? status;
  final DeliveryTeamModel? deliveryTeam;
  final TripModel? trip;
  final UserRoleEntity? role;
  final List<UserTripCollectionEntity> trip_collection;
  final bool? hasTrip;
  final DateTime? created;
  final DateTime? updated;

  GeneralUserEntity({
    this.id,
    this.collectionId,
    this.collectionName,
    this.email,
    this.profilePic,
    this.name,
    this.tripNumberId,
    this.hasTrip,
    this.token,
    this.password,
    this.passwordConfirm, // Add passwordConfirm parameter
    this.deliveryTeam,
    this.trip,
    this.status,
    this.role,
    this.created,
    this.updated,
    List<UserTripCollectionEntity>? trip_collection,
  }) : trip_collection = trip_collection ?? const [];

  GeneralUserEntity.empty()
    : id = '',
      collectionId = '',
      collectionName = '',
      email = '',
      profilePic = '',
      token = '',
      name = '',
      tripNumberId = '',
      password = '',
      passwordConfirm = '', // Initialize passwordConfirm as empty
      status = UserStatusEnum.suspended,
      deliveryTeam = null,
      trip = null,
      role = null,
      hasTrip = false,
      created = null,
      updated = null,
      trip_collection = const [];

  @override
  List<Object?> get props => [
    id,
    collectionId,
    collectionName,
    email,
    profilePic,
    name,
    tripNumberId,
    deliveryTeam?.id,
    status,
    trip?.id,
    token,
    password,
    passwordConfirm, // Add passwordConfirm to props
    role?.id,
    trip_collection,
  ];

  @override
  String toString() {
    return 'GeneralUserEntity(id: $id, name: $name, hasTrip: $hasTrip, email: $email, tripNumberId: $tripNumberId, role: ${role?.name}), status: ${status?.name}, trip_collection: ${trip_collection.length}';
  }
}
