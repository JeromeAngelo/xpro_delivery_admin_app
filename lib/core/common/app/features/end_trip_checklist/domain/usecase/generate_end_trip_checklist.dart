import 'package:xpro_delivery_admin_app/core/common/app/features/end_trip_checklist/domain/entity/end_checklist_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/end_trip_checklist/domain/repo/end_trip_checklist_repo.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';
import 'package:xpro_delivery_admin_app/core/usecases/usecase.dart';


class GenerateEndTripChecklist extends UsecaseWithParams<List<EndChecklistEntity>, String> {
  const GenerateEndTripChecklist(this._repo);

  final EndTripChecklistRepo _repo;

  @override
  ResultFuture<List<EndChecklistEntity>> call(String params) => 
      _repo.generateEndTripChecklist(params);
}


