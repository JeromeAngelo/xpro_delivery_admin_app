import 'package:desktop_app/core/common/app/features/Trip_Ticket/products/domain/entity/product_entity.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/products/domain/repo/product_repo.dart';
import 'package:desktop_app/core/enums/product_unit.dart';
import 'package:desktop_app/core/typedefs/typedefs.dart';
import 'package:desktop_app/core/usecases/usecase.dart';
import 'package:equatable/equatable.dart';

class UpdateProduct extends UsecaseWithParams<ProductEntity, UpdateProductParams> {
  const UpdateProduct(this._repo);

  final ProductRepo _repo;

  @override
  ResultFuture<ProductEntity> call(UpdateProductParams params) => _repo.updateProduct(
    id: params.id,
    name: params.name,
    description: params.description,
    totalAmount: params.totalAmount,
    case_: params.case_,
    pcs: params.pcs,
    pack: params.pack,
    box: params.box,
    pricePerCase: params.pricePerCase,
    pricePerPc: params.pricePerPc,
    primaryUnit: params.primaryUnit,
    secondaryUnit: params.secondaryUnit,
    image: params.image,
    invoiceId: params.invoiceId,
    customerId: params.customerId,
    isCase: params.isCase,
    isPc: params.isPc,
    isPack: params.isPack,
    isBox: params.isBox,
    hasReturn: params.hasReturn,
  );
}

class UpdateProductParams extends Equatable {
  final String id;
  final String? name;
  final String? description;
  final double? totalAmount;
  final int? case_;
  final int? pcs;
  final int? pack;
  final int? box;
  final double? pricePerCase;
  final double? pricePerPc;
  final ProductUnit? primaryUnit;
  final ProductUnit? secondaryUnit;
  final String? image;
  final String? invoiceId;
  final String? customerId;
  final bool? isCase;
  final bool? isPc;
  final bool? isPack;
  final bool? isBox;
  final bool? hasReturn;

  const UpdateProductParams({
    required this.id,
    this.name,
    this.description,
    this.totalAmount,
    this.case_,
    this.pcs,
    this.pack,
    this.box,
    this.pricePerCase,
    this.pricePerPc,
    this.primaryUnit,
    this.secondaryUnit,
    this.image,
    this.invoiceId,
    this.customerId,
    this.isCase,
    this.isPc,
    this.isPack,
    this.isBox,
    this.hasReturn,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    totalAmount,
    case_,
    pcs,
    pack,
    box,
    pricePerCase,
    pricePerPc,
    primaryUnit,
    secondaryUnit,
    image,
    invoiceId,
    customerId,
    isCase,
    isPc,
    isPack,
    isBox,
    hasReturn,
  ];
}
