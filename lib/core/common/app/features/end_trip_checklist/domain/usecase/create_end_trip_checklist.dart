import 'package:xpro_delivery_admin_app/core/common/app/features/end_trip_checklist/domain/entity/end_checklist_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/end_trip_checklist/domain/repo/end_trip_checklist_repo.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';
import 'package:xpro_delivery_admin_app/core/usecases/usecase.dart';
import 'package:equatable/equatable.dart';

class CreateEndTripChecklistItem implements UsecaseWithParams<EndChecklistEntity, CreateEndTripChecklistItemParams> {
  final EndTripChecklistRepo _repo;

  const CreateEndTripChecklistItem(this._repo);

  @override
  ResultFuture<EndChecklistEntity> call(CreateEndTripChecklistItemParams params) => 
      _repo.createEndTripChecklistItem(
        objectName: params.objectName,
        isChecked: params.isChecked,
        tripId: params.tripId,
        status: params.status,
        timeCompleted: params.timeCompleted,
      );
}

class CreateEndTripChecklistItemParams extends Equatable {
  final String objectName;
  final bool isChecked;
  final String tripId;
  final String? status;
  final DateTime? timeCompleted;

  const CreateEndTripChecklistItemParams({
    required this.objectName,
    required this.isChecked,
    required this.tripId,
    this.status,
    this.timeCompleted,
  });

  @override
  List<Object?> get props => [
    objectName,
    isChecked,
    tripId,
    status,
    timeCompleted,
  ];
}
