import 'package:xpro_delivery_admin_app/core/common/app/features/checklist/domain/entity/checklist_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/checklist/domain/repo/checklist_repo.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';
import 'package:xpro_delivery_admin_app/core/usecases/usecase.dart';
import 'package:equatable/equatable.dart';

class CreateChecklistItem implements UsecaseWithParams<ChecklistEntity, CreateChecklistItemParams> {
  final ChecklistRepo _repo;

  const CreateChecklistItem(this._repo);

  @override
  ResultFuture<ChecklistEntity> call(CreateChecklistItemParams params) => 
      _repo.createChecklistItem(
        objectName: params.objectName,
        isChecked: params.isChecked,
        tripId: params.tripId,
        status: params.status,
        timeCompleted: params.timeCompleted,
      );
}

class CreateChecklistItemParams extends Equatable {
  final String objectName;
  final bool isChecked;
  final String? tripId;
  final String? status;
  final DateTime? timeCompleted;

  const CreateChecklistItemParams({
    required this.objectName,
    required this.isChecked,
    this.tripId,
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
