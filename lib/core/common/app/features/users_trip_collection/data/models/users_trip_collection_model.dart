import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/trip/data/models/trip_models.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/general_auth/data/models/auth_models.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/users_trip_collection/domain/entity/user_trip_collection_entity.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';
import 'package:pocketbase/pocketbase.dart';

class UserTripCollectionModel extends UserTripCollectionEntity {
  int objectBoxId = 0;
  String pocketbaseId;
  String? userId;

  UserTripCollectionModel({
    super.id,
    super.collectionId,
    super.collectionName,
    super.user,
    super.trips,
    super.isActive,
    super.created,
    super.updated,
    this.userId,
    this.objectBoxId = 0,
  }) : pocketbaseId = id ?? '';

  factory UserTripCollectionModel.fromJson(Map<String, dynamic> json) {
    final expandedData = json['expand'] as Map<String, dynamic>?;

    // Add safe date parsing
    DateTime? parseDate(dynamic value) {
      if (value == null || value.toString().isEmpty) return null;
      try {
        return DateTime.parse(value.toString());
      } catch (_) {
        return null;
      }
    }

    // Handle user data
    final userData = expandedData?['user'];
    GeneralUserModel? userModel;

    if (userData != null) {
      if (userData is RecordModel) {
        userModel = GeneralUserModel.fromJson({
          'id': userData.id,
          'collectionId': userData.collectionId,
          'collectionName': userData.collectionName,
          ...userData.data,
        });
      } else if (userData is List && userData.isNotEmpty) {
        final firstUser = userData.first as RecordModel;
        userModel = GeneralUserModel.fromJson({
          'id': firstUser.id,
          'collectionId': firstUser.collectionId,
          'collectionName': firstUser.collectionName,
          ...firstUser.data,
        });
      } else if (userData is Map) {
        userModel = GeneralUserModel.fromJson(userData as Map<String, dynamic>);
      }
    }

    // Handle trips data
    final tripsData = expandedData?['trips'] as List?;
    List<TripModel> tripsList = [];
    
    if (tripsData != null) {
      tripsList = tripsData.map((trip) {
        if (trip is RecordModel) {
          return TripModel.fromJson({
            'id': trip.id,
            'collectionId': trip.collectionId,
            'collectionName': trip.collectionName,
            ...trip.data,
          });
        } else if (trip is Map<String, dynamic>) {
          return TripModel.fromJson(trip);
        } else {
          // Handle case where trip is just an ID string
          return TripModel(id: trip.toString());
        }
      }).toList();
    }

    return UserTripCollectionModel(
      id: json['id']?.toString(),
      collectionId: json['collectionId']?.toString(),
      collectionName: json['collectionName']?.toString(),
      user: userModel,
      trips: tripsList,
      isActive: json['isActive'] as bool? ?? false,
      created: parseDate(json['created']),
      updated: parseDate(json['updated']),
      userId: userModel?.id,
    );
  }

  DataMap toJson() {
    return {
      'id': pocketbaseId,
      'collectionId': collectionId,
      'collectionName': collectionName,
      'user': userId ?? user?.id,
      'trips': trips.map((trip) => trip.id).toList(),
      'isActive': isActive ?? false,
      'created': created?.toIso8601String(),
      'updated': updated?.toIso8601String(),
    };
  }

  UserTripCollectionModel copyWith({
    String? id,
    String? collectionId,
    String? collectionName,
    GeneralUserModel? user,
    List<TripModel>? trips,
    bool? isActive,
    DateTime? created,
    DateTime? updated,
    String? userId,
  }) {
    return UserTripCollectionModel(
      id: id ?? this.id,
      collectionId: collectionId ?? this.collectionId,
      collectionName: collectionName ?? this.collectionName,
      user: user ?? this.user as GeneralUserModel?,
      trips: trips ?? this.trips.map((e) => e as TripModel).toList(),
      isActive: isActive ?? this.isActive,
      created: created ?? this.created,
      updated: updated ?? this.updated,
      userId: userId ?? this.userId,
      objectBoxId: objectBoxId,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserTripCollectionModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
