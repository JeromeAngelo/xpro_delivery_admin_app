import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/trip/data/models/trip_models.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/checklist/domain/entity/checklist_entity.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';

class ChecklistModel extends ChecklistEntity {
  String? pocketBaseId;
  String? tripId;

  ChecklistModel({
    String? id,
    String? objectName,
    bool? isChecked,
    String? status,
    super.timeCompleted,
    TripModel? tripModel,
    this.tripId,
  }) : super(
         id: id ?? '',
         objectName: objectName ?? '',
         isChecked: isChecked ?? false,
         status: status ?? '',
         trip: tripModel,
       );

  // Factory constructor to create a model from JSON
  factory ChecklistModel.fromJson(DataMap json) {
    return ChecklistModel(
      id: json['id']?.toString() ?? '',
      objectName: json['objectName']?.toString() ?? '',
      isChecked: json['isChecked'] as bool? ?? false,
      status: json['status']?.toString() ?? '',
      timeCompleted: json['timeCompleted'] != null 
          ? DateTime.tryParse(json['timeCompleted'].toString())?.toUtc() 
          : null,
      tripId: json['trip']?.toString(),
    );
  }

  // Convert model to JSON
  DataMap toJson() {
    return {
      'id': id,
      'objectName': objectName,
      'isChecked': isChecked,
      'status': status,
      'timeCompleted': timeCompleted?.toIso8601String(),
      'trip': tripId,
    };
  }

  // Create a copy of this model with optional new values
  ChecklistModel copyWith({
    String? id,
    String? objectName,
    bool? isChecked,
    String? status,
    DateTime? timeCompleted,
    TripModel? tripModel,
    String? tripId,
  }) {
    return ChecklistModel(
      id: id ?? this.id,
      objectName: objectName ?? this.objectName,
      isChecked: isChecked ?? this.isChecked,
      status: status ?? this.status,
      timeCompleted: timeCompleted ?? this.timeCompleted,
      tripModel: tripModel ?? (trip as TripModel?),
      tripId: tripId ?? this.tripId,
    );
  }

  // Create a model from an entity
  factory ChecklistModel.fromEntity(ChecklistEntity entity) {
    return ChecklistModel(
      id: entity.id,
      objectName: entity.objectName,
      isChecked: entity.isChecked,
      status: entity.status,
      timeCompleted: entity.timeCompleted,
      tripModel: entity.trip as TripModel?,
    );
  }

  // Create an empty model
  factory ChecklistModel.empty() {
    return ChecklistModel(
      id: '',
      objectName: '',
      isChecked: false,
      status: '',
    );
  }
}