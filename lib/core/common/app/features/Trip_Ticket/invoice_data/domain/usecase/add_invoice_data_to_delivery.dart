import 'package:equatable/equatable.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/invoice_data/domain/repo/invoice_data_repo.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';
import 'package:xpro_delivery_admin_app/core/usecases/usecase.dart';

class AddInvoiceDataToDelivery extends UsecaseWithParams<bool, AddInvoiceDataToDeliveryParams> {
  const AddInvoiceDataToDelivery(this._repo);

  final InvoiceDataRepo _repo;

  @override
  ResultFuture<bool> call(AddInvoiceDataToDeliveryParams params) async {
    return _repo.addInvoiceDataToDelivery(
      invoiceId: params.invoiceId,
      deliveryId: params.deliveryId,
    );
  }
}

class AddInvoiceDataToDeliveryParams extends Equatable {
  const AddInvoiceDataToDeliveryParams({
    required this.invoiceId,
    required this.deliveryId,
  });

  final String invoiceId;
  final String deliveryId;

  @override
  List<Object?> get props => [invoiceId, deliveryId];
}
