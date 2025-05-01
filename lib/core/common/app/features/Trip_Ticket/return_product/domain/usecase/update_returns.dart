import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/return_product/domain/entity/return_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/return_product/domain/repo/return_repo.dart';
import 'package:xpro_delivery_admin_app/core/enums/product_return_reason.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';
import 'package:xpro_delivery_admin_app/core/usecases/usecase.dart';
import 'package:equatable/equatable.dart';

class UpdateReturn extends UsecaseWithParams<ReturnEntity, UpdateReturnParams> {
  const UpdateReturn(this._repo);

  final ReturnRepo _repo;

  @override
  ResultFuture<ReturnEntity> call(UpdateReturnParams params) => _repo.updateReturn(
    id: params.id,
    productName: params.productName,
    productDescription: params.productDescription,
    reason: params.reason,
    returnDate: params.returnDate,
    productQuantityCase: params.productQuantityCase,
    productQuantityPcs: params.productQuantityPcs,
    productQuantityPack: params.productQuantityPack,
    productQuantityBox: params.productQuantityBox,
    isCase: params.isCase,
    isPcs: params.isPcs,
    isBox: params.isBox,
    isPack: params.isPack,
    invoiceId: params.invoiceId,
    customerId: params.customerId,
    tripId: params.tripId,
  );
}

class UpdateReturnParams extends Equatable {
  final String id;
  final String? productName;
  final String? productDescription;
  final ProductReturnReason? reason;
  final DateTime? returnDate;
  final int? productQuantityCase;
  final int? productQuantityPcs;
  final int? productQuantityPack;
  final int? productQuantityBox;
  final bool? isCase;
  final bool? isPcs;
  final bool? isBox;
  final bool? isPack;
  final String? invoiceId;
  final String? customerId;
  final String? tripId;

  const UpdateReturnParams({
    required this.id,
    this.productName,
    this.productDescription,
    this.reason,
    this.returnDate,
    this.productQuantityCase,
    this.productQuantityPcs,
    this.productQuantityPack,
    this.productQuantityBox,
    this.isCase,
    this.isPcs,
    this.isBox,
    this.isPack,
    this.invoiceId,
    this.customerId,
    this.tripId,
  });

  @override
  List<Object?> get props => [
    id,
    productName,
    productDescription,
    reason,
    returnDate,
    productQuantityCase,
    productQuantityPcs,
    productQuantityPack,
    productQuantityBox,
    isCase,
    isPcs,
    isBox,
    isPack,
    invoiceId,
    customerId,
    tripId,
  ];
}
