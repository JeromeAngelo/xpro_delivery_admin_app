import '../../../../../../../enums/vehicle_tags_enums.dart';
import '../../../../../../../typedefs/typedefs.dart';
import '../entity/vehicle_tag_entity.dart';

abstract class VehicleTagRepo {
  const VehicleTagRepo();

  ResultFuture<List<VehicleTagEntity>> getVehicleTags();
  ResultFuture<VehicleTagEntity> loadVehicleTagById(String tagId);
  ResultFuture<VehicleTagEntity> createVehicleTag({
    required String label,
    required List<VehicleTagType> tagType,
    String? description,
  });
  ResultFuture<VehicleTagEntity> updateVehicleTag({
    required String tagId,
    String? label,
    List<VehicleTagType>? tagType,
    String? description,
  });
  ResultFuture<bool> deleteVehicleTag(String tagId);

  //Assigning and unassigning tags to vehicles
  ResultFuture<bool> assignTagToVehicle({
    required String vehicleId,
    required String tagId,
  });
  ResultFuture<bool> unassignTagFromVehicle({
    required String vehicleId,
    required String tagId,
  });
}