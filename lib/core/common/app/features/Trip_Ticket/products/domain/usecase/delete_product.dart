import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/products/domain/repo/product_repo.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';
import 'package:xpro_delivery_admin_app/core/usecases/usecase.dart';

class DeleteProduct extends UsecaseWithParams<bool, String> {
  const DeleteProduct(this._repo);

  final ProductRepo _repo;

  @override
  ResultFuture<bool> call(String productId) => _repo.deleteProduct(productId);
}
