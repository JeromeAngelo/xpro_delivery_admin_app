import 'package:desktop_app/core/common/app/features/Delivery_Team/delivery_team/domain/entity/delivery_team_entity.dart';
import 'package:desktop_app/core/common/app/features/Delivery_Team/delivery_team/domain/repo/delivery_team_repo.dart';
import 'package:desktop_app/core/typedefs/typedefs.dart';
import 'package:desktop_app/core/usecases/usecase.dart';
import 'package:equatable/equatable.dart';


class AssignDeliveryTeamParams extends Equatable {
  final String tripId;
  final String deliveryTeamId;
  

  const AssignDeliveryTeamParams({
    required this.tripId,
    required this.deliveryTeamId,

  });

  @override
  List<Object> get props => [tripId, deliveryTeamId, ];
}

class AssignDeliveryTeamToTrip implements UsecaseWithParams<DeliveryTeamEntity, AssignDeliveryTeamParams> {
  final DeliveryTeamRepo _repo;

  const AssignDeliveryTeamToTrip(this._repo);

  @override
  ResultFuture<DeliveryTeamEntity> call(AssignDeliveryTeamParams params) async {
    return _repo.assignDeliveryTeamToTrip(
      tripId: params.tripId,
      deliveryTeamId: params.deliveryTeamId,
     
    );
  }
}
