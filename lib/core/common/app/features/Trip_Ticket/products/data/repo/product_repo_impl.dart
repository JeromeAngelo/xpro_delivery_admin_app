import 'package:dartz/dartz.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/products/data/datasource/remote_datasource/product_remote_datasource.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/products/domain/entity/product_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/products/domain/repo/product_repo.dart';
import 'package:xpro_delivery_admin_app/core/enums/product_return_reason.dart';
import 'package:xpro_delivery_admin_app/core/enums/product_unit.dart';
import 'package:xpro_delivery_admin_app/core/enums/products_status.dart';
import 'package:xpro_delivery_admin_app/core/errors/exceptions.dart';
import 'package:xpro_delivery_admin_app/core/errors/failures.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';
import 'package:flutter/foundation.dart';

class ProductRepoImpl extends ProductRepo {
  const ProductRepoImpl(this._remoteDataSource);

  final ProductRemoteDatasource _remoteDataSource;

  @override
  ResultFuture<List<ProductEntity>> getProducts() async {
    try {
      debugPrint('🔄 Fetching products from remote source...');
      final remoteProducts = await _remoteDataSource.getProducts();
      debugPrint('✅ Successfully fetched ${remoteProducts.length} products');
      return Right(remoteProducts);
    } on ServerException catch (e) {
      debugPrint('⚠️ API Error: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  ResultFuture<List<ProductEntity>> getProductsByInvoiceId(String invoiceId) async {
    try {
      debugPrint('🔄 Fetching products from remote for invoice: $invoiceId');
      final remoteProducts = await _remoteDataSource.getProductsByInvoiceId(invoiceId);
      debugPrint('✅ Successfully fetched ${remoteProducts.length} products for invoice');
      return Right(remoteProducts);
    } on ServerException catch (e) {
      debugPrint('⚠️ API Error: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  ResultFuture<void> updateProductStatus(
      String productId, ProductsStatus status) async {
    try {
      await _remoteDataSource.updateProductStatus(productId, status);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  ResultFuture<void> updateProductQuantities(
    String productId, {
    required int? unloadedProductCase,
    required int? unloadedProductPc,
    required int? unloadedProductPack,
    required int? unloadedProductBox,
  }) async {
    try {
      await _remoteDataSource.updateProductQuantities(
        productId,
        unloadedProductCase: unloadedProductCase ?? 0,
        unloadedProductPc: unloadedProductPc ?? 0,
        unloadedProductPack: unloadedProductPack ?? 0,
        unloadedProductBox: unloadedProductBox ?? 0,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  ResultFuture<void> confirmDeliveryProducts(
    String invoiceId, 
    double confirmTotalAmount,
    String customerId,
  ) async {
    try {
      await _remoteDataSource.confirmDeliveryProducts(
        invoiceId, 
        confirmTotalAmount, 
        customerId
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  ResultFuture<void> addToReturns(
    String productId, {
    required int? returnProductCase,
    required int? returnProductPc,
    required int? returnProductPack,
    required int? returnProductBox,
    required ProductReturnReason? reason,
  }) async {
    try {
      await _remoteDataSource.addToReturn(
        productId,
        reason: reason ?? ProductReturnReason.none,
        returnProductCase: returnProductCase ?? 0,
        returnProductPc: returnProductPc ?? 0,
        returnProductPack: returnProductPack ?? 0,
        returnProductBox: returnProductBox ?? 0,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  ResultFuture<void> updateReturnReason(
    String productId,
    ProductReturnReason reason, {
    required int returnProductCase,
    required int returnProductPc,
    required int returnProductPack,
    required int returnProductBox,
  }) async {
    try {
      await _remoteDataSource.updateReturnReason(
        productId,
        reason,
        returnProductCase: returnProductCase,
        returnProductPc: returnProductPc,
        returnProductPack: returnProductPack,
        returnProductBox: returnProductBox,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  ResultFuture<void> calculateTotalAmount(String productId) async {
    try {
      await _remoteDataSource.calculateTotalAmount(productId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
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
  }) async {
    try {
      debugPrint('🔄 Creating new product: $name');
      final product = await _remoteDataSource.createProduct(
        name: name,
        description: description,
        totalAmount: totalAmount,
        case_: case_,
        pcs: pcs,
        pack: pack,
        box: box,
        pricePerCase: pricePerCase,
        pricePerPc: pricePerPc,
        primaryUnit: primaryUnit,
        secondaryUnit: secondaryUnit,
        image: image,
        invoiceId: invoiceId,
        customerId: customerId,
        isCase: isCase,
        isPc: isPc,
        isPack: isPack,
        isBox: isBox,
        hasReturn: hasReturn,
      );
      debugPrint('✅ Product created successfully: ${product.id}');
      return Right(product);
    } on ServerException catch (e) {
      debugPrint('⚠️ Product creation failed: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
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
  }) async {
    try {
      debugPrint('🔄 Updating product: $id');
      final product = await _remoteDataSource.updateProduct(
        id: id,
        name: name,
        description: description,
        totalAmount: totalAmount,
        case_: case_,
        pcs: pcs,
        pack: pack,
        box: box,
        pricePerCase: pricePerCase,
        pricePerPc: pricePerPc,
        primaryUnit: primaryUnit,
        secondaryUnit: secondaryUnit,
        image: image,
        invoiceId: invoiceId,
        customerId: customerId,
        isCase: isCase,
        isPc: isPc,
        isPack: isPack,
        isBox: isBox,
        hasReturn: hasReturn,
      );
      debugPrint('✅ Product updated successfully: ${product.id}');
      return Right(product);
    } on ServerException catch (e) {
      debugPrint('⚠️ Product update failed: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  ResultFuture<bool> deleteProduct(String id) async {
    try {
      debugPrint('🔄 Deleting product: $id');
      final result = await _remoteDataSource.deleteProduct(id);
      debugPrint('✅ Product deleted successfully');
      return Right(result);
    } on ServerException catch (e) {
      debugPrint('⚠️ Product deletion failed: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  ResultFuture<bool> deleteAllProducts(List<String> ids) async {
    try {
      debugPrint('🔄 Deleting multiple products: ${ids.length} items');
      final result = await _remoteDataSource.deleteAllProducts(ids);
      debugPrint('✅ All products deleted successfully');
      return Right(result);
    } on ServerException catch (e) {
      debugPrint('⚠️ Bulk product deletion failed: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }
}
