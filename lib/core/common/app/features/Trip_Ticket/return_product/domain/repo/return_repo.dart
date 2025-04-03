import 'package:desktop_app/core/common/app/features/Trip_Ticket/return_product/domain/entity/return_entity.dart';
import 'package:desktop_app/core/enums/product_return_reason.dart';
import 'package:desktop_app/core/typedefs/typedefs.dart';

abstract class ReturnRepo {
  const ReturnRepo();

  // Get operations
  ResultFuture<List<ReturnEntity>> getReturns(String tripId);
  ResultFuture<ReturnEntity> getReturnByCustomerId(String customerId);
  ResultFuture<List<ReturnEntity>> getAllReturns();
  
  // Create operation
  ResultFuture<ReturnEntity> createReturn({
    required String productName,
    required String productDescription,
    required ProductReturnReason reason,
    required DateTime returnDate,
    required int? productQuantityCase,
    required int? productQuantityPcs,
    required int? productQuantityPack,
    required int? productQuantityBox,
    required bool? isCase,
    required bool? isPcs,
    required bool? isBox,
    required bool? isPack,
    String? invoiceId,
    String? customerId,
    String? tripId,
  });
  
  // Update operation
  ResultFuture<ReturnEntity> updateReturn({
    required String id,
    String? productName,
    String? productDescription,
    ProductReturnReason? reason,
    DateTime? returnDate,
    int? productQuantityCase,
    int? productQuantityPcs,
    int? productQuantityPack,
    int? productQuantityBox,
    bool? isCase,
    bool? isPcs,
    bool? isBox,
    bool? isPack,
    String? invoiceId,
    String? customerId,
    String? tripId,
  });
  
  // Delete operations
  ResultFuture<bool> deleteReturn(String id);
  ResultFuture<bool> deleteAllReturns(List<String> ids);
}
