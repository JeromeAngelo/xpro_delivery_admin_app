import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/completed_customer/domain/entity/completed_customer_entity.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';

abstract class CompletedCustomerRepo {
  // Existing functions to keep
  ResultFuture<List<CompletedCustomerEntity>> getCompletedCustomers(String tripId);
  ResultFuture<CompletedCustomerEntity> getCompletedCustomerById(String customerId);
  // New functions
  ResultFuture<List<CompletedCustomerEntity>> getAllCompletedCustomers();
  
  ResultFuture<CompletedCustomerEntity> createCompletedCustomer({
    required String deliveryNumber,
    required String storeName,
    required String ownerName,
    required List<String> contactNumber,
    required String address,
    required String municipality,
    required String province,
    required String modeOfPayment,
    required DateTime timeCompleted,
    required double totalAmount,
    required String totalTime,
    required String tripId,
    String? transactionId,
    String? customerId,
  });
  
  ResultFuture<CompletedCustomerEntity> updateCompletedCustomer({
    required String id,
    String? deliveryNumber,
    String? storeName,
    String? ownerName,
    List<String>? contactNumber,
    String? address,
    String? municipality,
    String? province,
    String? modeOfPayment,
    DateTime? timeCompleted,
    double? totalAmount,
    String? totalTime,
    String? tripId,
    String? transactionId,
    String? customerId,
  });
  
  ResultFuture<bool> deleteCompletedCustomer(String id);
  
  ResultFuture<bool> deleteAllCompletedCustomers(List<String> ids);
}
