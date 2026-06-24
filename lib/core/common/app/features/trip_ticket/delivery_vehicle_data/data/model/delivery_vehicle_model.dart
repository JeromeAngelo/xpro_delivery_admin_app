import 'package:pocketbase/pocketbase.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/trip_ticket/delivery_vehicle_data/domain/enitity/delivery_vehicle_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/vehicle/vehicle_tags/data/model/vehicle_tag_model.dart';
import 'package:xpro_delivery_admin_app/core/enums/vehicle_status.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';

class DeliveryVehicleModel extends DeliveryVehicleEntity {
  DeliveryVehicleModel({
    super.id,
    super.collectionId,
    super.collectionName,
    super.name,
    super.plateNo,
    super.make,
    super.type,
    super.wheels,
    super.volumeCapacity,
    super.weightCapacity,
    super.isAssignedTrip,
    super.status,
    super.vehicleTags,
    super.created,
    super.updated,
  });

  // Factory constructor to create a model from JSON data
  factory DeliveryVehicleModel.fromJson(DataMap json) {
    final expandedData = json['expand'] as Map<String, dynamic>?;

    List<VehicleTagModel>? vehicleTags;
    final tagsData = expandedData?['vehicleTags'] ?? json['vehicleTags'];
    if (tagsData != null) {
      if (tagsData is List) {
        vehicleTags =
            tagsData
                .map((tag) {
                  if (tag is RecordModel) {
                    return VehicleTagModel.fromJson({
                      'id': tag.id,
                      'collectionId': tag.collectionId,
                      'collectionName': tag.collectionName,
                      ...tag.data,
                    });
                  } else if (tag is Map) {
                    return VehicleTagModel.fromJson(
                      tag as Map<String, dynamic>,
                    );
                  }
                  return null;
                })
                .whereType<VehicleTagModel>()
                .toList();
      }
    }

    return DeliveryVehicleModel(
      id: json['id']?.toString(),
      collectionId: json['collectionId']?.toString(),
      collectionName: json['collectionName']?.toString(),
      name: json['name']?.toString(),
      plateNo: json['plateNo']?.toString() ?? json['plate_no']?.toString(),
      make: json['make']?.toString(),
      type: json['type']?.toString(),
      wheels: json['wheels']?.toString(),
      volumeCapacity:
          json['volumeCapacity'] != null
              ? double.tryParse(json['volumeCapacity'].toString())
              : null,
      weightCapacity:
          json['weightCapacity'] != null
              ? double.tryParse(json['weightCapacity'].toString())
              : null,
      isAssignedTrip: json['isAssignedTrip'] as bool?,
      status: _parseStatus(json['status']),
      vehicleTags: vehicleTags,
      created:
          json['created'] != null
              ? DateTime.parse(json['created'].toString())
              : null,
      updated:
          json['updated'] != null
              ? DateTime.parse(json['updated'].toString())
              : null,
    );
  }

  static VehicleStatus? _parseStatus(dynamic value) {
    if (value == null) return null;
    final raw = value.toString();
    return VehicleStatus.values.firstWhere(
      (s) => s.name == raw,
      orElse: () => VehicleStatus.goodCondition,
    );
  }

  // Method to convert model to JSON
  DataMap toJson() {
    return {
      'id': id,
      'collectionId': collectionId,
      'collectionName': collectionName,
      'name': name,
      'plateNo': plateNo,
      'make': make,
      'type': type,
      'wheels': wheels,
      'volumeCapacity': volumeCapacity,
      'weightCapacity': weightCapacity,
      'isAssignedTrip': isAssignedTrip,
      'status': status?.name,
      'vehicleTags':
          vehicleTags?.map((tag) => tag.id).whereType<String>().toList(),
      'created': created?.toIso8601String(),
      'updated': updated?.toIso8601String(),
    };
  }

  // Create a copy of this model with given fields replaced with new values
  DeliveryVehicleModel copyWith({
    String? id,
    String? collectionId,
    String? collectionName,
    String? name,
    String? plateNo,
    String? make,
    String? type,
    String? wheels,
    double? volumeCapacity,
    double? weightCapacity,
    bool? isAssignedTrip,
    VehicleStatus? status,
    List<VehicleTagModel>? vehicleTags,
    DateTime? created,
    DateTime? updated,
  }) {
    return DeliveryVehicleModel(
      id: id ?? this.id,
      collectionId: collectionId ?? this.collectionId,
      collectionName: collectionName ?? this.collectionName,
      name: name ?? this.name,
      plateNo: plateNo ?? this.plateNo,
      make: make ?? this.make,
      type: type ?? this.type,
      wheels: wheels ?? this.wheels,
      volumeCapacity: volumeCapacity ?? this.volumeCapacity,
      weightCapacity: weightCapacity ?? this.weightCapacity,
      isAssignedTrip: isAssignedTrip ?? this.isAssignedTrip,
      status: status ?? this.status,
      vehicleTags: vehicleTags ?? this.vehicleTags,
      created: created ?? this.created,
      updated: updated ?? this.updated,
    );
  }

  factory DeliveryVehicleModel.fromEntity(DeliveryVehicleEntity entity) {
    return DeliveryVehicleModel(
      id: entity.id,
      collectionId: entity.collectionId,
      collectionName: entity.collectionName,
      name: entity.name,
      plateNo: entity.plateNo,
      make: entity.make,
      type: entity.type,
      wheels: entity.wheels,
      volumeCapacity: entity.volumeCapacity,
      weightCapacity: entity.weightCapacity,
      isAssignedTrip: entity.isAssignedTrip,
      status: entity.status,
      vehicleTags: entity.vehicleTags?.map(VehicleTagModel.fromEntity).toList(),
      created: entity.created,
      updated: entity.updated,
    );
  }

  factory DeliveryVehicleModel.empty() {
    return DeliveryVehicleModel(
      id: '',
      collectionId: '',
      collectionName: '',
      name: '',
      plateNo: '',
      make: '',
      type: '',
      wheels: '',
      volumeCapacity: null,
      weightCapacity: null,
      isAssignedTrip: false,
      status: VehicleStatus.goodCondition,
      vehicleTags: [],
      created: null,
      updated: null,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DeliveryVehicleModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
