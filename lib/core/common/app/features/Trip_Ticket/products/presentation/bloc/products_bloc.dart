import 'package:bloc/bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/products/domain/usecase/add_to_return_usecase.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/products/domain/usecase/confirm_delivery_products.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/products/domain/usecase/create_product.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/products/domain/usecase/delete_all_products.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/products/domain/usecase/delete_product.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/products/domain/usecase/get_product.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/products/domain/usecase/get_products_by_invoice_id.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/products/domain/usecase/update_product.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/products/domain/usecase/update_product_quantities.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/products/domain/usecase/update_return_reason_usecase.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/products/domain/usecase/update_status_product.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/products/presentation/bloc/products_event.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/products/presentation/bloc/products_state.dart';
import 'package:flutter/material.dart';

class ProductsBloc extends Bloc<ProductsEvent, ProductsState> {
  ProductsBloc({
    required GetProduct getProduct,
    required GetProductsByInvoice getProductsByInvoice,
    required UpdateStatusProduct updateStatusProduct,
    required ConfirmDeliveryProducts confirmDeliveryProducts,
    required AddToReturnUsecase addToReturn,
    required UpdateReturnReasonUsecase updateReturnReason,
    required UpdateProductQuantities updateProductQuantities,
    required CreateProduct createProduct,
    required UpdateProduct updateProduct,
    required DeleteProduct deleteProduct,
    required DeleteAllProducts deleteAllProducts,
  })  : _getProduct = getProduct,
        _getProductsByInvoice = getProductsByInvoice,
        _updateStatusProduct = updateStatusProduct,
        _confirmDeliveryProducts = confirmDeliveryProducts,
        _addToReturn = addToReturn,
        _updateReturnReason = updateReturnReason,
        _updateProductQuantities = updateProductQuantities,
        _createProduct = createProduct,
        _updateProduct = updateProduct,
        _deleteProduct = deleteProduct,
        _deleteAllProducts = deleteAllProducts,
        super(const ProductsInitial()) {
    on<GetProductsEvent>(_onGetProductHandler);
    on<GetProductsByInvoiceIdEvent>(_onGetProductsByInvoiceIdHandler);
    on<UpdateProductStatusEvent>(_onUpdateProductStatusHandler);
    on<ConfirmDeliveryProductsEvent>(_onConfirmDeliveryProductsHandler);
    on<AddToReturnEvent>(_onAddToReturnHandler);
    on<UpdateReturnReasonEvent>(_onUpdateReturnReasonHandler);
    on<UpdateProductQuantitiesEvent>(_onUpdateProductQuantitiesHandler);
    on<CreateProductEvent>(_onCreateProductHandler);
    on<UpdateProductEvent>(_onUpdateProductHandler);
    on<DeleteProductEvent>(_onDeleteProductHandler);
    on<DeleteAllProductsEvent>(_onDeleteAllProductsHandler);
  }

  final GetProduct _getProduct;
  final GetProductsByInvoice _getProductsByInvoice;
  final UpdateStatusProduct _updateStatusProduct;
  final ConfirmDeliveryProducts _confirmDeliveryProducts;
  final AddToReturnUsecase _addToReturn;
  final UpdateReturnReasonUsecase _updateReturnReason;
  final UpdateProductQuantities _updateProductQuantities;
  final CreateProduct _createProduct;
  final UpdateProduct _updateProduct;
  final DeleteProduct _deleteProduct;
  final DeleteAllProducts _deleteAllProducts;

  Future<void> _onGetProductsByInvoiceIdHandler(
    GetProductsByInvoiceIdEvent event,
    Emitter<ProductsState> emit,
  ) async {
    emit(const ProductsLoading());
    debugPrint('🔄 Loading products for invoice: ${event.invoiceId}');

    final result = await _getProductsByInvoice(event.invoiceId);
    result.fold(
      (failure) => emit(ProductsError(failure.message)),
      (products) {
        debugPrint('✅ Loaded ${products.length} products');
        emit(InvoiceProductsLoaded(products, event.invoiceId));
      },
    );
  }

  Future<void> _onGetProductHandler(
    GetProductsEvent event,
    Emitter<ProductsState> emit,
  ) async {
    emit(const ProductsLoading());
    final result = await _getProduct();
    result.fold(
      (failure) => emit(ProductsError(failure.message)),
      (products) => emit(ProductsLoaded(products)),
    );
  }

  Future<void> _onUpdateProductStatusHandler(
    UpdateProductStatusEvent event,
    Emitter<ProductsState> emit,
  ) async {
    final params = UpdateStatusParams(
      productId: event.productId,
      status: event.status,
    );

    final result = await _updateStatusProduct(params);
    result.fold(
      (failure) => emit(ProductsError(failure.message)),
      (_) => emit(ProductStatusUpdated(
        productId: event.productId,
        status: event.status,
      )),
    );
  }

  Future<void> _onConfirmDeliveryProductsHandler(
    ConfirmDeliveryProductsEvent event,
    Emitter<ProductsState> emit,
  ) async {
    final params = (event.invoiceId, event.confirmTotalAmount, event.customerId);
    final result = await _confirmDeliveryProducts(params);
    
    result.fold(
      (failure) => emit(ProductsError(failure.message)),
      (_) => emit(DeliveryProductsConfirmed(
        invoiceId: event.invoiceId,
        confirmTotalAmount: event.confirmTotalAmount,
        customerId: event.customerId,
      )),
    );
  }

  Future<void> _onAddToReturnHandler(
    AddToReturnEvent event,
    Emitter<ProductsState> emit,
  ) async {
    final params = AddToReturnParams(
      productId: event.productId,
      reason: event.reason,
      returnProductCase: event.returnProductCase,
      returnProductPc: event.returnProductPc,
      returnProductPack: event.returnProductPack,
      returnProductBox: event.returnProductBox,
    );

    final result = await _addToReturn(params);
    result.fold(
      (failure) => emit(ProductsError(failure.message)),
      (_) => emit(ProductAddedToReturn(
        productId: event.productId,
        reason: event.reason,
        returnProductCase: event.returnProductCase,
        returnProductPc: event.returnProductPc,
        returnProductPack: event.returnProductPack,
        returnProductBox: event.returnProductBox,
      )),
    );
  }

  Future<void> _onUpdateReturnReasonHandler(
    UpdateReturnReasonEvent event,
    Emitter<ProductsState> emit,
  ) async {
    final params = UpdateReasonParams(
      productId: event.productId,
      reason: event.reason,
      returnProductCase: event.returnProductCase,
      returnProductPc: event.returnProductPc,
      returnProductPack: event.returnProductPack,
      returnProductBox: event.returnProductBox,
    );

    final result = await _updateReturnReason(params);
    result.fold(
      (failure) => emit(ProductsError(failure.message)),
      (_) => emit(ProductReturnReasonUpdated(
        productId: event.productId,
        reason: event.reason,
        returnProductCase: event.returnProductCase,
        returnProductPc: event.returnProductPc,
        returnProductPack: event.returnProductPack,
        returnProductBox: event.returnProductBox,
      )),
    );
  }

  Future<void> _onUpdateProductQuantitiesHandler(
    UpdateProductQuantitiesEvent event,
    Emitter<ProductsState> emit,
  ) async {
    debugPrint('🔄 Bloc received quantities:');
    debugPrint('Product ID: ${event.productId}');
    debugPrint('Case: ${event.unloadedProductCase}');
    debugPrint('PC: ${event.unloadedProductPc}');

    final params = UpdateProductQuantitiesParams(
      productId: event.productId,
      unloadedProductCase: event.unloadedProductCase,
      unloadedProductPc: event.unloadedProductPc,
      unloadedProductPack: event.unloadedProductPack,
      unloadedProductBox: event.unloadedProductBox,
    );

    final result = await _updateProductQuantities(params);
    result.fold(
      (failure) => emit(ProductsError(failure.message)),
      (_) => emit(ProductQuantitiesUpdated(
        productId: event.productId,
        unloadedProductCase: event.unloadedProductCase,
        unloadedProductPc: event.unloadedProductPc,
        unloadedProductPack: event.unloadedProductPack,
        unloadedProductBox: event.unloadedProductBox,
      )),
    );
  }

  // New handlers for CRUD operations
  Future<void> _onCreateProductHandler(
    CreateProductEvent event,
    Emitter<ProductsState> emit,
  ) async {
    emit(const ProductsLoading());
    debugPrint('🔄 Creating new product: ${event.name}');

    final params = CreateProductParams(
      name: event.name,
      description: event.description,
      totalAmount: event.totalAmount,
      case_: event.case_,
      pcs: event.pcs,
      pack: event.pack,
      box: event.box,
      pricePerCase: event.pricePerCase,
      pricePerPc: event.pricePerPc,
      primaryUnit: event.primaryUnit,
      secondaryUnit: event.secondaryUnit,
      image: event.image,
      invoiceId: event.invoiceId,
      customerId: event.customerId,
      isCase: event.isCase,
      isPc: event.isPc,
      isPack: event.isPack,
      isBox: event.isBox,
      hasReturn: event.hasReturn,
    );

    final result = await _createProduct(params);
    result.fold(
      (failure) {
        debugPrint('❌ Product creation failed: ${failure.message}');
        emit(ProductsError(failure.message));
      },
      (product) {
        debugPrint('✅ Product created successfully: ${product.id}');
        emit(ProductCreated(product));
        
        // Refresh products list if invoice ID is provided
        if (event.invoiceId != null) {
          add(GetProductsByInvoiceIdEvent(event.invoiceId!));
        } else {
          add(const GetProductsEvent());
        }
      },
    );
  }

  Future<void> _onUpdateProductHandler(
    UpdateProductEvent event,
    Emitter<ProductsState> emit,
  ) async {
    emit(const ProductsLoading());
    debugPrint('🔄 Updating product: ${event.id}');

    final params = UpdateProductParams(
      id: event.id,
      name: event.name,
      description: event.description,
      totalAmount: event.totalAmount,
      case_: event.case_,
      pcs: event.pcs,
      pack: event.pack,
      box: event.box,
      pricePerCase: event.pricePerCase,
      pricePerPc: event.pricePerPc,
      primaryUnit: event.primaryUnit,
      secondaryUnit: event.secondaryUnit,
      image: event.image,
      invoiceId: event.invoiceId,
      customerId: event.customerId,
      isCase: event.isCase,
      isPc: event.isPc,
      isPack: event.isPack,
      isBox: event.isBox,
      hasReturn: event.hasReturn,
    );

    final result = await _updateProduct(params);
    result.fold(
      (failure) {
        debugPrint('❌ Product update failed: ${failure.message}');
        emit(ProductsError(failure.message));
      },
      (product) {
        debugPrint('✅ Product updated successfully: ${product.id}');
        emit(ProductUpdated(product));
        
        // Refresh products list if invoice ID is provided
        if (event.invoiceId != null) {
          add(GetProductsByInvoiceIdEvent(event.invoiceId!));
        } else {
          add(const GetProductsEvent());
        }
      },
    );
  }

  Future<void> _onDeleteProductHandler(
    DeleteProductEvent event,
    Emitter<ProductsState> emit,
  ) async {
    emit(const ProductsLoading());
    debugPrint('🔄 Deleting product: ${event.id}');

    final result = await _deleteProduct(event.id);
    result.fold(
      (failure) {
        debugPrint('❌ Product deletion failed: ${failure.message}');
        emit(ProductsError(failure.message));
      },
      (_) {
        debugPrint('✅ Product deleted successfully');
        emit(ProductDeleted(event.id));
        
        // Refresh products list
        add(const GetProductsEvent());
      },
    );
  }

  Future<void> _onDeleteAllProductsHandler(
    DeleteAllProductsEvent event,
    Emitter<ProductsState> emit,
  ) async {
    emit(const ProductsLoading());
    debugPrint('🔄 Deleting multiple products: ${event.ids.length} items');

    final result = await _deleteAllProducts(event.ids);
    result.fold(
      (failure) {
        debugPrint('❌ Bulk product deletion failed: ${failure.message}');
        emit(ProductsError(failure.message));
      },
      (_) {
        debugPrint('✅ All products deleted successfully');
        emit(ProductsDeleted(event.ids));
        
        // Refresh products list
        add(const GetProductsEvent());
      },
    );
  }

}
