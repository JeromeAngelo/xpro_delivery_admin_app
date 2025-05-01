import 'package:xpro_delivery_admin_app/core/common/app/features/checklist/domain/repo/checklist_repo.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';
import 'package:xpro_delivery_admin_app/core/usecases/usecase.dart';

class DeleteChecklistItem implements UsecaseWithParams<bool, String> {
  final ChecklistRepo _repo;

  const DeleteChecklistItem(this._repo);

  @override
  ResultFuture<bool> call(String id) => _repo.deleteChecklistItem(id);
}
