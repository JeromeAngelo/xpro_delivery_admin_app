import 'package:equatable/equatable.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/place_lookups/province/domain/entity/province_entity.dart';

class RegionEntity extends Equatable {
  final String? id;
  final String? name;
  final String? alias;
  final DateTime? created;
  final DateTime? updated;

  /// Back-relation: provinces that point to this region
  /// via the `region` field on the `province` collection.
  final List<ProvinceEntity>? provinces;

  const RegionEntity({
    this.id,
    this.name,
    this.alias,
    this.provinces,
    this.created,
    this.updated,
  });

  factory RegionEntity.empty() {
    return const RegionEntity(
      id: '',
      name: '',
      alias: '',
      provinces: [],
      created: null,
      updated: null,
    );
  }

  RegionEntity copyWith({
    String? id,
    String? name,
    String? alias,
    List<ProvinceEntity>? provinces,
    DateTime? created,
    DateTime? updated,
  }) {
    return RegionEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      alias: alias ?? this.alias,
      provinces: provinces ?? this.provinces,
      created: created ?? this.created,
      updated: updated ?? this.updated,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    alias,
    provinces?.map((e) => e.id).toList(),
    created,
    updated,
  ];
}
