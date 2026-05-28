import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';

import '../../../../../../../errors/exceptions.dart';
import '../../../../../../../errors/failures.dart';
import '../../../../../../../typedefs/typedefs.dart';
import '../../../delivery_data/domain/entity/delivery_data_entity.dart';
import '../../domain/entity/delivery_receipt_entity.dart';
import '../../domain/repo/delivery_receipt_repo.dart';
import '../datasource/remote_datasource/delivery_receipt_remote_datasource.dart';

class DeliveryReceiptRepoImpl implements DeliveryReceiptRepo {
  const DeliveryReceiptRepoImpl({
    required DeliveryReceiptRemoteDatasource remoteDatasource,
  }) : _remoteDatasource = remoteDatasource;

  final DeliveryReceiptRemoteDatasource _remoteDatasource;

  @override
  ResultFuture<DeliveryReceiptEntity> getDeliveryReceiptByTripId(
    String tripId,
  ) async {
    try {
      debugPrint(
        '🌐 REPO: Fetching delivery receipt by trip ID from remote: $tripId',
      );

      final remoteReceipt = await _remoteDatasource.getDeliveryReceiptByTripId(
        tripId,
      );

      debugPrint(
        '✅ REPO: Successfully retrieved delivery receipt by trip ID from remote',
      );
      return Right(remoteReceipt);
    } on ServerException catch (e) {
      debugPrint('❌ REPO: Remote fetch failed: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      debugPrint('❌ REPO: Unexpected error: ${e.toString()}');
      return Left(ServerFailure(message: e.toString(), statusCode: '500'));
    }
  }

  @override
  ResultFuture<DeliveryReceiptEntity> getDeliveryReceiptByDeliveryDataId(
    String deliveryDataId,
  ) async {
    try {
      debugPrint(
        '🌐 REPO: Fetching delivery receipt by delivery data ID from remote: $deliveryDataId',
      );

      final remoteReceipt = await _remoteDatasource
          .getDeliveryReceiptByDeliveryDataId(deliveryDataId);

      debugPrint(
        '✅ REPO: Successfully retrieved delivery receipt by delivery data ID from remote',
      );
      return Right(remoteReceipt);
    } on ServerException catch (e) {
      debugPrint('❌ REPO: Remote fetch failed: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      debugPrint('❌ REPO: Unexpected error: ${e.toString()}');
      return Left(ServerFailure(message: e.toString(), statusCode: '500'));
    }
  }

  @override
  ResultFuture<List<DeliveryReceiptEntity>> getAllDeliveryReceipts() async {
    try {
      debugPrint('🌐 REPO: Fetching all delivery receipts from remote');

      final remoteReceipts = await _remoteDatasource.getAllDeliveryReceipts();

      debugPrint(
        '✅ REPO: Successfully fetched ${remoteReceipts.length} delivery receipts from remote',
      );
      return Right(remoteReceipts);
    } on ServerException catch (e) {
      debugPrint('❌ REPO: Remote fetch failed: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      debugPrint('❌ REPO: Unexpected error: ${e.toString()}');
      return Left(ServerFailure(message: e.toString(), statusCode: '500'));
    }
  }

  @override
  ResultFuture<DeliveryReceiptEntity> createDeliveryReceiptByDeliveryDataId({
    required String deliveryDataId,
    required String? status,
    required DateTime? dateTimeCompleted,
    required List<String>? customerImages,
    required String? customerSignature,
    required String? receiptFile,
  }) async {
    try {
      debugPrint(
        '🌐 REPO: Creating delivery receipt on remote for delivery data: $deliveryDataId',
      );
      debugPrint('📝 REPO: Status: $status');
      debugPrint(
        '📸 REPO: Customer images count: ${customerImages?.length ?? 0}',
      );
      debugPrint(
        '✍️ REPO: Has signature: ${customerSignature?.isNotEmpty ?? false}',
      );
      debugPrint(
        '📄 REPO: Has receipt file: ${receiptFile?.isNotEmpty ?? false}',
      );

      final remoteDeliveryReceipt = await _remoteDatasource
          .createDeliveryReceiptByDeliveryDataId(
            deliveryDataId: deliveryDataId,
            status: status,
            dateTimeCompleted: dateTimeCompleted,
            customerImages: customerImages,
            customerSignature: customerSignature,
            receiptFile: receiptFile,
          );

      debugPrint(
        '✅ REPO: Successfully created delivery receipt on remote: ${remoteDeliveryReceipt.id}',
      );
      return Right(remoteDeliveryReceipt);
    } on ServerException catch (e) {
      debugPrint('❌ REPO: Remote creation failed: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      debugPrint('❌ REPO: Unexpected error during creation: ${e.toString()}');
      return Left(ServerFailure(message: e.toString(), statusCode: '500'));
    }
  }

  @override
  ResultFuture<bool> deleteDeliveryReceipt(String id) async {
    try {
      debugPrint('🌐 REPO: Deleting delivery receipt from remote: $id');

      final result = await _remoteDatasource.deleteDeliveryReceipt(id);

      if (result) {
        debugPrint('✅ REPO: Successfully deleted delivery receipt from remote');
        return const Right(true);
      } else {
        debugPrint('⚠️ REPO: Remote deletion returned false');
        return Left(
          ServerFailure(
            message: 'Failed to delete delivery receipt from remote',
            statusCode: '500',
          ),
        );
      }
    } on ServerException catch (e) {
      debugPrint('❌ REPO: Remote deletion failed: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      debugPrint('❌ REPO: Unexpected error during deletion: ${e.toString()}');
      return Left(ServerFailure(message: e.toString(), statusCode: '500'));
    }
  }

  @override
  ResultFuture<Uint8List> generateDeliveryReceiptPdf(
    DeliveryDataEntity deliveryData,
  ) {
    // TODO: implement generateDeliveryReceiptPdf
    throw UnimplementedError();
  }
}
