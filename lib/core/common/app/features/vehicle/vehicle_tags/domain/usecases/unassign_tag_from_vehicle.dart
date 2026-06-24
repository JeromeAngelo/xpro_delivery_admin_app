import 'package:equatable/equatable.dart';
import '../../../../../../../typedefs/typedefs.dart';
import '../../../../../../../usecases/usecase.dart';
import '../repo/vehicle_tag_repo.dart';

class UnassignTagFromVehicle
    extends UsecaseWithParams<bool, UnassignTagFromVehicleParams> {
  final VehicleTagRepo _repo;

  const UnassignTagFromVehicle(this._repo);

  @override
  ResultFuture<bool> call(UnassignTagFromVehicleParams params) => _repo
      .unassignTagFromVehicle(vehicleId: params.vehicleId, tagId: params.tagId);
}

class UnassignTagFromVehicleParams extends Equatable {
  final String vehicleId;
  final String tagId;

  const UnassignTagFromVehicleParams({
    required this.vehicleId,
    required this.tagId,
  });

  @override
  List<Object?> get props => [vehicleId, tagId];
}
