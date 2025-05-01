import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/delivery_update/domain/repo/delivery_update_repo.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';
import 'package:xpro_delivery_admin_app/core/usecases/usecase.dart';

class DeleteAllDeliveryUpdates extends UsecaseWithParams<bool, List<String>> {
  final DeliveryUpdateRepo _repo;
  const DeleteAllDeliveryUpdates(this._repo);

  @override
  ResultFuture<bool> call(List<String> params) => _repo.deleteAllDeliveryUpdates(params);
}
