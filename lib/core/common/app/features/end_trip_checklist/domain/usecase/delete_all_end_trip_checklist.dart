import 'package:xpro_delivery_admin_app/core/common/app/features/end_trip_checklist/domain/repo/end_trip_checklist_repo.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';
import 'package:xpro_delivery_admin_app/core/usecases/usecase.dart';
import 'package:equatable/equatable.dart';

class DeleteAllEndTripChecklistItems implements UsecaseWithParams<bool, DeleteAllEndTripChecklistItemsParams> {
  final EndTripChecklistRepo _repo;

  const DeleteAllEndTripChecklistItems(this._repo);

  @override
  ResultFuture<bool> call(DeleteAllEndTripChecklistItemsParams params) => 
      _repo.deleteAllEndTripChecklistItems(params.ids);
}

class DeleteAllEndTripChecklistItemsParams extends Equatable {
  final List<String> ids;

  const DeleteAllEndTripChecklistItemsParams({required this.ids});

  @override
  List<Object> get props => [ids];
}
