import 'package:pocketbase/pocketbase.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';

import '../../domain/entity/municipality_entity.dart';

class MunicipalityModel extends MunicipalityEntity {
  MunicipalityModel({
    super.id,
    super.name,
    super.provinceId,
    super.created,
    super.updated,
  });

  factory MunicipalityModel.fromJson(DataMap json) {
    DateTime? parseDate(dynamic value) {
      if (value == null || value.toString().isEmpty) return null;
      try {
        return DateTime.parse(value.toString());
      } catch (_) {
        return null;
      }
    }

    return MunicipalityModel(
      id: json['id']?.toString(),
      name: json['name']?.toString(),
      provinceId: json['province']?.toString(),
      created: parseDate(json['created']),
      updated: parseDate(json['updated']),
    );
  }

  factory MunicipalityModel.fromRecord(RecordModel record) {
    return MunicipalityModel.fromJson({
      'id': record.id,
      'collectionId': record.collectionId,
      'collectionName': record.collectionName,
      ...record.data,
    });
  }

  DataMap toJson() {
    return {'name': name, 'province': provinceId};
  }
}
