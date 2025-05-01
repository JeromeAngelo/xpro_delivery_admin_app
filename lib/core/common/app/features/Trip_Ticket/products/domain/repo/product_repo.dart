import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/products/domain/entity/product_entity.dart';
import 'package:xpro_delivery_admin_app/core/enums/product_return_reason.dart';
import 'package:xpro_delivery_admin_app/core/enums/product_unit.dart';
import 'package:xpro_delivery_admin_app/core/enums/products_status.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';

abstract class ProductRepo {
  const ProductRepo();

  // Get operations
  ResultFuture<List<ProductEntity>> getProducts();
  ResultFuture<List<ProductEntity>> getProductsByInvoiceId(String invoiceId);
  
  // Create operation
  ResultFuture<ProductEntity> createProduct({
    required String name,
    required String description,
    required double? totalAmount,
    required int? case_,
    required int? pcs,
    required int? pack,
    required int? box,
    required double? pricePerCase,
    required double? pricePerPc,
    required ProductUnit primaryUnit,
    required ProductUnit secondaryUnit,
    String? image,
    String? invoiceId,
    String? customerId,
    bool? isCase,
    bool? isPc,
    bool? isPack,
    bool? isBox,
    bool? hasReturn,
  });
  
  // Update operations
  ResultFuture<ProductEntity> updateProduct({
    required String id,
    String? name,
    String? description,
    double? totalAmount,
    int? case_,
    int? pcs,
    int? pack,
    int? box,
    double? pricePerCase,
    double? pricePerPc,
    ProductUnit? primaryUnit,
    ProductUnit? secondaryUnit,
    String? image,
    String? invoiceId,
    String? customerId,
    bool? isCase,
    bool? isPc,
    bool? isPack,
    bool? isBox,
    bool? hasReturn,
  });
  
  // Delete operations
  ResultFuture<bool> deleteProduct(String id);
  ResultFuture<bool> deleteAllProducts(List<String> ids);
  
  // Specialized update operations
  ResultFuture<void> updateProductStatus(String productId, ProductsStatus status);
  
  ResultFuture<void> updateProductQuantities(
    String productId, {
    required int? unloadedProductCase,
    required int? unloadedProductPc,
    required int? unloadedProductPack,
    required int? unloadedProductBox,
  });

  ResultFuture<void> confirmDeliveryProducts(
    String invoiceId, 
    double confirmTotalAmount,
    String customerId,
  );

  ResultFuture<void> addToReturns(
    String productId, {
    required int? returnProductCase,
    required int? returnProductPc,
    required int? returnProductPack,
    required int? returnProductBox,
    required ProductReturnReason? reason,
  });

  ResultFuture<void> updateReturnReason(
    String productId,
    ProductReturnReason reason, {
    required int returnProductCase,
    required int returnProductPc,
    required int returnProductPack,
    required int returnProductBox,
  });

  ResultFuture<void> calculateTotalAmount(String productId);
}
