import 'package:equatable/equatable.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/trip_ticket/trip/data/models/trip_models.dart';

class TripCoordinatesEntity extends Equatable {
  String? id;
  String? collectionId;
  String? collectionName;
  final TripModel? trip;
  double? latitude;
  double? longitude;
  double? speed;
  double? accuracy;
  double? deviceBatteryLife;
  double? networkSpeed;
  DateTime? created;
  DateTime? updated;

  TripCoordinatesEntity({
    this.id,
    this.collectionId,
    this.collectionName,
    this.trip,
    this.speed,
    this.accuracy,
    this.deviceBatteryLife,
    this.networkSpeed,
    this.latitude,
    this.longitude,
    this.created,
    this.updated,
  });

  @override
  List<Object?> get props => [
    id,
    collectionId,
    collectionName,
    trip?.id,
    latitude,
    longitude,
    speed,
    accuracy,
    deviceBatteryLife,
    networkSpeed,
    created,
    updated,
  ];
}
