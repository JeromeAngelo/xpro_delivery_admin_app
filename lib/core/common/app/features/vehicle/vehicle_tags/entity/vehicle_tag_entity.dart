import 'package:equatable/equatable.dart';

class VehicleTagEntity extends Equatable {
  final String? id;
  final String? label;
  final String? description;
 final DateTime? created;
  final DateTime? updated;

  const VehicleTagEntity({
    this.id,
    this.label,
    this.description,
    this.created,
    this.updated,
  });

  @override
  List<Object?> get props => [
        id,
        label,
        description,
        created,
        updated,
      ];
}
