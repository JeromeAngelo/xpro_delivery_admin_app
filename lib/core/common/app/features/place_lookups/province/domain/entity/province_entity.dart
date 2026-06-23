import 'package:equatable/equatable.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/place_lookups/region/domain/entity/region_entity.dart';

class ProvinceEntity extends Equatable {
  final String? id;
  final String? name;
  final String? regionId; // FK → Region

  /// toOne relation: the region this province belongs to.
  /// Populated when the `region` field is expanded on read.
  final RegionEntity? region;

  final DateTime? created;
  final DateTime? updated;

  const ProvinceEntity({
    this.id,
    this.name,
    this.regionId,
    this.region,
    this.created,
    this.updated,
  });

  factory ProvinceEntity.empty() {
    return const ProvinceEntity(
      id: '',
      name: '',
      regionId: null,
      region: null,
      created: null,
      updated: null,
    );
  }

  ProvinceEntity copyWith({
    String? id,
    String? name,
    String? regionId,
    RegionEntity? region,
    DateTime? created,
    DateTime? updated,
  }) {
    return ProvinceEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      regionId: regionId ?? this.regionId,
      region: region ?? this.region,
      created: created ?? this.created,
      updated: updated ?? this.updated,
    );
  }

  @override
  List<Object?> get props => [id, name, regionId, region, created, updated];
}
