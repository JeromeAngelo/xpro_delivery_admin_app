import 'package:desktop_app/core/common/app/features/Delivery_Team/delivery_team/domain/repo/delivery_team_repo.dart';
import 'package:desktop_app/core/typedefs/typedefs.dart';
import 'package:desktop_app/core/usecases/usecase.dart';

class DeleteDeliveryTeam extends UsecaseWithParams<bool, String> {
  final DeliveryTeamRepo _repo;

  const DeleteDeliveryTeam(this._repo);

  @override
  ResultFuture<bool> call(String deliveryTeamId) async {
    return _repo.deleteDeliveryTeam(deliveryTeamId);
  }
}
