import 'package:desktop_app/core/common/app/features/Trip_Ticket/trip/domain/entity/trip_entity.dart';
import 'package:equatable/equatable.dart';

class ChecklistEntity extends Equatable {
  final String id;
  final String? objectName;
  bool? isChecked;
  final String? status;
  DateTime? timeCompleted;
  final TripEntity? trip;

  ChecklistEntity({
    required this.id,
    required this.objectName,
    required this.isChecked,
    this.status,
    this.timeCompleted,
    this.trip,
  });

  ChecklistEntity.empty()
      : id = '',
        objectName = '',
        isChecked = false,
        status = '',
        trip = null;

  @override
  List<Object?> get props => [
        id,
        objectName,
        isChecked,
        timeCompleted,
        trip?.id,
      ];

  @override
  String toString() {
    return 'ChecklistEntity(id: $id, objectName: $objectName, isChecked: $isChecked, tripId: ${trip?.id})';
  }
}
