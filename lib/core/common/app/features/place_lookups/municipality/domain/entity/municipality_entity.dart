import 'package:equatable/equatable.dart';

class MunicipalityEntity extends Equatable {
  final String? id;
  final String? name;
  final String? provinceId; // FK → Province
  final DateTime? created;
  final DateTime? updated;

  const MunicipalityEntity({
    this.id,
    this.name,
    this.provinceId,
    this.created,
    this.updated,
  });

  factory MunicipalityEntity.empty() {
    return const MunicipalityEntity(
      id: '',
      name: '',
      provinceId: null,
      created: null,
      updated: null,
    );
  }

  MunicipalityEntity copyWith({
    String? id,
    String? name,
    String? provinceId,
    DateTime? created,
    DateTime? updated,
  }) {
    return MunicipalityEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      provinceId: provinceId ?? this.provinceId,
      created: created ?? this.created,
      updated: updated ?? this.updated,
    );
  }

  @override
  List<Object?> get props => [id, name, provinceId, created, updated];
}
