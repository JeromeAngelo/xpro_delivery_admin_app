import 'package:xpro_delivery_admin_app/core/common/app/features/Delivery_Team/delivery_team/data/models/delivery_team_model.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/trip/data/models/trip_models.dart';
import 'package:xpro_delivery_admin_app/core/enums/user_role.dart';
import 'package:equatable/equatable.dart';


class PersonelEntity extends Equatable {
  final String? id;
  final String? collectionId;
  final String? collectionName;
  final String? name;
  final DeliveryTeamModel? deliveryTeam;
  final TripModel? trip;
  final UserRole? role;
  final bool? isAssigned;
  final DateTime? created;
  final DateTime? updated;

  const PersonelEntity({
    this.id,
    this.collectionId,
    this.collectionName,
    this.name,
    this.role,
    this.deliveryTeam,
    this.isAssigned,
    this.trip,
    this.created,
    this.updated,
  });

  @override
  List<Object?> get props => [
        id,
        collectionId,
        collectionName,
        name,
        role,
        deliveryTeam?.id,
        isAssigned,
        trip?.id,
        created,
        updated,
      ];
      
  factory PersonelEntity.empty() {
    return const PersonelEntity(
      id: '',
      collectionId: '',
      collectionName: '',
      name: '',
      role: UserRole.teamLeader,
      isAssigned: false,
      deliveryTeam: null,
      trip: null,
      created: null,
      updated: null,
    );
  }
  
  @override
  String toString() {
    return 'PersonelEntity(id: $id, name: $name, role: $role, deliveryTeam: ${deliveryTeam?.id}, trip: ${trip?.id}, isAssigned: $isAssigned, created: $created, updated: $updated)';
  }
}
