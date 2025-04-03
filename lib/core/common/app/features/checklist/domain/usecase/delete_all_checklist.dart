import 'package:desktop_app/core/common/app/features/checklist/domain/repo/checklist_repo.dart';
import 'package:desktop_app/core/typedefs/typedefs.dart';
import 'package:desktop_app/core/usecases/usecase.dart';
import 'package:equatable/equatable.dart';

class DeleteAllChecklistItems implements UsecaseWithParams<bool, DeleteAllChecklistItemsParams> {
  final ChecklistRepo _repo;

  const DeleteAllChecklistItems(this._repo);

  @override
  ResultFuture<bool> call(DeleteAllChecklistItemsParams params) => 
      _repo.deleteAllChecklistItems(params.ids);
}

class DeleteAllChecklistItemsParams extends Equatable {
  final List<String> ids;

  const DeleteAllChecklistItemsParams({required this.ids});

  @override
  List<Object> get props => [ids];
}
