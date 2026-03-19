import 'package:equatable/equatable.dart';
import 'package:xpro_delivery_admin_app/core/usecases/usecase.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';
import '../repo/cancelled_invoice_repo.dart';

class ReassignTripForCancelledInvoice extends UsecaseWithParams<bool, ReassignTripForCancelledInvoiceParams> {
  const ReassignTripForCancelledInvoice(this._repo);

  final CancelledInvoiceRepo _repo;

  @override
  ResultFuture<bool> call(ReassignTripForCancelledInvoiceParams params) =>
      _repo.reassignTripForCancelledInvoice(params.deliveryDataId);
}

class ReassignTripForCancelledInvoiceParams extends Equatable {
  const ReassignTripForCancelledInvoiceParams({
    required this.deliveryDataId,
  });

  final String deliveryDataId;

  @override
  List<Object> get props => [deliveryDataId];
}
