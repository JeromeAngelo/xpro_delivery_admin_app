import 'package:xpro_delivery_admin_app/core/common/app/features/Delivery_Team/delivery_team/data/models/delivery_team_model.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/trip/data/models/trip_models.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/users_roles/entity/user_role_entity.dart';
import 'package:equatable/equatable.dart';

class GeneralUserEntity extends Equatable {
  final String? id;
  final String? collectionId;
  final String? collectionName;
  final String? email;
  final String? profilePic;
  final String? name;
  final String? tripNumberId;
  final String? token;
  final DeliveryTeamModel? deliveryTeam;
  final TripModel? trip;
  final UserRoleEntity? role; // Added relationship with UserRoleEntity

  const GeneralUserEntity({
    this.id,
    this.collectionId,
    this.collectionName,
    this.email,
    this.profilePic,
    this.name,
    this.tripNumberId,
    this.token,
    this.deliveryTeam,
    this.trip,
    this.role, // Added role parameter
  });

  const GeneralUserEntity.empty()
      : id = '',
        collectionId = '',
        collectionName = '',
        email = '',
        profilePic = '',
        token = '',
        name = '',
        tripNumberId = '',
        deliveryTeam = null,
        trip = null,
        role = null; // Initialize role as null in empty constructor

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
        trip?.id,
        token,
        role?.id, // Add role to props for equality comparison
      ];
        
  @override
  String toString() {
    return 'GeneralUserEntity(id: $id, name: $name, email: $email, tripNumberId: $tripNumberId, role: ${role?.name})';
  }
}
