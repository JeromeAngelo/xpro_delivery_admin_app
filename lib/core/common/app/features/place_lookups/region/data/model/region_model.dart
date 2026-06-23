import 'package:pocketbase/pocketbase.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';

import '../../../province/domain/entity/province_entity.dart';
import '../../domain/entity/region_entity.dart';
import '../../../../place_lookups/province/data/model/province_model.dart';

class RegionModel extends RegionEntity {
  // Relationship IDs (for PocketBase serialization / non-expanded reads)
  List<String>? provinceIds;

  RegionModel({
    super.id,
    super.name,
    super.alias,
    super.provinces,
    this.provinceIds,
    super.created,
    super.updated,
  });

  // ---------------------------------------------------------------------------
  // FROM JSON
  // ---------------------------------------------------------------------------
  factory RegionModel.fromJson(DataMap json) {
    final expand = json['expand'] as Map<String, dynamic>?;

    DateTime? parseDate(dynamic value) {
      if (value == null || value.toString().isEmpty) return null;
      try {
        return DateTime.parse(value.toString());
      } catch (_) {
        return null;
      }
    }

    // Back-relation `provinces` (records whose `region` field points here)
    List<ProvinceEntity> provincesList = [];
    final provincesExpand = expand?['provinces'] ?? json['provinces'];
    if (provincesExpand != null && provincesExpand is List) {
      for (final p in provincesExpand) {
        if (p is RecordModel) {
          provincesList.add(ProvinceModel.fromRecord(p));
        } else if (p is Map) {
          provincesList.add(ProvinceModel.fromJson(p as Map<String, dynamic>));
        } else if (p is String) {
          provincesList.add(ProvinceEntity(id: p));
        }
      }
    }

    return RegionModel(
      id: json['id']?.toString(),
      name: json['name']?.toString(),
      alias: json['alias']?.toString(),
      provinces: provincesList,
      provinceIds:
          json['provinces'] != null ? List<String>.from(json['provinces']) : [],
      created: parseDate(json['created']),
      updated: parseDate(json['updated']),
    );
  }

  factory RegionModel.fromRecord(RecordModel record) {
    return RegionModel.fromJson({
      'id': record.id,
      'collectionId': record.collectionId,
      'collectionName': record.collectionName,
      'expand': record.expand,
      ...record.data,
    });
  }

  // ---------------------------------------------------------------------------
  // FROM ENTITY
  // ---------------------------------------------------------------------------
  factory RegionModel.fromEntity(RegionEntity entity) {
    return RegionModel(
      id: entity.id,
      name: entity.name,
      alias: entity.alias,
      provinces: entity.provinces,
      provinceIds:
          entity.provinces?.map((e) => e.id ?? '').toList() ?? const [],
      created: entity.created,
      updated: entity.updated,
    );
  }

  // ---------------------------------------------------------------------------
  // EMPTY MODEL
  // ---------------------------------------------------------------------------
  factory RegionModel.empty() {
    return RegionModel(
      id: '',
      name: '',
      alias: '',
      provinces: [],
      provinceIds: [],
      created: null,
      updated: null,
    );
  }

  // ---------------------------------------------------------------------------
  // TO JSON
  // ---------------------------------------------------------------------------
  DataMap toJson() {
    return {
      'name': name,
      'alias': alias,
      'provinces': provinceIds ?? const [],
      'created': created?.toIso8601String(),
      'updated': updated?.toIso8601String(),
    };
  }

  // ---------------------------------------------------------------------------
  // COPY WITH
  // ---------------------------------------------------------------------------
  @override
  RegionModel copyWith({
    String? id,
    String? name,
    String? alias,
    List<ProvinceEntity>? provinces,
    List<String>? provinceIds,
    DateTime? created,
    DateTime? updated,
  }) {
    return RegionModel(
      id: id ?? this.id,
      name: name ?? this.name,
      alias: alias ?? this.alias,
      provinces: provinces ?? this.provinces,
      provinceIds: provinceIds ?? this.provinceIds,
      created: created ?? this.created,
      updated: updated ?? this.updated,
    );
  }

  // ---------------------------------------------------------------------------
  // EQUALITY
  // ---------------------------------------------------------------------------
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RegionModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
