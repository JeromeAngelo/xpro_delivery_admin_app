import 'package:equatable/equatable.dart';
import '../../../../../../../enums/vehicle_tags_enums.dart';
import '../../../../../../../typedefs/typedefs.dart';
import '../../../../../../../usecases/usecase.dart';
import '../entity/vehicle_tag_entity.dart';
import '../repo/vehicle_tag_repo.dart';

class UpdateVehicleTag
    extends UsecaseWithParams<VehicleTagEntity, UpdateVehicleTagParams> {
  final VehicleTagRepo _repo;

  const UpdateVehicleTag(this._repo);

  @override
  ResultFuture<VehicleTagEntity> call(UpdateVehicleTagParams params) =>
      _repo.updateVehicleTag(
        tagId: params.tagId,
        label: params.label,
        tagType: params.tagType,
        description: params.description,
      );
}

class UpdateVehicleTagParams extends Equatable {
  final String tagId;
  final String? label;
  final List<VehicleTagType>? tagType;
  final String? description;

  const UpdateVehicleTagParams({
    required this.tagId,
    this.label,
    this.tagType,
    this.description,
  });

  @override
  List<Object?> get props => [tagId, label, tagType, description];
}
