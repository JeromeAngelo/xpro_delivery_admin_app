import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';


import '../../../../../../../errors/exceptions.dart';
import '../../../../../../../errors/failures.dart';
import '../../../../../../../typedefs/typedefs.dart';
import '../../domain/entity/cancelled_invoice_entity.dart';
import '../../domain/repo/cancelled_invoice_repo.dart';
import '../datasources/remote_datasource/cancelled_invoice_remote_datasource.dart';
import '../model/cancelled_invoice_model.dart' show CancelledInvoiceModel;

class CancelledInvoiceRepoImpl implements CancelledInvoiceRepo {
  const CancelledInvoiceRepoImpl({
    required CancelledInvoiceRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final CancelledInvoiceRemoteDataSource _remoteDataSource;

  @override
  ResultFuture<List<CancelledInvoiceEntity>> loadCancelledInvoicesByTripId(String tripId) async {
    try {
      debugPrint('🌐 REPO: Loading cancelled invoices from remote for trip: $tripId');
      
      final remoteCancelledInvoices = await _remoteDataSource.loadCancelledInvoicesByTripId(tripId);
      
      debugPrint('✅ REPO: Successfully loaded ${remoteCancelledInvoices.length} cancelled invoices from remote');
      return Right(remoteCancelledInvoices);
    } on ServerException catch (e) {
      debugPrint('❌ REPO: Remote fetch failed: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      debugPrint('❌ REPO: Unexpected error: ${e.toString()}');
      return Left(ServerFailure(message: e.toString(), statusCode: '500'));
    }
  }

  @override
  ResultFuture<CancelledInvoiceEntity> loadCancelledInvoicesById(String id) async {
    try {
      debugPrint('🌐 REPO: Loading cancelled invoice from remote by ID: $id');
      
      final remoteCancelledInvoice = await _remoteDataSource.loadCancelledInvoiceById(id);
      
      debugPrint('✅ REPO: Successfully loaded cancelled invoice from remote');
      return Right(remoteCancelledInvoice);
    } on ServerException catch (e) {
      debugPrint('❌ REPO: Remote fetch failed: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      debugPrint('❌ REPO: Unexpected error: ${e.toString()}');
      return Left(ServerFailure(message: e.toString(), statusCode: '500'));
    }
  }
  
  @override
  ResultFuture<CancelledInvoiceEntity> createCancelledInvoice(
    CancelledInvoiceEntity cancelledInvoice,
    String deliveryDataId,
  ) async {
    try {
      debugPrint('🌐 REPO: Creating cancelled invoice on remote for delivery data: $deliveryDataId');
      debugPrint('📝 REPO: Reason: ${cancelledInvoice.reason.toString().split('.').last}');
      
      // Convert entity to model for remote data source
      final cancelledInvoiceModel = CancelledInvoiceModel.fromEntity(cancelledInvoice);
      
      // Create on remote
      final remoteCancelledInvoice = await _remoteDataSource.createCancelledInvoice(
        cancelledInvoiceModel,
        deliveryDataId,
      );
      
      debugPrint('✅ REPO: Successfully created cancelled invoice on remote');
      return Right(remoteCancelledInvoice);
    } on ServerException catch (e) {
      debugPrint('❌ REPO: Remote creation failed: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      debugPrint('❌ REPO: Unexpected error during creation: ${e.toString()}');
      return Left(ServerFailure(message: e.toString(), statusCode: '500'));
    }
  }

  @override
  ResultFuture<bool> deleteCancelledInvoice(String cancelledInvoiceId) async {
    try {
      debugPrint('🌐 REPO: Deleting cancelled invoice from remote: $cancelledInvoiceId');
      
      final result = await _remoteDataSource.deleteCancelledInvoice(cancelledInvoiceId);
      
      if (result) {
        debugPrint('✅ REPO: Successfully deleted cancelled invoice from remote');
        return const Right(true);
      } else {
        debugPrint('⚠️ REPO: Remote deletion returned false');
        return Left(ServerFailure(message: 'Failed to delete cancelled invoice from remote', statusCode: '500'));
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
ResultFuture<List<CancelledInvoiceEntity>> getAllCancelledInvoices() async {
  try {
    debugPrint('🌐 REPO: Loading all cancelled invoices from remote');
    
    final remoteCancelledInvoices = await _remoteDataSource.getAllCancelledInvoices();
    
    debugPrint('✅ REPO: Successfully loaded ${remoteCancelledInvoices.length} cancelled invoices from remote');
    return Right(remoteCancelledInvoices);
  } on ServerException catch (e) {
    debugPrint('❌ REPO: Remote fetch failed: ${e.message}');
    return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
  } catch (e) {
    debugPrint('❌ REPO: Unexpected error: ${e.toString()}');
    return Left(ServerFailure(message: e.toString(), statusCode: '500'));
  }
}

}
