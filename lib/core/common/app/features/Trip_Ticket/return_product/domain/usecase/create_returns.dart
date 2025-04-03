import 'package:desktop_app/core/common/app/features/Trip_Ticket/return_product/domain/entity/return_entity.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/return_product/domain/repo/return_repo.dart';
import 'package:desktop_app/core/enums/product_return_reason.dart';
import 'package:desktop_app/core/typedefs/typedefs.dart';
import 'package:desktop_app/core/usecases/usecase.dart';
import 'package:equatable/equatable.dart';

class CreateReturn extends UsecaseWithParams<ReturnEntity, CreateReturnParams> {
  const CreateReturn(this._repo);

  final ReturnRepo _repo;

  @override
  ResultFuture<ReturnEntity> call(CreateReturnParams params) => _repo.createReturn(
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

class CreateReturnParams extends Equatable {
  final String productName;
  final String productDescription;
  final ProductReturnReason reason;
  final DateTime returnDate;
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

  const CreateReturnParams({
    required this.productName,
    required this.productDescription,
    required this.reason,
    required this.returnDate,
    required this.productQuantityCase,
    required this.productQuantityPcs,
    required this.productQuantityPack,
    required this.productQuantityBox,
    required this.isCase,
    required this.isPcs,
    required this.isBox,
    required this.isPack,
    this.invoiceId,
    this.customerId,
    this.tripId,
  });

  @override
  List<Object?> get props => [
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
