import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';
import '../entity/municipality_entity.dart';

abstract class MunicipalityRepo {
  const MunicipalityRepo();

  ResultFuture<List<MunicipalityEntity>> getAllMunicipalities();

  /// Municipalities filtered by parent province.
  ResultFuture<List<MunicipalityEntity>> getAllMunicipalitiesByProvinceId(
    String provinceId,
  );

  ResultFuture<MunicipalityEntity> getMunicipalityById(String id);

  ResultFuture<MunicipalityEntity> createMunicipality({
    required String name,
    required String provinceId,
  });

  ResultFuture<MunicipalityEntity> updateMunicipality({
    required String id,
    required String name,
    required String provinceId,
  });

  ResultFuture<bool> deleteMunicipality(String id);

  /// Returns the municipalities assigned to a given vehicle profile.
  /// Relation field on `vehicleProfile`: `assignedMunicipality` (multiple).
  ResultFuture<List<MunicipalityEntity>>
  getAssignedMunicipalitiesByVehicleProfileId(String vehicleProfileId);
}
