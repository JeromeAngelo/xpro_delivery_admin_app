import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';
import '../entity/region_entity.dart';

abstract class RegionRepo {
  const RegionRepo();

  ResultFuture<List<RegionEntity>> getAllRegions();

  ResultFuture<RegionEntity> getRegionById(String id);

  ResultFuture<RegionEntity> createRegion({
    required String name,
    String? alias,
  });

  ResultFuture<RegionEntity> updateRegion({
    required String id,
    required String name,
    String? alias,
  });

  ResultFuture<bool> deleteRegion(String id);

  /// Returns the regions assigned to a given vehicle profile (the
  /// relation field on the `vehicleProfile` collection is named
  /// `assignedRegion` and is a multiple relation).
  ResultFuture<List<RegionEntity>> getAssignedRegionsByVehicleProfileId(
    String vehicleProfileId,
  );
}
