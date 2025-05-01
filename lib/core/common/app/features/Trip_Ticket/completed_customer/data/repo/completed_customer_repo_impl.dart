import 'package:dartz/dartz.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/completed_customer/data/datasource/remote_datasource/completed_customer_remote_datasource.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/completed_customer/domain/entity/completed_customer_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/completed_customer/domain/repo/completed_customer_repo.dart';
import 'package:xpro_delivery_admin_app/core/errors/exceptions.dart';
import 'package:xpro_delivery_admin_app/core/errors/failures.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';
import 'package:flutter/foundation.dart';

class CompletedCustomerRepoImpl extends CompletedCustomerRepo {
  CompletedCustomerRepoImpl(this._remoteDataSource);

  final CompletedCustomerRemoteDatasource _remoteDataSource;

  @override
  ResultFuture<List<CompletedCustomerEntity>> getCompletedCustomers(String tripId) async {
    try {
      debugPrint('🔄 Fetching completed customers from remote source...');
      final remoteCustomers = await _remoteDataSource.getCompletedCustomers(tripId);
      return Right(remoteCustomers);
    } on ServerException catch (e) {
      debugPrint('⚠️ API Error: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  ResultFuture<CompletedCustomerEntity> getCompletedCustomerById(String customerId) async {
    try {
      debugPrint('🌐 Fetching completed customer data from remote: $customerId');
      final remoteCustomer = await _remoteDataSource.getCompletedCustomerById(customerId);
      
      debugPrint('📦 Remote data retrieved for completed customer:');
      debugPrint('   🏪 Store: ${remoteCustomer.storeName}');
      debugPrint('   🧾 Invoices: ${remoteCustomer.invoicesList.length}');
      debugPrint('   📝 Status Updates: ${remoteCustomer.deliveryStatus.length}');
      
      return Right(remoteCustomer);
    } on ServerException catch (e) {
      debugPrint('⚠️ Remote fetch failed: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  ResultFuture<List<CompletedCustomerEntity>> getAllCompletedCustomers() async {
    try {
      debugPrint('🔄 Fetching all completed customers from remote source...');
      final remoteCustomers = await _remoteDataSource.getAllCompletedCustomers();
      debugPrint('✅ Retrieved ${remoteCustomers.length} completed customers');
      return Right(remoteCustomers);
    } on ServerException catch (e) {
      debugPrint('⚠️ API Error: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
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
  }) async {
    try {
      debugPrint('🔄 Creating new completed customer...');
      final createdCustomer = await _remoteDataSource.createCompletedCustomer(
        deliveryNumber: deliveryNumber,
        storeName: storeName,
        ownerName: ownerName,
        contactNumber: contactNumber,
        address: address,
        municipality: municipality,
        province: province,
        modeOfPayment: modeOfPayment,
        timeCompleted: timeCompleted,
        totalAmount: totalAmount,
        totalTime: totalTime,
        tripId: tripId,
        transactionId: transactionId,
        customerId: customerId,
      );
      
      debugPrint('✅ Successfully created completed customer with ID: ${createdCustomer.id}');
      return Right(createdCustomer);
    } on ServerException catch (e) {
      debugPrint('⚠️ API Error: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
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
  }) async {
    try {
      debugPrint('🔄 Updating completed customer: $id');
      final updatedCustomer = await _remoteDataSource.updateCompletedCustomer(
        id: id,
        deliveryNumber: deliveryNumber,
        storeName: storeName,
        ownerName: ownerName,
        contactNumber: contactNumber,
        address: address,
        municipality: municipality,
        province: province,
        modeOfPayment: modeOfPayment,
        timeCompleted: timeCompleted,
        totalAmount: totalAmount,
        totalTime: totalTime,
        tripId: tripId,
        transactionId: transactionId,
        customerId: customerId,
      );
      
      debugPrint('✅ Successfully updated completed customer');
      return Right(updatedCustomer);
    } on ServerException catch (e) {
      debugPrint('⚠️ API Error: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  ResultFuture<bool> deleteCompletedCustomer(String id) async {
    try {
      debugPrint('🔄 Deleting completed customer: $id');
      final result = await _remoteDataSource.deleteCompletedCustomer(id);
      
      debugPrint('✅ Successfully deleted completed customer');
      return Right(result);
    } on ServerException catch (e) {
      debugPrint('⚠️ API Error: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  ResultFuture<bool> deleteAllCompletedCustomers(List<String> ids) async {
    try {
      debugPrint('🔄 Deleting multiple completed customers: ${ids.length} items');
      final result = await _remoteDataSource.deleteAllCompletedCustomers(ids);
      
      debugPrint('✅ Successfully deleted all completed customers');
      return Right(result);
    } on ServerException catch (e) {
      debugPrint('⚠️ API Error: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }
}
