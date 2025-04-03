

import 'package:desktop_app/core/common/app/features/Trip_Ticket/products/domain/entity/product_entity.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/products/domain/repo/product_repo.dart';
import 'package:desktop_app/core/typedefs/typedefs.dart';
import 'package:desktop_app/core/usecases/usecase.dart';

class GetProduct extends UsecaseWithoutParams<List<ProductEntity>> {
  const GetProduct(this._repo);

  final ProductRepo _repo;

  @override
  ResultFuture<List<ProductEntity>> call() => _repo.getProducts();
}