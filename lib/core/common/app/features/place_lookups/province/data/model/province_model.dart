import 'package:pocketbase/pocketbase.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';

import '../../../region/domain/entity/region_entity.dart';
import '../../../region/data/model/region_model.dart';
import '../../domain/entity/province_entity.dart';

class ProvinceModel extends ProvinceEntity {
  ProvinceModel({
    super.id,
    super.name,
    super.regionId,
    super.region,
    super.created,
    super.updated,
  });

  factory ProvinceModel.fromJson(DataMap json) {
    DateTime? parseDate(dynamic value) {
      if (value == null || value.toString().isEmpty) return null;
      try {
        return DateTime.parse(value.toString());
      } catch (_) {
        return null;
      }
    }

    // toOne relation `region` — may be expanded inline or be a plain ID string.
    RegionEntity? regionEntity;
    final expand = json['expand'] as Map<String, dynamic>?;
    final regionExpand = expand?['region'] ?? json['region'];
    if (regionExpand is RecordModel) {
      regionEntity = RegionModel.fromRecord(regionExpand);
    } else if (regionExpand is Map) {
      regionEntity = RegionModel.fromJson(regionExpand.cast<String, dynamic>());
    } else if (regionExpand is String) {
      regionEntity = RegionEntity(id: regionExpand);
    }

    return ProvinceModel(
      id: json['id']?.toString(),
      name: json['name']?.toString(),
      regionId: json['region']?.toString(),
      region: regionEntity,
      created: parseDate(json['created']),
      updated: parseDate(json['updated']),
    );
  }

  factory ProvinceModel.fromRecord(RecordModel record) {
    return ProvinceModel.fromJson({
      'id': record.id,
      'collectionId': record.collectionId,
      'collectionName': record.collectionName,
      'expand': record.expand,
      ...record.data,
    });
  }

  DataMap toJson() {
    return {'name': name, 'region': regionId};
  }
}
