import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';

import '../../../../../../../enums/vehicle_tags_enums.dart';
import '../../../../../../../typedefs/typedefs.dart';
import '../../domain/entity/vehicle_tag_entity.dart';

class VehicleTagModel extends VehicleTagEntity {
  String pocketbaseId;

  VehicleTagModel({
    super.id,
    super.label,
    super.description,
    super.created,
    super.updated,
    super.types,
    super.expiration,
    super.stickerNumber,
  }) : pocketbaseId = id ?? '',
       super();

  factory VehicleTagModel.fromJson(DataMap json) {
    debugPrint('🔧 VehicleTagModel.fromJson: Processing data');

    DateTime? parseDate(dynamic value) {
      if (value == null || value.toString().isEmpty) return null;
      try {
        return DateTime.parse(value.toString());
      } catch (_) {
        return null;
      }
    }

    List<VehicleTagType>? parseTypes(dynamic value) {
      if (value == null) return null;
      if (value is List) {
        return value
            .map(
              (e) => VehicleTagType.values.firstWhere(
                (type) => type.name == e.toString(),
                orElse: () => VehicleTagType.other,
              ),
            )
            .toList();
      }
      return null;
    }

    return VehicleTagModel(
      id: json['id']?.toString(),
      label: json['label']?.toString(),
      description: json['description']?.toString(),
      created: parseDate(json['created']),
      updated: parseDate(json['updated']),
      types: parseTypes(json['types'] ?? json['tagType']),
      expiration: parseDate(json['expiration']),
      stickerNumber: json['stickerNumber']?.toString(),
    );
  }

  factory VehicleTagModel.fromRecord(RecordModel record) {
    return VehicleTagModel.fromJson({
      'id': record.id,
      'collectionId': record.collectionId,
      'collectionName': record.collectionName,
      ...record.data,
      'expand': record.expand,
    });
  }

  DataMap toJson() {
    return {
      'label': label,
      'description': description,
      'types': types?.map((type) => type.name).toList(),
      'expiration': expiration,
      'stickerNumber': stickerNumber,
    };
  }

  VehicleTagModel copyWith({
    String? id,
    String? label,
    String? description,
    DateTime? created,
    DateTime? updated,
    List<VehicleTagType>? types,
    DateTime? expiration,
    String? stickerNumber,
  }) {
    return VehicleTagModel(
      id: id ?? this.id,
      label: label ?? this.label,
      description: description ?? this.description,
      created: created ?? this.created,
      updated: updated ?? this.updated,
      types: types ?? this.types,
      expiration: expiration ?? this.expiration,
      stickerNumber: stickerNumber ?? this.stickerNumber,
    );
  }

  factory VehicleTagModel.fromEntity(VehicleTagEntity entity) {
    return VehicleTagModel(
      id: entity.id,
      label: entity.label,
      description: entity.description,
      created: entity.created,
      updated: entity.updated,
      types: entity.types,
      expiration: entity.expiration,
      stickerNumber: entity.stickerNumber,
    );
  }

  factory VehicleTagModel.empty() {
    return VehicleTagModel(
      id: '',
      label: '',
      description: '',
      created: null,
      updated: null,
      types: [],
      expiration: null,
      stickerNumber: '',
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VehicleTagModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
