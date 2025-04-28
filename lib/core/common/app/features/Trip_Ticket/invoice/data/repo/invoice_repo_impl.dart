import 'package:dartz/dartz.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/invoice/data/datasource/remote_data_source/invoice_remote_datasource.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/invoice/domain/entity/invoice_entity.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/invoice/domain/repo/invoice_repo.dart';
import 'package:desktop_app/core/enums/invoice_status.dart';
import 'package:desktop_app/core/errors/exceptions.dart';
import 'package:desktop_app/core/errors/failures.dart';
import 'package:desktop_app/core/typedefs/typedefs.dart';
import 'package:flutter/foundation.dart';

class InvoiceRepoImpl extends InvoiceRepo {
  const InvoiceRepoImpl(this._remoteDataSource);

  final InvoiceRemoteDatasource _remoteDataSource;

 @override
ResultFuture<List<InvoiceEntity>> getInvoices() async {
  try {
    debugPrint('🔄 Fetching invoices from remote source...');
    final remoteInvoices = await _remoteDataSource.getInvoices();
    debugPrint('✅ Successfully fetched ${remoteInvoices.length} invoices');
    
    // Add additional check for empty list
    if (remoteInvoices.isEmpty) {
      debugPrint('⚠️ No invoices returned from remote source');
    }
    
    return Right(remoteInvoices);
  } on ServerException catch (e) {
    debugPrint('⚠️ API Error: ${e.message}');
    return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
  } catch (e) {
    // Handle other exceptions
    debugPrint('❌ Unexpected error: $e');
    return Left(ServerFailure(message: e.toString(), statusCode: '500'));
  }
}


  @override
  ResultFuture<List<InvoiceEntity>> getInvoicesByCustomerId(String customerId) async {
    try {
      debugPrint('🔄 Fetching customer invoices from remote: $customerId');
      final remoteInvoices = await _remoteDataSource.getInvoicesByCustomerId(customerId);
      debugPrint('✅ Successfully fetched ${remoteInvoices.length} invoices for customer');
      return Right(remoteInvoices);
    } on ServerException catch (e) {
      debugPrint('⚠️ Remote fetch failed: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  ResultFuture<List<InvoiceEntity>> getInvoicesByTripId(String tripId) async {
    try {
      debugPrint('🔄 Fetching trip invoices from remote: $tripId');
      final remoteInvoices = await _remoteDataSource.getInvoicesByTripId(tripId);
      debugPrint('✅ Successfully fetched ${remoteInvoices.length} invoices for trip');
      return Right(remoteInvoices);
    } on ServerException catch (e) {
      debugPrint('⚠️ Remote fetch failed: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  ResultFuture<InvoiceEntity> createInvoice({
    required String invoiceNumber,
    required String customerId,
    required String tripId,
    required List<String> productIds,
    InvoiceStatus? status,
    double? totalAmount,
    double? confirmTotalAmount,
    String? customerDeliveryStatus,
  }) async {
    try {
      debugPrint('🔄 Creating new invoice: $invoiceNumber');
      final invoice = await _remoteDataSource.createInvoice(
        invoiceNumber: invoiceNumber,
        customerId: customerId,
        tripId: tripId,
        productIds: productIds,
        status: status,
        totalAmount: totalAmount,
        confirmTotalAmount: confirmTotalAmount,
        customerDeliveryStatus: customerDeliveryStatus,
      );
      debugPrint('✅ Successfully created invoice: ${invoice.id}');
      return Right(invoice);
    } on ServerException catch (e) {
      debugPrint('⚠️ Invoice creation failed: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  ResultFuture<InvoiceEntity> updateInvoice({
    required String id,
    String? invoiceNumber,
    String? customerId,
    String? tripId,
    List<String>? productIds,
    InvoiceStatus? status,
    double? totalAmount,
    double? confirmTotalAmount,
    String? customerDeliveryStatus,
  }) async {
    try {
      debugPrint('🔄 Updating invoice: $id');
      final invoice = await _remoteDataSource.updateInvoice(
        id: id,
        invoiceNumber: invoiceNumber,
        customerId: customerId,
        tripId: tripId,
        productIds: productIds,
        status: status,
        totalAmount: totalAmount,
        confirmTotalAmount: confirmTotalAmount,
        customerDeliveryStatus: customerDeliveryStatus,
      );
      debugPrint('✅ Successfully updated invoice: ${invoice.id}');
      return Right(invoice);
    } on ServerException catch (e) {
      debugPrint('⚠️ Invoice update failed: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  ResultFuture<bool> deleteInvoice(String id) async {
    try {
      debugPrint('🔄 Deleting invoice: $id');
      final result = await _remoteDataSource.deleteInvoice(id);
      debugPrint('✅ Successfully deleted invoice');
      return Right(result);
    } on ServerException catch (e) {
      debugPrint('⚠️ Invoice deletion failed: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  ResultFuture<bool> deleteAllInvoices(List<String> ids) async {
    try {
      debugPrint('🔄 Deleting multiple invoices: ${ids.length} items');
      final result = await _remoteDataSource.deleteAllInvoices(ids);
      debugPrint('✅ Successfully deleted all invoices');
      return Right(result);
    } on ServerException catch (e) {
      debugPrint('⚠️ Bulk invoice deletion failed: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }
  
  @override
ResultFuture<InvoiceEntity> getInvoiceById(String id) async {
  try {
    debugPrint('🔄 REPO: Fetching invoice by ID: $id');
    final invoice = await _remoteDataSource.getInvoiceById(id);
    debugPrint('✅ REPO: Successfully fetched invoice: ${invoice.id}');
    return Right(invoice);
  } on ServerException catch (e) {
    debugPrint('⚠️ REPO: Failed to get invoice: ${e.message}');
    return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
  }
}

 @override
ResultFuture<List<InvoiceEntity>> getInvoicesByCompletedCustomerId(String completedCustomerId) async {
  try {
    debugPrint('🔄 REPO: Fetching invoices by completed customer ID: $completedCustomerId');
    
    final invoices = await _remoteDataSource.getInvoicesByCompletedCustomerId(completedCustomerId);
    
    debugPrint('✅ REPO: Successfully retrieved ${invoices.length} invoices for completed customer');
    return Right(invoices);
  } on ServerException catch (e) {
    debugPrint('⚠️ REPO: Server exception while getting invoices by completed customer ID: ${e.message}');
    return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
  } catch (e) {
    debugPrint('❌ REPO: Unexpected error while getting invoices by completed customer ID: ${e.toString()}');
    return Left(ServerFailure(message: e.toString(), statusCode: '500'));
  }
}


}
