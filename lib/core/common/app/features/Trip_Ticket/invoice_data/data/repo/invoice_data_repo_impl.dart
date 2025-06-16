import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/invoice_data/data/datasources/remote_datasource/invoice_data_remote_datasource.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/invoice_data/domain/entity/invoice_data_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/invoice_data/domain/repo/invoice_data_repo.dart';
import 'package:xpro_delivery_admin_app/core/errors/exceptions.dart';
import 'package:xpro_delivery_admin_app/core/errors/failures.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';

class InvoiceDataRepoImpl implements InvoiceDataRepo {
  const InvoiceDataRepoImpl(this._remoteDataSource);

  final InvoiceDataRemoteDataSource _remoteDataSource;

  @override
  ResultFuture<List<InvoiceDataEntity>> getAllInvoiceData() async {
    try {
      debugPrint('🌐 Fetching all invoice data from remote');
      final remoteInvoiceData = await _remoteDataSource.getAllInvoiceData();
      debugPrint('✅ Retrieved ${remoteInvoiceData.length} invoice data records');
      return Right(remoteInvoiceData);
    } on ServerException catch (e) {
      debugPrint('⚠️ API Error: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  ResultFuture<InvoiceDataEntity> getInvoiceDataById(String id) async {
    try {
      debugPrint('🌐 Fetching invoice data by ID: $id');
      final remoteInvoiceData = await _remoteDataSource.getInvoiceDataById(id);
      debugPrint('✅ Retrieved invoice data: ${remoteInvoiceData.id}');
      return Right(remoteInvoiceData);
    } on ServerException catch (e) {
      debugPrint('⚠️ API Error: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  ResultFuture<List<InvoiceDataEntity>> getInvoiceDataByDeliveryId(String deliveryId) async {
    try {
      debugPrint('🌐 Fetching invoice data for delivery: $deliveryId');
      final remoteInvoiceData = await _remoteDataSource.getInvoiceDataByDeliveryId(deliveryId);
      debugPrint('✅ Retrieved ${remoteInvoiceData.length} invoices for delivery');
      return Right(remoteInvoiceData);
    } on ServerException catch (e) {
      debugPrint('⚠️ API Error: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  ResultFuture<bool> addInvoiceDataToDelivery({
    required String invoiceId,
    required String deliveryId,
  }) async {
    try {
      debugPrint('🌐 Adding invoice $invoiceId to delivery $deliveryId');
      final result = await _remoteDataSource.addInvoiceDataToDelivery(
        invoiceId: invoiceId,
        deliveryId: deliveryId,
      );
      debugPrint('✅ Successfully added invoice to delivery');
      return Right(result);
    } on ServerException catch (e) {
      debugPrint('⚠️ API Error: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  ResultFuture<bool> addInvoiceDataToInvoiceStatus({
    required String invoiceId,
    required String invoiceStatusId,
  }) async {
    try {
      debugPrint('🌐 Adding invoice $invoiceId to invoice status $invoiceStatusId');
      final result = await _remoteDataSource.addInvoiceDataToInvoiceStatus(
        invoiceId: invoiceId,
        invoiceStatusId: invoiceStatusId,
      );
      debugPrint('✅ Successfully added invoice to invoice status');
      return Right(result);
    } on ServerException catch (e) {
      debugPrint('⚠️ API Error: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }
  
  
  @override
  ResultFuture<List<InvoiceDataEntity>> getInvoiceDataByCustomerId(String customerId) async {
    try {
      debugPrint('🌐 Fetching invoice data for customer: $customerId');
      final remoteInvoiceData = await _remoteDataSource.getInvoiceDataByCustomerId(customerId);
      debugPrint('✅ Retrieved ${remoteInvoiceData.length} invoices for customer');
      return Right(remoteInvoiceData);
    } on ServerException catch (e) {
      debugPrint('⚠️ API Error: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }
}
