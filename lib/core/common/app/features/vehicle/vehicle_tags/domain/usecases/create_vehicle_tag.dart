import 'package:equatable/equatable.dart';
import '../../../../../../../enums/vehicle_tags_enums.dart';
import '../../../../../../../typedefs/typedefs.dart';
import '../../../../../../../usecases/usecase.dart';
import '../entity/vehicle_tag_entity.dart';
import '../repo/vehicle_tag_repo.dart';

class CreateVehicleTag
    extends UsecaseWithParams<VehicleTagEntity, CreateVehicleTagParams> {
  final VehicleTagRepo _repo;

  const CreateVehicleTag(this._repo);

  @override
  ResultFuture<VehicleTagEntity> call(CreateVehicleTagParams params) =>
      _repo.createVehicleTag(
        label: params.label,
        tagType: params.tagType,
        description: params.description,
      );
}

class CreateVehicleTagParams extends Equatable {
  final String label;
  final List<VehicleTagType> tagType;
  final String? description;

  const CreateVehicleTagParams({
    required this.label,
    required this.tagType,
    this.description,
  });

  @override
  List<Object?> get props => [label, tagType, description];
}
