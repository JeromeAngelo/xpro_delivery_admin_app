import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/invoice_items/data/model/invoice_items_model.dart';
import 'package:xpro_delivery_admin_app/core/errors/exceptions.dart';

abstract class InvoiceItemsRemoteDataSource {
  // Get invoice items by invoice data ID
  Future<List<InvoiceItemsModel>> getInvoiceItemsByInvoiceDataId(
    String invoiceDataId,
  );

  // Get all invoice items
  Future<List<InvoiceItemsModel>> getAllInvoiceItems();

  // Update invoice item by ID
  Future<InvoiceItemsModel> updateInvoiceItemById(
    InvoiceItemsModel invoiceItem,
  );
}

class InvoiceItemsRemoteDataSourceImpl implements InvoiceItemsRemoteDataSource {
  const InvoiceItemsRemoteDataSourceImpl({required PocketBase pocketBaseClient})
    : _pocketBaseClient = pocketBaseClient;

  final PocketBase _pocketBaseClient;
  static const String _authTokenKey = 'auth_token';
  static const String _authUserKey = 'auth_user';

  // Helper method to ensure PocketBase client is authenticated
  Future<void> _ensureAuthenticated() async {
    try {
      // Check if already authenticated
      if (_pocketBaseClient.authStore.isValid) {
        debugPrint('✅ PocketBase client already authenticated');
        return;
      }

      debugPrint('⚠️ PocketBase client not authenticated, attempting to restore from storage');

      // Try to restore authentication from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString(_authTokenKey);
      final userDataString = prefs.getString(_authUserKey);

      if (authToken != null && userDataString != null) {
        debugPrint('🔄 Restoring authentication from storage');

        // Restore the auth store with token only
        // The PocketBase client will handle the record validation
        _pocketBaseClient.authStore.save(authToken, null);
        
        debugPrint('✅ Authentication restored from storage');
      } else {
        debugPrint('❌ No stored authentication found');
        throw const ServerException(
          message: 'User not authenticated. Please log in again.',
          statusCode: '401',
        );
      }
    } catch (e) {
      debugPrint('❌ Failed to ensure authentication: ${e.toString()}');
      throw ServerException(
        message: 'Authentication error: ${e.toString()}',
        statusCode: '401',
      );
    }
  }

  @override
  Future<List<InvoiceItemsModel>> getInvoiceItemsByInvoiceDataId(
    String invoiceDataId,
  ) async {
    try {
      debugPrint(
        '🔄 Fetching invoice items for invoice data ID: $invoiceDataId',
      );
      
      // Ensure PocketBase client is authenticated
      await _ensureAuthenticated();

      final result = await _pocketBaseClient
          .collection('invoiceItems')
          .getFullList(
            expand: 'invoice',
            filter: 'invoice = "$invoiceDataId"',
            sort: '-created',
          );

      debugPrint(
        '✅ Retrieved ${result.length} invoice items for invoice data ID: $invoiceDataId',
      );

      List<InvoiceItemsModel> invoiceItems = [];

      for (var record in result) {
        final mappedData = {
          'id': record.id,
          'collectionId': record.collectionId,
          'collectionName': record.collectionName,
          'name': record.data['name'] ?? '',
          'brand': record.data['brand'] ?? '',
          'refId': record.data['refID'] ?? '',
          'uom': record.data['uom'] ?? '',
          'quantity': record.data['quantity'],
          'totalBaseQuantity': record.data['totalBaseQuantity'],
          'uomPrice': record.data['uomPrice'],
          'totalAmount': record.data['totalAmount'],

          'expand': {'invoiceData': record.expand['invoice']},
        };

        invoiceItems.add(InvoiceItemsModel.fromJson(mappedData));
      }

      return invoiceItems;
    } catch (e) {
      debugPrint(
        '❌ Failed to fetch invoice items by invoice data ID: ${e.toString()}',
      );
      throw ServerException(
        message:
            'Failed to load invoice items by invoice data ID: ${e.toString()}',
        statusCode: '500',
      );
    }
  }

  @override
  Future<List<InvoiceItemsModel>> getAllInvoiceItems() async {
    try {
      debugPrint('🔄 Fetching all invoice items');
      
      // Ensure PocketBase client is authenticated
      await _ensureAuthenticated();

      final result = await _pocketBaseClient
          .collection('invoiceItems')
          .getFullList(expand: 'invoice', sort: '-created');

      debugPrint('✅ Retrieved ${result.length} invoice items');

      List<InvoiceItemsModel> invoiceItems = [];

      for (var record in result) {
        final mappedData = {
          'id': record.id,
          'collectionId': record.collectionId,
          'collectionName': record.collectionName,
          'name': record.data['name'] ?? '',
          'brand': record.data['brand'] ?? '',
          'refId': record.data['refID'] ?? '',
          'uom': record.data['uom'] ?? '',
          'quantity': record.data['quantity'],
          'totalBaseQuantity': record.data['totalBaseQuantity'],
          'uomPrice': record.data['uomPrice'],
          'totalAmount': record.data['totalAmount'],

          'expand': {'invoiceData': record.expand['invoice']},
        };

        invoiceItems.add(InvoiceItemsModel.fromJson(mappedData));
      }

      return invoiceItems;
    } catch (e) {
      debugPrint('❌ Failed to fetch all invoice items: ${e.toString()}');
      throw ServerException(
        message: 'Failed to load all invoice items: ${e.toString()}',
        statusCode: '500',
      );
    }
  }

  @override
  Future<InvoiceItemsModel> updateInvoiceItemById(
    InvoiceItemsModel invoiceItem,
  ) async {
    try {
      if (invoiceItem.id == null) {
        throw ServerException(
          message: 'Invoice item ID is required for update',
          statusCode: '400',
        );
      }

      debugPrint('🔄 Updating invoice item: ${invoiceItem.id}');

      final body = {
        'name': invoiceItem.name ?? '',
        'brand': invoiceItem.brand ?? '',
        'refId': invoiceItem.refId ?? '',
        'uom': invoiceItem.uom ?? '',
        'quantity': invoiceItem.quantity?.toString() ?? '',
        'totalBaseQuantity': invoiceItem.totalBaseQuantity?.toString() ?? '',
        'uomPrice': invoiceItem.uomPrice?.toString() ?? '',
        'totalAmount': invoiceItem.totalAmount?.toString() ?? '',
      };

      // Only include invoice data if it's provided
      if (invoiceItem.invoiceData?.id != null) {
        body['invoice'] = invoiceItem.invoiceData!.id!;
      }

      final record = await _pocketBaseClient
          .collection('invoiceItems')
          .update(invoiceItem.id!, body: body);

      // Fetch the updated record with expanded relations
      final updatedRecord = await _pocketBaseClient
          .collection('invoiceItems')
          .getOne(record.id, expand: 'invoice');

      debugPrint('✅ Successfully updated invoice item: ${record.id}');

      final mappedData = {
        'id': updatedRecord.id,
        'collectionId': updatedRecord.collectionId,
        'collectionName': updatedRecord.collectionName,
        'name': updatedRecord.data['name'] ?? '',
        'brand': updatedRecord.data['brand'] ?? '',
        'refId': updatedRecord.data['refID'] ?? '',
        'uom': updatedRecord.data['uom'] ?? '',
        'quantity': updatedRecord.data['quantity'],
        'totalBaseQuantity': updatedRecord.data['totalBaseQuantity'],
        'uomPrice': updatedRecord.data['uomPrice'],
        'totalAmount': updatedRecord.data['totalAmount'],

        'expand': {'invoiceData': updatedRecord.expand['invoice']},
      };

      return InvoiceItemsModel.fromJson(mappedData);
    } catch (e) {
      debugPrint('❌ Failed to update invoice item: ${e.toString()}');
      throw ServerException(
        message: 'Failed to update invoice item: ${e.toString()}',
        statusCode: e is ServerException ? e.statusCode : '500',
      );
    }
  }
}
