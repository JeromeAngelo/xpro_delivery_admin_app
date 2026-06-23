import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';
import 'package:xpro_delivery_admin_app/core/usecases/usecase.dart';
import '../entity/municipality_entity.dart';
import '../repo/municipality_repo.dart';

class CreateMunicipalityParams {
  final String name;
  final String provinceId;
  const CreateMunicipalityParams({
    required this.name,
    required this.provinceId,
  });
}

class CreateMunicipality
    extends UsecaseWithParams<MunicipalityEntity, CreateMunicipalityParams> {
  CreateMunicipality(this._repo);
  final MunicipalityRepo _repo;

  @override
  ResultFuture<MunicipalityEntity> call(CreateMunicipalityParams params) =>
      _repo.createMunicipality(
        name: params.name,
        provinceId: params.provinceId,
      );
}
