import 'package:dartz/dartz.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/customer/data/datasource/remote_datasource/customer_remote_data_source.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/customer/data/model/customer_model.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/customer/domain/entity/customer_entity.dart' show CustomerEntity;
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/customer/domain/repo/customer_repo.dart';
import 'package:xpro_delivery_admin_app/core/errors/exceptions.dart';
import 'package:xpro_delivery_admin_app/core/errors/failures.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';
import 'package:flutter/foundation.dart';

class CustomerRepoImpl extends CustomerRepo {
  const CustomerRepoImpl(this._remoteDataSource);

  final CustomerRemoteDataSource _remoteDataSource;

  @override
  ResultFuture<List<CustomerEntity>> getCustomers(String tripId) async {
    try {
      debugPrint('🌐 Fetching customers from remote for trip: $tripId');
      final remoteCustomers = await _remoteDataSource.getCustomers(tripId);
      return Right(remoteCustomers);
    } on ServerException catch (e) {
      debugPrint('⚠️ API Error: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  ResultFuture<CustomerEntity> getCustomerLocation(String customerId) async {
    try {
      debugPrint('🌐 Fetching customer location from remote');
      final remoteCustomer = await _remoteDataSource.getCustomerLocation(customerId);
      return Right(remoteCustomer);
    } on ServerException catch (e) {
      debugPrint('⚠️ API Error: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  ResultFuture<String> calculateCustomerTotalTime(String customerId) async {
    try {
      debugPrint('🔄 Calculating customer total time');
      final remoteTime = await _remoteDataSource.calculateCustomerTotalTime(customerId);
      return Right(remoteTime);
    } on ServerException catch (e) {
      debugPrint('⚠️ API Error: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  ResultFuture<List<CustomerEntity>> getAllCustomers() async {
    try {
      debugPrint('🔄 Fetching all customers from remote source');
      final remoteCustomers = await _remoteDataSource.getAllCustomers();
      debugPrint('✅ Retrieved ${remoteCustomers.length} customers');
      return Right(remoteCustomers);
    } on ServerException catch (e) {
      debugPrint('⚠️ API Error: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
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
  }) async {
    try {
      debugPrint('🔄 Creating new customer');
      final createdCustomer = await _remoteDataSource.createCustomer(
        deliveryNumber: deliveryNumber,
        storeName: storeName,
        ownerName: ownerName,
        contactNumber: contactNumber,
        address: address,
        municipality: municipality,
        province: province,
        modeOfPayment: modeOfPayment,
        tripId: tripId,
        totalAmount: totalAmount,
        latitude: latitude,
        longitude: longitude,
        notes: notes,
        remarks: remarks,
        hasNotes: hasNotes,
        confirmedTotalPayment: confirmedTotalPayment,
      );
      
      debugPrint('✅ Successfully created customer with ID: ${createdCustomer.id}');
      return Right(createdCustomer);
    } on ServerException catch (e) {
      debugPrint('⚠️ API Error: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
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
  }) async {
    try {
      debugPrint('🔄 Updating customer: $id');
      
      // Create a CustomerModel with the provided fields
      final customerModel = CustomerModel(
        id: id,
        deliveryNumber: deliveryNumber,
        storeName: storeName,
        ownerName: ownerName,
        contactNumber: contactNumber,
        address: address,
        municipality: municipality,
        province: province,
        modeOfPayment: modeOfPayment,
        totalAmount: totalAmount,
        latitude: latitude,
        longitude: longitude,
        notes: notes,
        remarks: remarks,
        hasNotes: hasNotes,
        confirmedTotalPayment: confirmedTotalPayment,
      );
      
      await _remoteDataSource.updateCustomer(customerModel);
      
      // Fetch the updated customer to return
      final updatedCustomer = await _remoteDataSource.getCustomerLocation(id);
      
      debugPrint('✅ Successfully updated customer');
      return Right(updatedCustomer);
    } on ServerException catch (e) {
      debugPrint('⚠️ API Error: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  ResultFuture<bool> deleteCustomer(String id) async {
    try {
      debugPrint('🔄 Deleting customer: $id');
      final result = await _remoteDataSource.deleteCustomer(id);
      
      debugPrint('✅ Successfully deleted customer');
      return Right(result);
    } on ServerException catch (e) {
      debugPrint('⚠️ API Error: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  ResultFuture<bool> deleteAllCustomers(List<String> ids) async {
    try {
      debugPrint('🔄 Deleting multiple customers: ${ids.length} items');
      final result = await _remoteDataSource.deleteAllCustomers(ids);
      
      debugPrint('✅ Successfully deleted all customers');
      return Right(result);
    } on ServerException catch (e) {
      debugPrint('⚠️ API Error: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }
  
 
  @override
  Stream<Either<Failure, List<CustomerEntity>>> watchCustomers(String tripId) {
    debugPrint('🔄 Setting up watch stream for customers in trip: $tripId');
    
    return _remoteDataSource.watchCustomers(tripId)
      .map((customers) => Right<Failure, List<CustomerEntity>>(customers))
      .handleError((error) {
        debugPrint('⚠️ Error in customer watch stream: $error');
        if (error is ServerException) {
          return Left<Failure, List<CustomerEntity>>(
            ServerFailure(message: error.message, statusCode: error.statusCode)
          );
        }
        return Left<Failure, List<CustomerEntity>>(
          ServerFailure(message: error.toString(), statusCode: '500')
        );
      });
  }
  
  @override
  Stream<Either<Failure, CustomerEntity>> watchCustomerLocation(String customerId) {
    debugPrint('🔄 Setting up watch stream for customer location: $customerId');
    
    return _remoteDataSource.watchCustomerLocation(customerId)
      .map((customer) => Right<Failure, CustomerEntity>(customer))
      .handleError((error) {
        debugPrint('⚠️ Error in customer location watch stream: $error');
        if (error is ServerException) {
          return Left<Failure, CustomerEntity>(
            ServerFailure(message: error.message, statusCode: error.statusCode)
          );
        }
        return Left<Failure, CustomerEntity>(
          ServerFailure(message: error.toString(), statusCode: '500')
        );
      });
  }
  
  @override
  Stream<Either<Failure, List<CustomerEntity>>> watchAllCustomers() {
    debugPrint('🔄 Setting up watch stream for all customers');
    
    return _remoteDataSource.watchAllCustomers()
      .map((customers) => Right<Failure, List<CustomerEntity>>(customers))
      .handleError((error) {
        debugPrint('⚠️ Error in all customers watch stream: $error');
        if (error is ServerException) {
          return Left<Failure, List<CustomerEntity>>(
            ServerFailure(message: error.message, statusCode: error.statusCode)
          );
        }
        return Left<Failure, List<CustomerEntity>>(
          ServerFailure(message: error.toString(), statusCode: '500')
        );
      });
  }
}
