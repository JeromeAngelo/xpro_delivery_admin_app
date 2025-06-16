import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/delivery_vehicle_data/domain/enitity/delivery_vehicle_entity.dart';
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
    super.created,
    super.updated,
  });

  // Factory constructor to create a model from JSON data
  factory DeliveryVehicleModel.fromJson(DataMap json) {
    return DeliveryVehicleModel(
      id: json['id'],
      collectionId: json['collectionId'],
      collectionName: json['collectionName'],
      name: json['name'],
      plateNo: json['plateNo'],
      make: json['make'],
      type: json['type'],
      wheels: json['wheels'],
      volumeCapacity: json['volumeCapacity'] != null 
          ? double.tryParse(json['volumeCapacity'].toString()) 
          : null,
      weightCapacity: json['weightCapacity'] != null 
          ? double.tryParse(json['weightCapacity'].toString()) 
          : null,
      created: json['created'] != null 
          ? DateTime.parse(json['created']) 
          : null,
      updated: json['updated'] != null 
          ? DateTime.parse(json['updated']) 
          : null,
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
      created: created ?? this.created,
      updated: updated ?? this.updated,
    );
  }
}
