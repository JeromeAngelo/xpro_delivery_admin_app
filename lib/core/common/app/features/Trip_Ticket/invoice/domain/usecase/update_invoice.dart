import 'package:desktop_app/core/common/app/features/Trip_Ticket/invoice/domain/entity/invoice_entity.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/invoice/domain/repo/invoice_repo.dart';
import 'package:desktop_app/core/enums/invoice_status.dart';
import 'package:desktop_app/core/typedefs/typedefs.dart';
import 'package:desktop_app/core/usecases/usecase.dart';
import 'package:equatable/equatable.dart';

class UpdateInvoice extends UsecaseWithParams<InvoiceEntity, UpdateInvoiceParams> {
  final InvoiceRepo _repo;
  const UpdateInvoice(this._repo);

  @override
  ResultFuture<InvoiceEntity> call(UpdateInvoiceParams params) => 
      _repo.updateInvoice(
        id: params.id,
        invoiceNumber: params.invoiceNumber,
        customerId: params.customerId,
        tripId: params.tripId,
        productIds: params.productIds,
        status: params.status,
        totalAmount: params.totalAmount,
        confirmTotalAmount: params.confirmTotalAmount,
        customerDeliveryStatus: params.customerDeliveryStatus,
      );
}

class UpdateInvoiceParams extends Equatable {
  final String id;
  final String? invoiceNumber;
  final String? customerId;
  final String? tripId;
  final List<String>? productIds;
  final InvoiceStatus? status;
  final double? totalAmount;
  final double? confirmTotalAmount;
  final String? customerDeliveryStatus;

  const UpdateInvoiceParams({
    required this.id,
    this.invoiceNumber,
    this.customerId,
    this.tripId,
    this.productIds,
    this.status,
    this.totalAmount,
    this.confirmTotalAmount,
    this.customerDeliveryStatus,
  });

  @override
  List<Object?> get props => [
    id,
    invoiceNumber,
    customerId,
    tripId,
    productIds,
    status,
    totalAmount,
    confirmTotalAmount,
    customerDeliveryStatus,
  ];
}
