import 'package:desktop_app/core/common/app/features/end_trip_checklist/domain/entity/end_checklist_entity.dart';
import 'package:desktop_app/core/common/app/features/end_trip_checklist/domain/repo/end_trip_checklist_repo.dart';
import 'package:desktop_app/core/typedefs/typedefs.dart';
import 'package:desktop_app/core/usecases/usecase.dart';

class LoadEndTripChecklist extends UsecaseWithParams<List<EndChecklistEntity>, String> {
  const LoadEndTripChecklist(this._repo);

  final EndTripChecklistRepo _repo;

  @override
  ResultFuture<List<EndChecklistEntity>> call(String params) => 
      _repo.loadEndTripChecklist(params);
      

}




