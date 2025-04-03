import 'package:desktop_app/core/common/app/features/end_trip_checklist/domain/entity/end_checklist_entity.dart';
import 'package:desktop_app/core/typedefs/typedefs.dart';


class EndTripChecklistModel extends EndChecklistEntity {
  String pocketbaseId;

  EndTripChecklistModel({
    String? id,
    String? objectName,
    bool? isChecked,
    String? status,
    String? trip,
    super.timeCompleted,
  }) : pocketbaseId = id ?? '',
       super(
         id: id ?? '',
         objectName: objectName ?? '',
         isChecked: isChecked ?? false,
         status: status ?? '',
         trip: trip ?? '',
       );

  factory EndTripChecklistModel.fromJson(DataMap json) {
    return EndTripChecklistModel(
      id: json['id']?.toString() ?? '',
      objectName: json['objectName']?.toString() ?? '',
      isChecked: json['isChecked'] as bool? ?? false,
      status: json['status']?.toString() ?? '',
      trip: json['trip']?.toString() ?? '',
      timeCompleted: json['timeCompleted'] != null 
          ? DateTime.tryParse(json['timeCompleted'].toString())?.toUtc() 
          : null,
    );
  }

  DataMap toJson() {
    return {
      'id': id,
      'objectName': objectName,
      'isChecked': isChecked,
      'status': status,
      'trip': trip,
      'timeCompleted': timeCompleted?.toIso8601String(),
    };
  }
}
