import 'package:equatable/equatable.dart';
import 'package:xpro_delivery_admin_app/core/enums/vehicle_tags_enums.dart';

class VehicleTagEntity extends Equatable {
  final String? id;
  final String? label;
  final String? description;
  final DateTime? created;
  final DateTime? updated;
  final List<VehicleTagType>? types;
  final DateTime? expiration;
  final String? stickerNumber;

  const VehicleTagEntity({
    this.id,
    this.label,
    this.description,
    this.created,
    this.updated,
    this.types,
    this.expiration,
    this.stickerNumber,
  });

  @override
  List<Object?> get props => [id, label, description, created, updated, types, expiration, stickerNumber];
}
