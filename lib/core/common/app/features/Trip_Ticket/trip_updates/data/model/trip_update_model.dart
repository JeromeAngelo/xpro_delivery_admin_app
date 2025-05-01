import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/trip/data/models/trip_models.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/trip_updates/domain/entity/trip_update_entity.dart';
import 'package:xpro_delivery_admin_app/core/enums/trip_update_status.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';
import 'package:flutter/material.dart';



class TripUpdateModel extends TripUpdateEntity {
  String pocketbaseId;
  String? tripId;

  TripUpdateModel({
    super.id,
    super.collectionId,
    super.collectionName,
    super.status,
    super.date,
    super.image,
    super.description,
    super.latitude,
    super.longitude,
    super.trip,
    this.tripId,
  }) : pocketbaseId = id ?? '';

  factory TripUpdateModel.fromJson(DataMap json) {
    debugPrint('🔄 Parsing status from JSON: ${json['status']}');
    final expandedData = json['expand'] as Map<String, dynamic>?;

    TripModel? tripModel;
    if (expandedData?['trip'] != null) {
      tripModel = TripModel.fromJson(expandedData!['trip'] as DataMap);
    }

    TripUpdateStatus parseStatus(String? statusStr) {
      if (statusStr == null) return TripUpdateStatus.none;

      // Direct enum mapping based on database values
      switch (statusStr) {
        case 'vehicleBreakdown':
          return TripUpdateStatus.vehicleBreakdown;
        case 'generalUpdate':
          return TripUpdateStatus.generalUpdate;
        case 'refuelling':
          return TripUpdateStatus.refuelling;
        case 'roadClosure':
          return TripUpdateStatus.roadClosure;
        case 'others':
          return TripUpdateStatus.others;
        default:
          debugPrint('📊 Unmatched status value: $statusStr');
          return TripUpdateStatus.none;
      }
    }

    final status = parseStatus(json['status']?.toString());
    debugPrint('🎯 Parsed status: $status from raw value: ${json['status']}');

    return TripUpdateModel(
      id: json['id']?.toString(),
      collectionId: json['collectionId']?.toString(),
      collectionName: json['collectionName']?.toString(),
      status: status,
      date: json['date'] != null
          ? DateTime.tryParse(json['date'].toString())
          : DateTime.now(),
      image: json['image']?.toString(),
      description: json['description']?.toString(),
      latitude: json['latitude']?.toString(),
      longitude: json['longitude']?.toString(),
      trip: tripModel,
      tripId: expandedData?['trip']?['id']?.toString(),
    );
  }

  DataMap toJson() {
    return {
      'id': pocketbaseId,
      'collectionId': collectionId,
      'collectionName': collectionName,
      'status': status?.toString().split('.').last,
      'date': date?.toIso8601String(),
      'image': image,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'trip': tripId ?? trip?.id,
    };
  }

  factory TripUpdateModel.initial([String? tripId]) {
    return TripUpdateModel(
      id: '',
      collectionId: '',
      collectionName: 'trip_updates',
      status: TripUpdateStatus.others,
      date: DateTime.now(),
      image: null,
      description: '',
      latitude: '',
      longitude: '',
      tripId: tripId,
    );
  }

  TripUpdateModel copyWith({
    String? id,
    String? collectionId,
    String? collectionName,
    TripUpdateStatus? status,
    DateTime? date,
    String? image,
    String? description,
    String? latitude,
    String? longitude,
    TripModel? trip,
    String? tripId,
  }) {
    return TripUpdateModel(
      id: id ?? this.id,
      collectionId: collectionId ?? this.collectionId,
      collectionName: collectionName ?? this.collectionName,
      status: status ?? this.status,
      date: date ?? this.date,
      image: image ?? this.image,
      description: description ?? this.description,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      trip: trip ?? this.trip,
      tripId: tripId ?? this.tripId,
    );
  }
}
