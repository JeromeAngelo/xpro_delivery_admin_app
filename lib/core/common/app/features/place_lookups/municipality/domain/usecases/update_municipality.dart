import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';
import 'package:xpro_delivery_admin_app/core/usecases/usecase.dart';
import '../entity/municipality_entity.dart';
import '../repo/municipality_repo.dart';

class UpdateMunicipalityParams {
  final String id;
  final String name;
  final String provinceId;
  const UpdateMunicipalityParams({
    required this.id,
    required this.name,
    required this.provinceId,
  });
}

class UpdateMunicipality
    extends UsecaseWithParams<MunicipalityEntity, UpdateMunicipalityParams> {
  UpdateMunicipality(this._repo);
  final MunicipalityRepo _repo;

  @override
  ResultFuture<MunicipalityEntity> call(UpdateMunicipalityParams params) =>
      _repo.updateMunicipality(
        id: params.id,
        name: params.name,
        provinceId: params.provinceId,
      );
}
