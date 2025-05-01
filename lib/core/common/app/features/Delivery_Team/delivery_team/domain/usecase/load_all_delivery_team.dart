import 'package:xpro_delivery_admin_app/core/common/app/features/Delivery_Team/delivery_team/domain/entity/delivery_team_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Delivery_Team/delivery_team/domain/repo/delivery_team_repo.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';
import 'package:xpro_delivery_admin_app/core/usecases/usecase.dart';

class LoadAllDeliveryTeam
    extends UsecaseWithoutParams<List<DeliveryTeamEntity>> {
  final DeliveryTeamRepo _repo;
  LoadAllDeliveryTeam(this._repo);

  @override
  ResultFuture<List<DeliveryTeamEntity>> call() => _repo.loadAllDeliveryTeam();
}
