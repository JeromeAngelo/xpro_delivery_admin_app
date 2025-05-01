import 'package:xpro_delivery_admin_app/core/common/app/features/end_trip_checklist/domain/repo/end_trip_checklist_repo.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';
import 'package:xpro_delivery_admin_app/core/usecases/usecase.dart';

class DeleteEndTripChecklistItem implements UsecaseWithParams<bool, String> {
  final EndTripChecklistRepo _repo;

  const DeleteEndTripChecklistItem(this._repo);

  @override
  ResultFuture<bool> call(String id) => _repo.deleteEndTripChecklistItem(id);
}
