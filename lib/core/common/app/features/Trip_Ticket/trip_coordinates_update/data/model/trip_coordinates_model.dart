import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/trip/data/models/trip_models.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/trip_coordinates_update/domain/entity/trip_coordinates_entity.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';

class TripCoordinatesModel extends TripCoordinatesEntity {
  int objectBoxId = 0;
  String? tripId;

  TripCoordinatesModel({
    super.id,
    super.collectionId,
    super.collectionName,
    super.trip,
    super.latitude,
    super.longitude,
    super.created,
    super.updated,
    this.tripId,
    this.objectBoxId = 0,
  });

  factory TripCoordinatesModel.fromJson(Map<String, dynamic> json) {
    final expandedData = json['expand'] as Map<String, dynamic>?;

    // Add safe date parsing
    DateTime? parseDate(dynamic value) {
      if (value == null || value.toString().isEmpty) return null;
      
      // If value is already a DateTime, return it directly
      if (value is DateTime) {
        return value;
      }
      
      debugPrint('🔍 Model parseDate attempting to parse: "${value.toString()}" (type: ${value.runtimeType})');
      
      try {
        return DateTime.parse(value.toString());
      } catch (e) {
        debugPrint('⚠️ Model parseDate failed: $e for value: ${value.toString()}');
        return null;
      }
    }

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
      } else if (tripData is Map) {
        tripModel = TripModel.fromJson(tripData as Map<String, dynamic>);
      }
    }

    // Parse latitude and longitude
    double? latitude;
    if (json['latitude'] != null) {
      try {
        latitude = double.parse(json['latitude'].toString());
      } catch (e) {
        debugPrint('❌ Error parsing latitude: $e');
      }
    }

    double? longitude;
    if (json['longitude'] != null) {
      try {
        longitude = double.parse(json['longitude'].toString());
      } catch (e) {
        debugPrint('❌ Error parsing longitude: $e');
      }
    }

    return TripCoordinatesModel(
      id: json['id']?.toString(),
      collectionId: json['collectionId']?.toString(),
      collectionName: json['collectionName']?.toString(),
      trip: tripModel,
      latitude: latitude,
      longitude: longitude,
      created: parseDate(json['created']),
      updated: parseDate(json['updated']),
      tripId: json['trip']?.toString() ?? tripModel?.id,
    );
  }

  DataMap toJson() {
    return {
      'id': id,
      'collectionId': collectionId,
      'collectionName': collectionName,
      'trip': tripId ?? trip?.id,
      'latitude': latitude?.toString(),
      'longitude': longitude?.toString(),
      'created': created?.toIso8601String(),
      'updated': updated?.toIso8601String(),
    };
  }

  TripCoordinatesModel copyWith({
    String? id,
    String? collectionId,
    String? collectionName,
    TripModel? trip,
    double? latitude,
    double? longitude,
    DateTime? created,
    DateTime? updated,
    String? tripId,
  }) {
    return TripCoordinatesModel(
      id: id ?? this.id,
      collectionId: collectionId ?? this.collectionId,
      collectionName: collectionName ?? this.collectionName,
      trip: trip ?? this.trip,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      created: created ?? this.created,
      updated: updated ?? this.updated,
      tripId: tripId ?? this.tripId,
      objectBoxId: objectBoxId,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TripCoordinatesModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
