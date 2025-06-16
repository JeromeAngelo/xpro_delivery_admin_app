import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/delivery_data/domain/repo/delivery_data_repo.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';
import 'package:xpro_delivery_admin_app/core/usecases/usecase.dart';

/// Usecase for deleting a delivery data entity by ID
///
/// Takes a delivery data ID and returns a boolean indicating success or failure
class DeleteDeliveryData extends UsecaseWithParams<bool, String> {
  final DeliveryDataRepo _repo;

  const DeleteDeliveryData(this._repo);

  @override
  ResultFuture<bool> call(String params) async {
    return _repo.deleteDeliveryData(params);
  }
}
