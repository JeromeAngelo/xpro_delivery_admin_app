import 'dart:math';

import 'package:xpro_delivery_admin_app/core/common/app/features/Delivery_Team/delivery_team/data/models/delivery_team_model.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/trip/data/models/trip_models.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/general_auth/domain/entity/users_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/users_roles/data/model/user_role_model.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/users_trip_collection/data/models/users_trip_collection_model.dart';
import 'package:xpro_delivery_admin_app/core/enums/user_status_enum.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';
import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';

class GeneralUserModel extends GeneralUserEntity {
  String? tripId;
  String? deliveryTeamId;
  String? roleId;
  List<String>? tripCollectionIds;

  GeneralUserModel({
    super.id,
    super.collectionId,
    super.collectionName,
    super.email,
    super.profilePic,
    super.name,
    super.status,
    super.hasTrip,
    super.tripNumberId,
    super.password,
    super.passwordConfirm,
    super.created,
    super.updated,
    DeliveryTeamModel? deliveryTeamModel,
    TripModel? tripModel,
    UserRoleModel? roleModel,
    List<UserTripCollectionModel>? tripCollectionModels,
    super.token,
    this.tripId,
    this.deliveryTeamId,
    String? roleId,
    this.tripCollectionIds,
  }) : 
    roleId = roleId ?? roleModel?.id,  // Set roleId from roleModel if not provided
    super(
      deliveryTeam: deliveryTeamModel, 
      trip: tripModel, 
      role: roleModel,
      trip_collection: tripCollectionModels,
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

    // Handle trip collection data
    final tripCollectionData = expandedData?['trip_collection'];
    List<UserTripCollectionModel> tripCollectionModels = [];
    List<String> tripCollectionIds = [];
    
    if (tripCollectionData != null) {
      if (tripCollectionData is List) {
        tripCollectionModels = tripCollectionData.map((collection) {
          if (collection is RecordModel) {
            return UserTripCollectionModel.fromJson({
              'id': collection.id,
              'collectionId': collection.collectionId,
              'collectionName': collection.collectionName,
              ...collection.data,
              'expand': collection.expand,
            });
          } else if (collection is Map<String, dynamic>) {
            return UserTripCollectionModel.fromJson(collection);
          } else {
            // If it's just an ID string
            tripCollectionIds.add(collection.toString());
            return UserTripCollectionModel(id: collection.toString());
          }
        }).toList();
      } else if (json['trip_collection'] is List) {
        // If trip_collection is in the main JSON object as a list of IDs
        tripCollectionIds = (json['trip_collection'] as List)
            .map((id) => id.toString())
            .toList();
      }
    }

    // Get token from tokenKey field
    final token = json['tokenKey']?.toString();

    // Determine hasTrip value based on trip data
    final bool hasTrip = json['hasTrip'] as bool? ?? 
                         tripModel != null || 
                         (json['trip'] != null && json['trip'].toString().isNotEmpty);

    // Parse created and updated dates
    DateTime? created;
    if (json['created'] != null) {
      try {
        created = DateTime.parse(json['created'].toString());
      } catch (e) {
        debugPrint('⚠️ Error parsing created date: $e');
      }
    }

    DateTime? updated;
    if (json['updated'] != null) {
      try {
        updated = DateTime.parse(json['updated'].toString());
      } catch (e) {
        debugPrint('⚠️ Error parsing updated date: $e');
      }
    }

    debugPrint('📊 Mapped data summary:');
    debugPrint('ID: ${json['id']}');
    debugPrint('Name: ${json['name']}');
    debugPrint('Trip Number: ${json['tripNumberId']}');
    debugPrint('Has Trip: $hasTrip');
    debugPrint('Trip ID: ${tripModel?.id}');
    debugPrint('Delivery Team ID: ${deliveryTeamModel?.id}');
    debugPrint('Role ID: ${roleModel?.id}');
    debugPrint('Trip Collection Count: ${tripCollectionModels.length}');
    debugPrint('Created: ${created?.toIso8601String() ?? 'null'}');
    debugPrint('Updated: ${updated?.toIso8601String() ?? 'null'}');
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
      status: UserStatusEnum.values.firstWhere(
        (e) => e.name == (json['status'] ?? 'suspended'),
        orElse: () => UserStatusEnum.suspended,
      ),
      tripNumberId: json['tripNumberId']?.toString(),
      password: json['password']?.toString(),
      passwordConfirm: json['passwordConfirm']?.toString(),
      hasTrip: hasTrip,
      created: created,
      updated: updated,
      deliveryTeamModel: deliveryTeamModel,
      tripModel: tripModel,
      roleModel: roleModel,
      tripCollectionModels: tripCollectionModels,
      tripId: tripModel?.id,
      deliveryTeamId: deliveryTeamModel?.id,
      roleId: roleModel?.id,
      tripCollectionIds: tripCollectionIds.isEmpty ? null : tripCollectionIds,
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
    'user_role': roleId ?? (role as UserRoleModel?)?.id,
    'deliveryTeam': deliveryTeamId,
    'trip': tripId,
    'trip_collection': tripCollectionIds ?? trip_collection.map((tc) => tc.id).toList(),
    'token': token,
    'password': password,
    'passwordConfirm': passwordConfirm,
    'status': status?.toString().split('.').last,
    'hasTrip': hasTrip,
    'created': created?.toIso8601String(),
    'updated': updated?.toIso8601String(),
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
    String? password,
    String? passwordConfirm,
    DeliveryTeamModel? deliveryTeamModel,
    TripModel? tripModel,
    UserRoleModel? roleModel,
    List<UserTripCollectionModel>? tripCollectionModels,
    UserStatusEnum? status,
    bool? hasTrip,
    DateTime? created,
    DateTime? updated,
    String? tripId,
    String? deliveryTeamId,
    String? roleId,
    List<String>? tripCollectionIds,
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
      password: password ?? this.password,
      passwordConfirm: passwordConfirm ?? this.passwordConfirm,
      status: status ?? this.status,
      hasTrip: hasTrip ?? this.hasTrip,
      created: created ?? this.created,
      updated: updated ?? this.updated,
      deliveryTeamModel: deliveryTeamModel ?? deliveryTeam,
      tripModel: tripModel ?? trip,
      roleModel: roleModel ?? role as UserRoleModel?,
      tripCollectionModels: tripCollectionModels ?? trip_collection.map((tc) => tc as UserTripCollectionModel).toList(),
      tripId: tripId ?? this.tripId,
      deliveryTeamId: deliveryTeamId ?? this.deliveryTeamId,
      roleId: roleId ?? this.roleId,
      tripCollectionIds: tripCollectionIds ?? this.tripCollectionIds,
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
      password: entity.password,
      passwordConfirm: entity.passwordConfirm,
      hasTrip: entity.hasTrip,
      created: entity.created,
      updated: entity.updated,
      deliveryTeamModel: entity.deliveryTeam,
      tripModel: entity.trip,
      roleModel: entity.role as UserRoleModel?,
      tripCollectionModels: entity.trip_collection.map((tc) => tc as UserTripCollectionModel).toList(),
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
      password: '',
      passwordConfirm: '',
      hasTrip: false,
      created: null,
      updated: null,
      token: '',
    );
  }
}

