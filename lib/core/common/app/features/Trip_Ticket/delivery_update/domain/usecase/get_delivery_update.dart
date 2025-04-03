
import 'package:desktop_app/core/common/app/features/Trip_Ticket/delivery_update/domain/entity/delivery_update_entity.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/delivery_update/domain/repo/delivery_update_repo.dart';
import 'package:desktop_app/core/typedefs/typedefs.dart';
import 'package:desktop_app/core/usecases/usecase.dart';

class GetDeliveryStatusChoices implements UsecaseWithParams<List<DeliveryUpdateEntity>, String> {
  const GetDeliveryStatusChoices(this._repo);

  final DeliveryUpdateRepo _repo;

  @override
  ResultFuture<List<DeliveryUpdateEntity>> call(String customerId) async => 
      _repo.getDeliveryStatusChoices(customerId);

    
}
