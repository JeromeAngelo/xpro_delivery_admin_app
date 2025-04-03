
// update_product_quantities.dart
import 'package:desktop_app/core/common/app/features/Trip_Ticket/products/domain/repo/product_repo.dart';
import 'package:desktop_app/core/typedefs/typedefs.dart';
import 'package:desktop_app/core/usecases/usecase.dart';

class UpdateProductQuantities extends UsecaseWithParams<void, UpdateProductQuantitiesParams> {
  const UpdateProductQuantities(this._repo);

  final ProductRepo _repo;

  @override
  ResultFuture<void> call(UpdateProductQuantitiesParams params) {
    return _repo.updateProductQuantities(
      params.productId,
      unloadedProductCase: params.unloadedProductCase,
      unloadedProductPc: params.unloadedProductPc,
      unloadedProductPack: params.unloadedProductPack,
      unloadedProductBox: params.unloadedProductBox,
    );
  }
}

class UpdateProductQuantitiesParams {
  final String productId;
  final int unloadedProductCase;
  final int unloadedProductPc;
  final int unloadedProductPack;
  final int unloadedProductBox;

  const UpdateProductQuantitiesParams({
    required this.productId,
    required this.unloadedProductCase,
    required this.unloadedProductPc,
    required this.unloadedProductPack,
    required this.unloadedProductBox,
  });
}
