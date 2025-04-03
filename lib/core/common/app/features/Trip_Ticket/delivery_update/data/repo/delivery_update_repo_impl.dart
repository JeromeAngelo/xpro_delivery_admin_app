import 'package:dartz/dartz.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/delivery_update/data/datasource/remote_datasource/delivery_update_datasource.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/delivery_update/data/models/delivery_update_model.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/delivery_update/domain/entity/delivery_update_entity.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/delivery_update/domain/repo/delivery_update_repo.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/invoice/data/models/invoice_models.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/return_product/data/model/return_model.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/transaction/data/model/transaction_model.dart';
import 'package:desktop_app/core/errors/exceptions.dart';
import 'package:desktop_app/core/errors/failures.dart';
import 'package:desktop_app/core/typedefs/typedefs.dart';
import 'package:flutter/foundation.dart';

class DeliveryUpdateRepoImpl extends DeliveryUpdateRepo {
  const DeliveryUpdateRepoImpl(this._remoteDataSource);

  final DeliveryUpdateDatasource _remoteDataSource;

  @override
  ResultFuture<List<DeliveryUpdateEntity>> getDeliveryStatusChoices(String customerId) async {
    try {
      debugPrint('🌐 Fetching delivery status choices from remote');
      final remoteUpdates = await _remoteDataSource.getDeliveryStatusChoices(customerId);
      return Right(remoteUpdates);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  ResultFuture<void> updateDeliveryStatus(String customerId, String statusId) async {
    try {
      debugPrint('🌐 Updating delivery status in remote');
      await _remoteDataSource.updateDeliveryStatus(customerId, statusId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  ResultFuture<void> completeDelivery(
    String customerId, {
    required List<InvoiceModel> invoices,
    required List<TransactionModel> transactions,
    required List<ReturnModel> returns,
    required List<DeliveryUpdateModel> deliveryStatus,
  }) async {
    try {
      await _remoteDataSource.completeDelivery(
        customerId,
        invoices: invoices,
        transactions: transactions,
        returns: returns,
        deliveryStatus: deliveryStatus,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  ResultFuture<DataMap> checkEndDeliverStatus(String tripId) async {
    try {
      debugPrint('🔄 Checking delivery status for trip: $tripId');
      final remoteResult = await _remoteDataSource.checkEndDeliverStatus(tripId);
      return Right(remoteResult);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  ResultFuture<void> initializePendingStatus(List<String> customerIds) async {
    try {
      await _remoteDataSource.initializePendingStatus(customerIds);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  ResultFuture<void> createDeliveryStatus(
    String customerId, {
    required String title,
    required String subtitle,
    required DateTime time,
    required bool isAssigned,
    required String image,
  }) async {
    try {
      await _remoteDataSource.createDeliveryStatus(
        customerId,
        title: title,
        subtitle: subtitle,
        time: time,
        isAssigned: isAssigned,
        image: image,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  ResultFuture<void> updateQueueRemarks(
    String customerId,
    String queueCount,
  ) async {
    try {
      debugPrint('🌐 Updating queue remarks remotely');
      await _remoteDataSource.updateQueueRemarks(
        customerId,
        queueCount,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  // New implementations
  @override
  ResultFuture<List<DeliveryUpdateEntity>> getAllDeliveryUpdates() async {
    try {
      debugPrint('🔄 Fetching all delivery updates from remote');
      final remoteUpdates = await _remoteDataSource.getAllDeliveryUpdates();
      debugPrint('✅ Retrieved ${remoteUpdates.length} delivery updates');
      return Right(remoteUpdates);
    } on ServerException catch (e) {
      debugPrint('❌ Failed to get all delivery updates: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  ResultFuture<DeliveryUpdateEntity> createDeliveryUpdate({
    required String title,
    required String subtitle,
    required DateTime time,
    required String customerId,
    required bool isAssigned,
    String? assignedTo,
    String? image,
    String? remarks,
  }) async {
    try {
      debugPrint('🔄 Creating new delivery update');
      final createdUpdate = await _remoteDataSource.createDeliveryUpdate(
        title: title,
        subtitle: subtitle,
        time: time,
        customerId: customerId,
        isAssigned: isAssigned,
        assignedTo: assignedTo,
        image: image,
        remarks: remarks,
      );
      
      debugPrint('✅ Successfully created delivery update with ID: ${createdUpdate.id}');
      return Right(createdUpdate);
    } on ServerException catch (e) {
      debugPrint('❌ Failed to create delivery update: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  ResultFuture<DeliveryUpdateEntity> updateDeliveryUpdate({
    required String id,
    String? title,
    String? subtitle,
    DateTime? time,
    String? customerId,
    bool? isAssigned,
    String? assignedTo,
    String? image,
    String? remarks,
  }) async {
    try {
      debugPrint('🔄 Updating delivery update: $id');
      final updatedUpdate = await _remoteDataSource.updateDeliveryUpdate(
        id: id,
        title: title,
        subtitle: subtitle,
        time: time,
        customerId: customerId,
        isAssigned: isAssigned,
        assignedTo: assignedTo,
        image: image,
        remarks: remarks,
      );
      
      debugPrint('✅ Successfully updated delivery update');
      return Right(updatedUpdate);
    } on ServerException catch (e) {
      debugPrint('❌ Failed to update delivery update: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  ResultFuture<bool> deleteDeliveryUpdate(String id) async {
    try {
      debugPrint('🔄 Deleting delivery update: $id');
      final result = await _remoteDataSource.deleteDeliveryUpdate(id);
      
      debugPrint('✅ Successfully deleted delivery update');
      return Right(result);
    } on ServerException catch (e) {
      debugPrint('❌ Failed to delete delivery update: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  ResultFuture<bool> deleteAllDeliveryUpdates(List<String> ids) async {
    try {
      debugPrint('🔄 Deleting multiple delivery updates: ${ids.length} items');
      final result = await _remoteDataSource.deleteAllDeliveryUpdates(ids);
      
      debugPrint('✅ Successfully deleted all delivery updates');
      return Right(result);
    } on ServerException catch (e) {
      debugPrint('❌ Failed to delete delivery updates: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }
}
