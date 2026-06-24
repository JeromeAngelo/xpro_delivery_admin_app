import '../../../../../../../typedefs/typedefs.dart';
import '../../../../../../../usecases/usecase.dart';
import '../repo/vehicle_tag_repo.dart';

class DeleteVehicleTag extends UsecaseWithParams<bool, String> {
  final VehicleTagRepo _repo;

  const DeleteVehicleTag(this._repo);

  @override
  ResultFuture<bool> call(String tagId) => _repo.deleteVehicleTag(tagId);
}
