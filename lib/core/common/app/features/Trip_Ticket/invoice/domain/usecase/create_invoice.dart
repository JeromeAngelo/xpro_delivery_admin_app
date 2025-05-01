import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/invoice/domain/entity/invoice_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/invoice/domain/repo/invoice_repo.dart';
import 'package:xpro_delivery_admin_app/core/enums/invoice_status.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';
import 'package:xpro_delivery_admin_app/core/usecases/usecase.dart';
import 'package:equatable/equatable.dart';

class CreateInvoice extends UsecaseWithParams<InvoiceEntity, CreateInvoiceParams> {
  final InvoiceRepo _repo;
  const CreateInvoice(this._repo);

  @override
  ResultFuture<InvoiceEntity> call(CreateInvoiceParams params) => 
      _repo.createInvoice(
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

class CreateInvoiceParams extends Equatable {
  final String invoiceNumber;
  final String customerId;
  final String tripId;
  final List<String> productIds;
  final InvoiceStatus? status;
  final double? totalAmount;
  final double? confirmTotalAmount;
  final String? customerDeliveryStatus;

  const CreateInvoiceParams({
    required this.invoiceNumber,
    required this.customerId,
    required this.tripId,
    required this.productIds,
    this.status,
    this.totalAmount,
    this.confirmTotalAmount,
    this.customerDeliveryStatus,
  });

  @override
  List<Object?> get props => [
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
