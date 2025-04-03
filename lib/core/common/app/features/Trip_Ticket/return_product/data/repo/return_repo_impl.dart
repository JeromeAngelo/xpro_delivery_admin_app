import 'package:dartz/dartz.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/return_product/data/datasource/remote_datasource/return_remote_datasource.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/return_product/domain/entity/return_entity.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/return_product/domain/repo/return_repo.dart';
import 'package:desktop_app/core/enums/product_return_reason.dart';
import 'package:desktop_app/core/errors/exceptions.dart';
import 'package:desktop_app/core/errors/failures.dart';
import 'package:desktop_app/core/typedefs/typedefs.dart';
import 'package:flutter/foundation.dart';

class ReturnRepoImpl extends ReturnRepo {
  const ReturnRepoImpl(this._remoteDataSource);

  final ReturnRemoteDatasource _remoteDataSource;

  @override
  ResultFuture<List<ReturnEntity>> getReturns(String tripId) async {
    try {
      debugPrint('🔄 Fetching returns from remote source...');
      final remoteReturns = await _remoteDataSource.getReturns(tripId);
      debugPrint('✅ Successfully fetched ${remoteReturns.length} returns');
      return Right(remoteReturns);
    } on ServerException catch (e) {
      debugPrint('⚠️ API Error: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }
  
  @override
  ResultFuture<ReturnEntity> getReturnByCustomerId(String customerId) async {
    try {
      final returnItem = await _remoteDataSource.getReturnByCustomerId(customerId);
      return Right(returnItem);
    } on ServerException catch (e) {
      debugPrint('⚠️ Remote fetch failed: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  ResultFuture<List<ReturnEntity>> getAllReturns() async {
    try {
      debugPrint('🔄 Fetching all returns from remote source...');
      final remoteReturns = await _remoteDataSource.getAllReturns();
      debugPrint('✅ Successfully fetched ${remoteReturns.length} returns');
      return Right(remoteReturns);
    } on ServerException catch (e) {
      debugPrint('⚠️ API Error: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
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
  }) async {
    try {
      debugPrint('🔄 Creating new return for product: $productName');
      final returnItem = await _remoteDataSource.createReturn(
        productName: productName,
        productDescription: productDescription,
        reason: reason,
        returnDate: returnDate,
        productQuantityCase: productQuantityCase,
        productQuantityPcs: productQuantityPcs,
        productQuantityPack: productQuantityPack,
        productQuantityBox: productQuantityBox,
        isCase: isCase,
        isPcs: isPcs,
        isBox: isBox,
        isPack: isPack,
        invoiceId: invoiceId,
        customerId: customerId,
        tripId: tripId,
      );
      debugPrint('✅ Return created successfully: ${returnItem.id}');
      return Right(returnItem);
    } on ServerException catch (e) {
      debugPrint('⚠️ Return creation failed: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
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
  }) async {
    try {
      debugPrint('🔄 Updating return: $id');
      final returnItem = await _remoteDataSource.updateReturn(
        id: id,
        productName: productName,
        productDescription: productDescription,
        reason: reason,
        returnDate: returnDate,
        productQuantityCase: productQuantityCase,
        productQuantityPcs: productQuantityPcs,
        productQuantityPack: productQuantityPack,
        productQuantityBox: productQuantityBox,
        isCase: isCase,
        isPcs: isPcs,
        isBox: isBox,
        isPack: isPack,
        invoiceId: invoiceId,
        customerId: customerId,
        tripId: tripId,
      );
      debugPrint('✅ Return updated successfully: ${returnItem.id}');
      return Right(returnItem);
    } on ServerException catch (e) {
      debugPrint('⚠️ Return update failed: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  ResultFuture<bool> deleteReturn(String id) async {
    try {
      debugPrint('🔄 Deleting return: $id');
      final result = await _remoteDataSource.deleteReturn(id);
      debugPrint('✅ Return deleted successfully');
      return Right(result);
    } on ServerException catch (e) {
      debugPrint('⚠️ Return deletion failed: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  ResultFuture<bool> deleteAllReturns(List<String> ids) async {
    try {
      debugPrint('🔄 Deleting multiple returns: ${ids.length} items');
      final result = await _remoteDataSource.deleteAllReturns(ids);
      debugPrint('✅ All returns deleted successfully');
      return Right(result);
    } on ServerException catch (e) {
      debugPrint('⚠️ Bulk return deletion failed: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }
}
