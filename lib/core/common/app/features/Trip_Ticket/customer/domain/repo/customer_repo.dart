

import 'package:dartz/dartz.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/customer/domain/entity/customer_entity.dart';
import 'package:xpro_delivery_admin_app/core/errors/failures.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';

abstract class CustomerRepo {
  const CustomerRepo();

  ResultFuture<List<CustomerEntity>> getCustomers(String tripId);
  ResultFuture<CustomerEntity> getCustomerLocation(String customerId);
 
  ResultFuture<String> calculateCustomerTotalTime(String customerId);
// New functions
  ResultFuture<List<CustomerEntity>> getAllCustomers();
  
  ResultFuture<CustomerEntity> createCustomer({
    required String deliveryNumber,
    required String storeName,
    required String ownerName,
    required List<String> contactNumber,
    required String address,
    required String municipality,
    required String province,
    required String modeOfPayment,
    required String tripId,
    String? totalAmount,
    String? latitude,
    String? longitude,
    String? notes,
    String? remarks,
    bool? hasNotes,
    double? confirmedTotalPayment,
  });
  
  ResultFuture<CustomerEntity> updateCustomer({
    required String id,
    String? deliveryNumber,
    String? storeName,
    String? ownerName,
    List<String>? contactNumber,
    String? address,
    String? municipality,
    String? province,
    String? modeOfPayment,
    String? tripId,
    String? totalAmount,
    String? latitude,
    String? longitude,
    String? notes,
    String? remarks,
    bool? hasNotes,
    double? confirmedTotalPayment,
  });
  
  ResultFuture<bool> deleteCustomer(String id);
  
  ResultFuture<bool> deleteAllCustomers(List<String> ids);

  // Realtime watch functionality
    Stream<Either<Failure, List<CustomerEntity>>> watchCustomers(String tripId);
    Stream<Either<Failure, CustomerEntity>> watchCustomerLocation(String customerId);
    Stream<Either<Failure, List<CustomerEntity>>> watchAllCustomers();
}


