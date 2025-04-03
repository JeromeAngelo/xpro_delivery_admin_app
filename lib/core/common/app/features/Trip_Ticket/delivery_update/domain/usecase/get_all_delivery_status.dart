import 'package:desktop_app/core/common/app/features/Trip_Ticket/delivery_update/domain/entity/delivery_update_entity.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/delivery_update/domain/repo/delivery_update_repo.dart';
import 'package:desktop_app/core/typedefs/typedefs.dart';
import 'package:desktop_app/core/usecases/usecase.dart';

class GetAllDeliveryUpdates extends UsecaseWithoutParams<List<DeliveryUpdateEntity>> {
  final DeliveryUpdateRepo _repo;
  const GetAllDeliveryUpdates(this._repo);

  @override
  ResultFuture<List<DeliveryUpdateEntity>> call() => _repo.getAllDeliveryUpdates();
}
