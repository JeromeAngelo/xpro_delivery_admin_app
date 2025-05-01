import 'package:xpro_delivery_admin_app/core/common/app/features/checklist/domain/entity/checklist_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/checklist/domain/repo/checklist_repo.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';
import 'package:xpro_delivery_admin_app/core/usecases/usecase.dart';
import 'package:equatable/equatable.dart';

class UpdateChecklistItem implements UsecaseWithParams<ChecklistEntity, UpdateChecklistItemParams> {
  final ChecklistRepo _repo;

  const UpdateChecklistItem(this._repo);

  @override
  ResultFuture<ChecklistEntity> call(UpdateChecklistItemParams params) => 
      _repo.updateChecklistItem(
        id: params.id,
        objectName: params.objectName,
        isChecked: params.isChecked,
        tripId: params.tripId,
        status: params.status,
        timeCompleted: params.timeCompleted,
      );
}

class UpdateChecklistItemParams extends Equatable {
  final String id;
  final String? objectName;
  final bool? isChecked;
  final String? tripId;
  final String? status;
  final DateTime? timeCompleted;

  const UpdateChecklistItemParams({
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
