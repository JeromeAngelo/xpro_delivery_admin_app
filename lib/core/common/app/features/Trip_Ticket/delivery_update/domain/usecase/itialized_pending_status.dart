
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/delivery_update/domain/repo/delivery_update_repo.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';
import 'package:xpro_delivery_admin_app/core/usecases/usecase.dart';

class InitializePendingStatus extends UsecaseWithParams<void, List<String>> {
  const InitializePendingStatus(this._repo);

  final DeliveryUpdateRepo _repo;

  @override
  ResultFuture<void> call(List<String> params) async {
    return _repo.initializePendingStatus(params);
  }
}
