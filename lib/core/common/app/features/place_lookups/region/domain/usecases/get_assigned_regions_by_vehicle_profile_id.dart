import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';
import 'package:xpro_delivery_admin_app/core/usecases/usecase.dart';
import '../entity/region_entity.dart';
import '../repo/region_repo.dart';

/// Returns the regions assigned to the given vehicle profile.
///
/// PocketBase exposes this as a multiple-relation field named
/// `assignedRegion` on the `vehicleProfile` collection, so the
/// datasource expands it and returns the resolved `RegionEntity`
/// list.
class GetAssignedRegionsByVehicleProfileId
    extends UsecaseWithParams<List<RegionEntity>, String> {
  GetAssignedRegionsByVehicleProfileId(this._repo);
  final RegionRepo _repo;

  @override
  ResultFuture<List<RegionEntity>> call(String vehicleProfileId) =>
      _repo.getAssignedRegionsByVehicleProfileId(vehicleProfileId);
}
