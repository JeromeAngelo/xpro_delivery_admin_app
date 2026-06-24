import 'package:equatable/equatable.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/vehicle/vehicle_tags/domain/entity/vehicle_tag_entity.dart';
import 'package:xpro_delivery_admin_app/core/enums/vehicle_status.dart';

class DeliveryVehicleEntity extends Equatable {
  int dbId = 0;

  String? id;
  String? collectionId;
  String? collectionName;

  // Vehicle information fields
  String? name;
  String? plateNo;
  String? make;
  String? type;
  String? wheels;

  // Capacity fields
  double? volumeCapacity;
  double? weightCapacity;

  // Assignment / status fields
  bool? isAssignedTrip;
  VehicleStatus? status;

  // Relations
  List<VehicleTagEntity>? vehicleTags;

  // Timestamps
  DateTime? created;
  DateTime? updated;

  DeliveryVehicleEntity({
    this.id,
    this.collectionId,
    this.collectionName,
    this.name,
    this.plateNo,
    this.make,
    this.type,
    this.wheels,
    this.volumeCapacity,
    this.weightCapacity,
    this.isAssignedTrip,
    this.status,
    this.vehicleTags,
    this.created,
    this.updated,
  });

  @override
  List<Object?> get props => [
    id,
    collectionId,
    collectionName,
    name,
    plateNo,
    make,
    type,
    wheels,
    volumeCapacity,
    weightCapacity,
    isAssignedTrip,
    status,
    vehicleTags,
    created,
    updated,
  ];
}
