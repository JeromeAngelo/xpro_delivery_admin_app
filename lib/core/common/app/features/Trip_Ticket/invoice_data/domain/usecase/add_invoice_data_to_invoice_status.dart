import 'package:equatable/equatable.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/invoice_data/domain/repo/invoice_data_repo.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';
import 'package:xpro_delivery_admin_app/core/usecases/usecase.dart';

class AddInvoiceDataToInvoiceStatus extends UsecaseWithParams<bool, AddInvoiceDataToInvoiceStatusParams> {
  const AddInvoiceDataToInvoiceStatus(this._repo);

  final InvoiceDataRepo _repo;

  @override
  ResultFuture<bool> call(AddInvoiceDataToInvoiceStatusParams params) async {
    return _repo.addInvoiceDataToInvoiceStatus(
      invoiceId: params.invoiceId,
      invoiceStatusId: params.invoiceStatusId,
    );
  }
}

class AddInvoiceDataToInvoiceStatusParams extends Equatable {
  const AddInvoiceDataToInvoiceStatusParams({
    required this.invoiceId,
    required this.invoiceStatusId,
  });

  final String invoiceId;
  final String invoiceStatusId;

  @override
  List<Object?> get props => [invoiceId, invoiceStatusId];
}
