import 'package:equatable/equatable.dart';
import '../../../../../../../typedefs/typedefs.dart';
import '../../../../../../../usecases/usecase.dart';
import '../repo/vehicle_tag_repo.dart';

class AssignTagToVehicle
    extends UsecaseWithParams<bool, AssignTagToVehicleParams> {
  final VehicleTagRepo _repo;

  const AssignTagToVehicle(this._repo);

  @override
  ResultFuture<bool> call(AssignTagToVehicleParams params) => _repo
      .assignTagToVehicle(vehicleId: params.vehicleId, tagId: params.tagId);
}

class AssignTagToVehicleParams extends Equatable {
  final String vehicleId;
  final String tagId;

  const AssignTagToVehicleParams({
    required this.vehicleId,
    required this.tagId,
  });

  @override
  List<Object?> get props => [vehicleId, tagId];
}
