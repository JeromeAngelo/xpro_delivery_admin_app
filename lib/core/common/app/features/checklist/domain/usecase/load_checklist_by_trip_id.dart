import 'package:xpro_delivery_admin_app/core/common/app/features/checklist/domain/entity/checklist_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/checklist/domain/repo/checklist_repo.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';
import 'package:xpro_delivery_admin_app/core/usecases/usecase.dart';

class LoadChecklistByTripId extends UsecaseWithParams<List<ChecklistEntity>, String> {
  const LoadChecklistByTripId(this._repo);
  final ChecklistRepo _repo;

  @override
  ResultFuture<List<ChecklistEntity>> call(String params) => _repo.loadChecklistByTripId(params);
}
