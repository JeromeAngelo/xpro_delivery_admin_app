
// update_return_reason_usecase.dart
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/products/domain/repo/product_repo.dart';
import 'package:xpro_delivery_admin_app/core/enums/product_return_reason.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';
import 'package:xpro_delivery_admin_app/core/usecases/usecase.dart';

class UpdateReturnReasonUsecase extends UsecaseWithParams<void, UpdateReasonParams> {
  const UpdateReturnReasonUsecase(this._repo);

  final ProductRepo _repo;
  
  @override
  ResultFuture<void> call(UpdateReasonParams params) =>
      _repo.updateReturnReason(
        params.productId,
        params.reason,
        returnProductCase: params.returnProductCase,
        returnProductPc: params.returnProductPc,
        returnProductPack: params.returnProductPack,
        returnProductBox: params.returnProductBox,
      );
}

class UpdateReasonParams {
  final String productId;
  final ProductReturnReason reason;
  final int returnProductCase;
  final int returnProductPc;
  final int returnProductPack;
  final int returnProductBox;

  const UpdateReasonParams({
    required this.productId,
    required this.reason,
    required this.returnProductCase,
    required this.returnProductPc,
    required this.returnProductPack,
    required this.returnProductBox,
  });
}