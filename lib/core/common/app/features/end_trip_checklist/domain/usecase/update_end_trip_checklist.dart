import 'package:desktop_app/core/common/app/features/end_trip_checklist/domain/entity/end_checklist_entity.dart';
import 'package:desktop_app/core/common/app/features/end_trip_checklist/domain/repo/end_trip_checklist_repo.dart';
import 'package:desktop_app/core/typedefs/typedefs.dart';
import 'package:desktop_app/core/usecases/usecase.dart';
import 'package:equatable/equatable.dart';

class UpdateEndTripChecklistItem implements UsecaseWithParams<EndChecklistEntity, UpdateEndTripChecklistItemParams> {
  final EndTripChecklistRepo _repo;

  const UpdateEndTripChecklistItem(this._repo);

  @override
  ResultFuture<EndChecklistEntity> call(UpdateEndTripChecklistItemParams params) => 
      _repo.updateEndTripChecklistItem(
        id: params.id,
        objectName: params.objectName,
        isChecked: params.isChecked,
        tripId: params.tripId,
        status: params.status,
        timeCompleted: params.timeCompleted,
      );
}

class UpdateEndTripChecklistItemParams extends Equatable {
  final String id;
  final String? objectName;
  final bool? isChecked;
  final String? tripId;
  final String? status;
  final DateTime? timeCompleted;

  const UpdateEndTripChecklistItemParams({
    required this.id,
    this.objectName,
    this.isChecked,
    this.tripId,
    this.status,
    this.timeCompleted,
  });

  @override
  List<Object?> get props => [
    id,
    objectName,
    isChecked,
    tripId,
    status,
    timeCompleted,
  ];
}
