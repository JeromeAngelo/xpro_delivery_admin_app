import '../../../../../../../typedefs/typedefs.dart';
import '../../../../../../../usecases/usecase.dart';
import '../entity/vehicle_tag_entity.dart';
import '../repo/vehicle_tag_repo.dart';

class LoadVehicleTagById extends UsecaseWithParams<VehicleTagEntity, String> {
  final VehicleTagRepo _repo;

  const LoadVehicleTagById(this._repo);

  @override
  ResultFuture<VehicleTagEntity> call(String tagId) => _repo.loadVehicleTagById(tagId);
}