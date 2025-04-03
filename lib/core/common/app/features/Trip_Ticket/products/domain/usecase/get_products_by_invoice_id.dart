
import 'package:desktop_app/core/common/app/features/Trip_Ticket/products/domain/entity/product_entity.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/products/domain/repo/product_repo.dart';
import 'package:desktop_app/core/typedefs/typedefs.dart';
import 'package:desktop_app/core/usecases/usecase.dart';

class GetProductsByInvoice extends UsecaseWithParams<List<ProductEntity>, String> {
  const GetProductsByInvoice(this._repo);

  final ProductRepo _repo;

  @override
  ResultFuture<List<ProductEntity>> call(String params) => _repo.getProductsByInvoiceId(params);
  
}

