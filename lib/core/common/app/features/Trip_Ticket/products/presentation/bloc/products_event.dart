import 'package:xpro_delivery_admin_app/core/enums/product_return_reason.dart';
import 'package:xpro_delivery_admin_app/core/enums/product_unit.dart';
import 'package:xpro_delivery_admin_app/core/enums/products_status.dart';
import 'package:equatable/equatable.dart';

abstract class ProductsEvent extends Equatable {
  const ProductsEvent();
  
  @override
  List<Object?> get props => [];
}
  
class GetProductsEvent extends ProductsEvent {
  const GetProductsEvent();
}

class GetProductsByInvoiceIdEvent extends ProductsEvent {
  final String invoiceId;
  
  const GetProductsByInvoiceIdEvent(this.invoiceId);
  
  @override
  List<Object> get props => [invoiceId];
}

class UpdateProductStatusEvent extends ProductsEvent {
  const UpdateProductStatusEvent({
    required this.productId,
    required this.status,
  });
  
  final String productId;
  final ProductsStatus status;
  
  @override
  List<Object> get props => [productId, status];
}

class ConfirmDeliveryProductsEvent extends ProductsEvent {
  final String invoiceId;
  final double confirmTotalAmount;
  final String customerId;
  
  const ConfirmDeliveryProductsEvent({
    required this.invoiceId,
    required this.confirmTotalAmount,
    required this.customerId,
  });
  
  @override
  List<Object> get props => [invoiceId, confirmTotalAmount, customerId];
}

class AddToReturnEvent extends ProductsEvent {
  final String productId;
  final ProductReturnReason reason;
  final int returnProductCase;
  final int returnProductPc;
  final int returnProductPack;
  final int returnProductBox;
  
  const AddToReturnEvent({
    required this.productId,
    required this.reason,
    required this.returnProductCase,
    required this.returnProductPc,
    required this.returnProductPack,
    required this.returnProductBox,
  });
  
  @override
  List<Object> get props => [
    productId, 
    reason, 
    returnProductCase, 
    returnProductPc,
    returnProductPack,
    returnProductBox,
  ];
}

class UpdateReturnReasonEvent extends ProductsEvent {
  final String productId;
  final ProductReturnReason reason;
  final int returnProductCase;
  final int returnProductPc;
  final int returnProductPack;
  final int returnProductBox;
  
  const UpdateReturnReasonEvent({
    required this.productId,
    required this.reason,
    required this.returnProductCase,
    required this.returnProductPc,
    required this.returnProductPack,
    required this.returnProductBox,
  });
  
  @override
  List<Object> get props => [
    productId, 
    reason,
    returnProductCase,
    returnProductPc,
    returnProductPack,
    returnProductBox,
  ];
}

class UpdateProductQuantitiesEvent extends ProductsEvent {
  final String productId;
  final int unloadedProductCase;
  final int unloadedProductPc;
  final int unloadedProductPack;
  final int unloadedProductBox;

  const UpdateProductQuantitiesEvent({
    required this.productId,
    required this.unloadedProductCase,
    required this.unloadedProductPc,
    required this.unloadedProductPack,
    required this.unloadedProductBox,
  });

  @override
  List<Object> get props => [
    productId, 
    unloadedProductCase, 
    unloadedProductPc,
    unloadedProductPack,
    unloadedProductBox,
  ];
}

// New events for CRUD operations
class CreateProductEvent extends ProductsEvent {
  final String name;
  final String description;
  final double? totalAmount;
  final int? case_;
  final int? pcs;
  final int? pack;
  final int? box;
  final double? pricePerCase;
  final double? pricePerPc;
  final ProductUnit primaryUnit;
  final ProductUnit secondaryUnit;
  final String? image;
  final String? invoiceId;
  final String? customerId;
  final bool? isCase;
  final bool? isPc;
  final bool? isPack;
  final bool? isBox;
  final bool? hasReturn;

  const CreateProductEvent({
    required this.name,
    required this.description,
    this.totalAmount,
    this.case_,
    this.pcs,
    this.pack,
    this.box,
    this.pricePerCase,
    this.pricePerPc,
    required this.primaryUnit,
    required this.secondaryUnit,
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

class UpdateProductEvent extends ProductsEvent {
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

  const UpdateProductEvent({
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

class DeleteProductEvent extends ProductsEvent {
  final String id;
  
  const DeleteProductEvent(this.id);
  
  @override
  List<Object> get props => [id];
}

class DeleteAllProductsEvent extends ProductsEvent {
  final List<String> ids;
  
  const DeleteAllProductsEvent(this.ids);
  
  @override
  List<Object> get props => [ids];
}

class CalculateTotalAmountEvent extends ProductsEvent {
  final String productId;
  
  const CalculateTotalAmountEvent(this.productId);
  
  @override
  List<Object> get props => [productId];
}
