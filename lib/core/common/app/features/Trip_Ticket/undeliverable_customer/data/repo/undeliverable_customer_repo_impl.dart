import 'package:dartz/dartz.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/undeliverable_customer/data/datasources/remote_datasource/undeliverable_customer_remote_datasrc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/undeliverable_customer/data/model/undeliverable_customer_model.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/undeliverable_customer/domain/entity/undeliverable_customer_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/undeliverable_customer/domain/repo/undeliverable_repo.dart';
import 'package:xpro_delivery_admin_app/core/enums/undeliverable_reason.dart';
import 'package:xpro_delivery_admin_app/core/errors/exceptions.dart';
import 'package:xpro_delivery_admin_app/core/errors/failures.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';
import 'package:flutter/material.dart';

class UndeliverableCustomerRepoImpl implements UndeliverableRepo {
  const UndeliverableCustomerRepoImpl({
    required UndeliverableCustomerRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final UndeliverableCustomerRemoteDataSource _remoteDataSource;

  @override
  ResultFuture<List<UndeliverableCustomerEntity>> getUndeliverableCustomers(String tripId) async {
    try {
      final remoteCustomers = await _remoteDataSource.getUndeliverableCustomers(tripId);
      return Right(remoteCustomers);
    } on ServerException catch (e) {
      debugPrint('❌ Server error: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  ResultFuture<UndeliverableCustomerEntity> getUndeliverableCustomerById(String customerId) async {
    try {
      final customer = await _remoteDataSource.getUndeliverableCustomerById(customerId);
      return Right(customer);
    } on ServerException catch (e) {
      debugPrint('❌ Server error: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  ResultFuture<List<UndeliverableCustomerEntity>> getAllUndeliverableCustomers() async {
    try {
      final customers = await _remoteDataSource.getAllUndeliverableCustomers();
      return Right(customers);
    } on ServerException catch (e) {
      debugPrint('❌ Server error: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  ResultFuture<UndeliverableCustomerEntity> createUndeliverableCustomer(
    UndeliverableCustomerEntity undeliverableCustomer,
    String customerId,
  ) async {
    try {
      final customerModel = UndeliverableCustomerModel.fromJson(
        (undeliverableCustomer as UndeliverableCustomerModel).toJson(),
      );
      
      debugPrint('🌐 Creating undeliverable customer in remote');
      final remoteCustomer = await _remoteDataSource.createUndeliverableCustomer(
        customerModel,
        customerId,
      );
      
      return Right(remoteCustomer);
    } on ServerException catch (e) {
      debugPrint('❌ Server error: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  ResultFuture<UndeliverableCustomerEntity> updateUndeliverableCustomer(
    UndeliverableCustomerEntity undeliverableCustomer,
    String customerId,
  ) async {
    try {
      final customerModel = UndeliverableCustomerModel.fromJson(
        (undeliverableCustomer as UndeliverableCustomerModel).toJson(),
      );
      
      debugPrint('🌐 Updating undeliverable customer in remote');
      await _remoteDataSource.updateUndeliverableCustomer(customerModel, customerId);
      
      // Since the remote datasource doesn't return the updated entity,
      // we'll return the model that was passed in
      return Right(undeliverableCustomer);
    } on ServerException catch (e) {
      debugPrint('❌ Server error: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  ResultFuture<bool> deleteUndeliverableCustomer(String undeliverableCustomerId) async {
    try {
      await _remoteDataSource.deleteUndeliverableCustomer(undeliverableCustomerId);
      return const Right(true);
    } on ServerException catch (e) {
      debugPrint('❌ Server error: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  ResultFuture<bool> deleteAllUndeliverableCustomers() async {
    try {
      final result = await _remoteDataSource.deleteAllUndeliverableCustomers();
      return Right(result);
    } on ServerException catch (e) {
      debugPrint('❌ Server error: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  ResultFuture<UndeliverableCustomerEntity> setUndeliverableReason(
    String customerId, 
    UndeliverableReason reason
  ) async {
    try {
      await _remoteDataSource.setUndeliverableReason(customerId, reason);
      
      // Since the remote datasource doesn't return the updated entity,
      // we'll fetch the updated entity
      final updatedCustomer = await _remoteDataSource.getUndeliverableCustomerById(customerId);
      return Right(updatedCustomer);
    } on ServerException catch (e) {
      debugPrint('❌ Server error: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }
}
