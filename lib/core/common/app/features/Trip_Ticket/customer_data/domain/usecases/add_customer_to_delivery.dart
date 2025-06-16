import 'package:equatable/equatable.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/customer_data/domain/repo/customer_data_repo.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';
import 'package:xpro_delivery_admin_app/core/usecases/usecase.dart';

class AddCustomerToDelivery extends UsecaseWithParams<bool, AddCustomerToDeliveryParams> {
  final CustomerDataRepo _repo;

  const AddCustomerToDelivery(this._repo);

  @override
  ResultFuture<bool> call(AddCustomerToDeliveryParams params) async {
    return _repo.addCustomerToDelivery(
      customerId: params.customerId,
      deliveryId: params.deliveryId,
    );
  }
}

class AddCustomerToDeliveryParams extends Equatable {
  final String customerId;
  final String deliveryId;

  const AddCustomerToDeliveryParams({
    required this.customerId,
    required this.deliveryId,
  });

  @override
  List<Object?> get props => [customerId, deliveryId];
}
