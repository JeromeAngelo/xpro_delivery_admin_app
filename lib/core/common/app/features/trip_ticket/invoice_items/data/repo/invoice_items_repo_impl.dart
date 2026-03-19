import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/trip_ticket/invoice_items/data/datasource/remote_datasource/invoice_items_remote_datasource.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/trip_ticket/invoice_items/data/model/invoice_items_model.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/trip_ticket/invoice_items/domain/entity/invoice_items_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/trip_ticket/invoice_items/domain/repo/invoice_items_repo.dart';
import 'package:xpro_delivery_admin_app/core/errors/exceptions.dart';
import 'package:xpro_delivery_admin_app/core/errors/failures.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';

class InvoiceItemsRepoImpl implements InvoiceItemsRepo {
  const InvoiceItemsRepoImpl(this._remoteDataSource);

  final InvoiceItemsRemoteDataSource _remoteDataSource;

  @override
  ResultFuture<List<InvoiceItemsEntity>> getInvoiceItemsByInvoiceDataId(String invoiceDataId) async {
    try {
      debugPrint('🌐 Fetching invoice items for invoice data ID: $invoiceDataId');
      final remoteInvoiceItems = await _remoteDataSource.getInvoiceItemsByInvoiceDataId(invoiceDataId);
      debugPrint('✅ Retrieved ${remoteInvoiceItems.length} invoice items for invoice data ID: $invoiceDataId');
      return Right(remoteInvoiceItems);
    } on ServerException catch (e) {
      debugPrint('⚠️ API Error: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  ResultFuture<List<InvoiceItemsEntity>> getAllInvoiceItems() async {
    try {
      debugPrint('🌐 Fetching all invoice items from remote');
      final remoteInvoiceItems = await _remoteDataSource.getAllInvoiceItems();
      debugPrint('✅ Retrieved ${remoteInvoiceItems.length} invoice items');
      return Right(remoteInvoiceItems);
    } on ServerException catch (e) {
      debugPrint('⚠️ API Error: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  ResultFuture<InvoiceItemsEntity> updateInvoiceItemById(InvoiceItemsEntity invoiceItem) async {
    try {
      debugPrint('🌐 Updating invoice item: ${invoiceItem.id}');
      
      // Convert entity to model if it's not already a model
      final invoiceItemModel = invoiceItem is InvoiceItemsModel 
          ? invoiceItem 
          : InvoiceItemsModel(
              id: invoiceItem.id,
              collectionId: invoiceItem.collectionId,
              collectionName: invoiceItem.collectionName,
              name: invoiceItem.name,
              brand: invoiceItem.brand,
              refId: invoiceItem.refId,
              uom: invoiceItem.uom,
              quantity: invoiceItem.quantity,
              totalBaseQuantity: invoiceItem.totalBaseQuantity,
              uomPrice: invoiceItem.uomPrice,
              totalAmount: invoiceItem.totalAmount,
              invoiceData: invoiceItem.invoiceData,
              created: invoiceItem.created,
              updated: invoiceItem.updated,
            );
      
      final updatedInvoiceItem = await _remoteDataSource.updateInvoiceItemById(invoiceItemModel);
      
      debugPrint('✅ Successfully updated invoice item');
      return Right(updatedInvoiceItem);
    } on ServerException catch (e) {
      debugPrint('⚠️ API Error: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }
}
