import '../../../../../../../typedefs/typedefs.dart';
import '../../../../../../../usecases/usecase.dart';
import '../entity/vehicle_tag_entity.dart';
import '../repo/vehicle_tag_repo.dart';

class GetVehicleTags extends UsecaseWithoutParams<List<VehicleTagEntity>> {
  final VehicleTagRepo _repo;

  const GetVehicleTags(this._repo);

  @override
  ResultFuture<List<VehicleTagEntity>> call() => _repo.getVehicleTags();
}
