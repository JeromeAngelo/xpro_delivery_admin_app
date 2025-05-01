

import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/products/domain/repo/product_repo.dart';
import 'package:xpro_delivery_admin_app/core/enums/products_status.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';
import 'package:xpro_delivery_admin_app/core/usecases/usecase.dart';

class UpdateStatusProduct extends UsecaseWithParams<void, UpdateStatusParams> {
  const UpdateStatusProduct(this._repo);

  final ProductRepo _repo;
  
  @override
  ResultFuture<void> call(UpdateStatusParams params) =>
      _repo.updateProductStatus(params.productId, params.status);
}

class UpdateStatusParams {
  final String productId;
  final ProductsStatus status;

  const UpdateStatusParams({
    required this.productId,
    required this.status,
  });
}
