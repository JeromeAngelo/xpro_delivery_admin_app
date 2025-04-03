import 'package:desktop_app/core/common/app/features/end_trip_checklist/domain/repo/end_trip_checklist_repo.dart';
import 'package:desktop_app/core/typedefs/typedefs.dart';
import 'package:desktop_app/core/usecases/usecase.dart';


class CheckEndTripChecklist extends UsecaseWithParams<bool, String> {
  const CheckEndTripChecklist(this._repo);

  final EndTripChecklistRepo _repo;

  @override
  ResultFuture<bool> call(String params) => 
      _repo.checkEndTripChecklistItem(params);
}
