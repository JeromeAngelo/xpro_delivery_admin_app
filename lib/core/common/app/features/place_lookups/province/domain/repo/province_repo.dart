import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';
import '../entity/province_entity.dart';

abstract class ProvinceRepo {
  const ProvinceRepo();

  ResultFuture<List<ProvinceEntity>> getAllProvinces();

  /// Provinces filtered by parent region.
  ResultFuture<List<ProvinceEntity>> getAllProvincesByRegionId(String regionId);

  ResultFuture<ProvinceEntity> getProvinceById(String id);

  ResultFuture<ProvinceEntity> createProvince({
    required String name,
    required String regionId,
  });

  ResultFuture<ProvinceEntity> updateProvince({
    required String id,
    required String name,
    required String regionId,
  });

  ResultFuture<bool> deleteProvince(String id);

  /// Returns the provinces assigned to a given vehicle profile.
  /// Relation field on `vehicleProfile`: `assignedProvince` (multiple).
  ResultFuture<List<ProvinceEntity>> getAssignedProvincesByVehicleProfileId(
    String vehicleProfileId,
  );
}
