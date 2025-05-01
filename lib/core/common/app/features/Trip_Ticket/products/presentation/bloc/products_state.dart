import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/products/domain/entity/product_entity.dart';
import 'package:xpro_delivery_admin_app/core/enums/product_return_reason.dart';
import 'package:xpro_delivery_admin_app/core/enums/products_status.dart';
import 'package:equatable/equatable.dart';

abstract class ProductsState extends Equatable {
  const ProductsState();

  @override
  List<Object> get props => [];
}

class ProductsInitial extends ProductsState {
  const ProductsInitial();
}

class ProductsLoading extends ProductsState {
  const ProductsLoading();
}

class ProductsLoaded extends ProductsState {
  final List<ProductEntity> products;
  const ProductsLoaded(this.products);
  
  @override
  List<Object> get props => [products];
}

class InvoiceProductsLoaded extends ProductsState {
  final List<ProductEntity> products;
  final String invoiceId;
  
  const InvoiceProductsLoaded(
    this.products, 
    this.invoiceId, 
  );
  
  @override
  List<Object> get props => [products, invoiceId];
}

class ProductsError extends ProductsState {
  final String message;
  const ProductsError(this.message);
  
  @override
  List<Object> get props => [message];
}

class ProductStatusUpdated extends ProductsState {
  final String productId;
  final ProductsStatus status;
  
  const ProductStatusUpdated({
    required this.productId,
    required this.status,
  });
  
  @override
  List<Object> get props => [productId, status];
}

class ProductQuantitiesUpdated extends ProductsState {
  final String productId;
  final int unloadedProductCase;
  final int unloadedProductPc;
  final int unloadedProductPack;
  final int unloadedProductBox;

  const ProductQuantitiesUpdated({
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

class ProductAddedToReturn extends ProductsState {
  final String productId;
  final ProductReturnReason reason;
  final int returnProductCase;
  final int returnProductPc;
  final int returnProductPack;
  final int returnProductBox;
  
  const ProductAddedToReturn({
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

class ProductReturnReasonUpdated extends ProductsState {
  final String productId;
  final ProductReturnReason reason;
  final int returnProductCase;
  final int returnProductPc;
  final int returnProductPack;
  final int returnProductBox;
  
  const ProductReturnReasonUpdated({
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

class DeliveryProductsConfirmed extends ProductsState {
  final String invoiceId;
  final double confirmTotalAmount;
  final String customerId;
  
  const DeliveryProductsConfirmed({
    required this.invoiceId,
    required this.confirmTotalAmount,
    required this.customerId,
  });
  
  @override
  List<Object> get props => [invoiceId, confirmTotalAmount, customerId];
}

// New states for CRUD operations
class ProductCreated extends ProductsState {
  final ProductEntity product;
  
  const ProductCreated(this.product);
  
  @override
  List<Object> get props => [product];
}

class ProductUpdated extends ProductsState {
  final ProductEntity product;
  
  const ProductUpdated(this.product);
  
  @override
  List<Object> get props => [product];
}

class ProductDeleted extends ProductsState {
  final String id;
  
  const ProductDeleted(this.id);
  
  @override
  List<Object> get props => [id];
}

class ProductsDeleted extends ProductsState {
  final List<String> ids;
  
  const ProductsDeleted(this.ids);
  
  @override
  List<Object> get props => [ids];
}

class TotalAmountCalculated extends ProductsState {
  final String productId;
  
  const TotalAmountCalculated(this.productId);
  
  @override
  List<Object> get props => [productId];
}
