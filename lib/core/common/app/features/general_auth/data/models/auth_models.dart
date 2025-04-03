import 'package:desktop_app/core/common/app/features/Delivery_Team/delivery_team/data/models/delivery_team_model.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/trip/data/models/trip_models.dart';
import 'package:desktop_app/core/common/app/features/general_auth/domain/entity/users_entity.dart';
import 'package:desktop_app/core/common/app/features/users_roles/model/user_role_model.dart';
import 'package:desktop_app/core/typedefs/typedefs.dart';
import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';

class GeneralUserModel extends GeneralUserEntity {
  String? tripId;
  String? deliveryTeamId;
  String? roleId;

  GeneralUserModel({
    super.id,
    super.collectionId,
    super.collectionName,
    super.email,
    super.profilePic,
    super.name,
    super.tripNumberId,
    DeliveryTeamModel? deliveryTeamModel,
    TripModel? tripModel,
    UserRoleModel? roleModel,
    super.token,
    this.tripId,
    this.deliveryTeamId,
    this.roleId,
  }) : super(
          deliveryTeam: deliveryTeamModel,
          trip: tripModel,
          role: roleModel,
        );

  factory GeneralUserModel.fromJson(DataMap json) {
    debugPrint('🔄 Creating GeneralUserModel from JSON');
    final expandedData = json['expand'] as Map<String, dynamic>?;

    // Handle trip data
    final tripData = expandedData?['trip'];
    TripModel? tripModel;
    if (tripData != null) {
      if (tripData is RecordModel) {
        tripModel = TripModel.fromJson({
          'id': tripData.id,
          'collectionId': tripData.collectionId,
          'collectionName': tripData.collectionName,
          ...tripData.data,
        });
      } else if (tripData is Map<String, dynamic>) {
        tripModel = TripModel.fromJson(tripData);
      }
    }

    // Handle delivery team data
    final deliveryTeamData = expandedData?['deliveryTeam'];
    DeliveryTeamModel? deliveryTeamModel;
    if (deliveryTeamData != null) {
      if (deliveryTeamData is RecordModel) {
        deliveryTeamModel = DeliveryTeamModel.fromJson({
          'id': deliveryTeamData.id,
          'collectionId': deliveryTeamData.collectionId,
          'collectionName': deliveryTeamData.collectionName,
          ...deliveryTeamData.data,
        });
      } else if (deliveryTeamData is Map<String, dynamic>) {
        deliveryTeamModel = DeliveryTeamModel.fromJson(deliveryTeamData);
      }
    }

    // Handle user role data
    final roleData = expandedData?['user_role'];
    UserRoleModel? roleModel;
    if (roleData != null) {
      if (roleData is RecordModel) {
        roleModel = UserRoleModel.fromJson({
          'id': roleData.id,
          'name': roleData.data['name'],
          'permissions': roleData.data['permissions'],
        });
      } else if (roleData is Map<String, dynamic>) {
        roleModel = UserRoleModel.fromJson(roleData);
      } else if (roleData is List && roleData.isNotEmpty) {
        final firstRole = roleData.first;
        if (firstRole is RecordModel) {
          roleModel = UserRoleModel.fromJson({
            'id': firstRole.id,
            'name': firstRole.data['name'],
            'permissions': firstRole.data['permissions'],
          });
        } else if (firstRole is Map<String, dynamic>) {
          roleModel = UserRoleModel.fromJson(firstRole);
        }
      }
    }

    // Get token from tokenKey field
    final token = json['tokenKey']?.toString();

    debugPrint('📊 Mapped data summary:');
    debugPrint('ID: ${json['id']}');
    debugPrint('Name: ${json['name']}');
    debugPrint('Trip Number: ${json['tripNumberId']}');
    debugPrint('Trip ID: ${tripModel?.id}');
    debugPrint('Delivery Team ID: ${deliveryTeamModel?.id}');
    debugPrint('Role ID: ${roleModel?.id}');
    debugPrint(
      'Token: ${token != null ? token.substring(0, min(10, token.length)) : "null"}...',
    );

    return GeneralUserModel(
      id: json['id']?.toString(),
      collectionId: json['collectionId']?.toString(),
      collectionName: json['collectionName']?.toString(),
      email: json['email']?.toString(),
      profilePic: json['profilePic']?.toString(),
      name: json['name']?.toString(),
      
      tripNumberId: json['tripNumberId']?.toString(),
      deliveryTeamModel: deliveryTeamModel,
      tripModel: tripModel,
      roleModel: roleModel,
      tripId: tripModel?.id,
      deliveryTeamId: deliveryTeamModel?.id,
      roleId: roleModel?.id,
      token: token,
    );
  }

  DataMap toJson() {
    return {
      'id': id,
      'collectionId': collectionId,
      'collectionName': collectionName,
      'email': email,
      'profilePic': profilePic,
      'name': name,
      'tripNumberId': tripNumberId,
      'user_role': roleId, // Use the field name expected by PocketBase
      'deliveryTeam': deliveryTeamId,
      'trip': tripId,
      'token': token,
    };
  }

  GeneralUserModel copyWith({
    String? id,
    String? collectionId,
    String? collectionName,
    String? email,
    String? profilePic,
    String? name,
    String? tripNumberId,
    DeliveryTeamModel? deliveryTeamModel,
    TripModel? tripModel,
    UserRoleModel? roleModel,
    String? tripId,
    String? deliveryTeamId,
    String? roleId,
    String? token,
  }) {
    return GeneralUserModel(
      id: id ?? this.id,
      collectionId: collectionId ?? this.collectionId,
      collectionName: collectionName ?? this.collectionName,
      email: email ?? this.email,
      profilePic: profilePic ?? this.profilePic,
      name: name ?? this.name,
      tripNumberId: tripNumberId ?? this.tripNumberId,
      deliveryTeamModel: deliveryTeamModel ?? deliveryTeam,
      tripModel: tripModel ?? trip,
      roleModel: roleModel ?? role as UserRoleModel?,
      tripId: tripId ?? this.tripId,
      deliveryTeamId: deliveryTeamId ?? this.deliveryTeamId,
      roleId: roleId ?? this.roleId,
      token: token ?? this.token,
    );
  }

  factory GeneralUserModel.fromEntity(GeneralUserEntity entity) {
    return GeneralUserModel(
      id: entity.id,
      collectionId: entity.collectionId,
      collectionName: entity.collectionName,
      email: entity.email,
      profilePic: entity.profilePic,
      name: entity.name,
      tripNumberId: entity.tripNumberId,
      deliveryTeamModel: entity.deliveryTeam,
      tripModel: entity.trip,
      roleModel: entity.role as UserRoleModel?,
      token: entity.token,
    );
  }

  factory GeneralUserModel.empty() {
    return GeneralUserModel(
      id: '',
      collectionId: '',
      collectionName: '',
      email: '',
      profilePic: '',
      name: '',
      tripNumberId: '',
      token: '',
    );
  }
}

// Helper function to avoid potential errors with substring
int min(int a, int b) {
  return a < b ? a : b;
}
