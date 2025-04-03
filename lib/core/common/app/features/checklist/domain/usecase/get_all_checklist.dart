import 'package:desktop_app/core/common/app/features/checklist/domain/entity/checklist_entity.dart';
import 'package:desktop_app/core/common/app/features/checklist/domain/repo/checklist_repo.dart';
import 'package:desktop_app/core/typedefs/typedefs.dart';
import 'package:desktop_app/core/usecases/usecase.dart';

class GetAllChecklists implements UsecaseWithoutParams<List<ChecklistEntity>> {
  final ChecklistRepo _repo;

  const GetAllChecklists(this._repo);

  @override
  ResultFuture<List<ChecklistEntity>> call() => _repo.getAllChecklists();
}
