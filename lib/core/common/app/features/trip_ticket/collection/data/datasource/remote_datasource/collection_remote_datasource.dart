import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pocketbase/pocketbase.dart' show PocketBase, RecordModel;

import '../../../../../../../../errors/exceptions.dart';
import '../../../../trip/data/models/trip_models.dart';
import '../../../../customer_data/data/model/customer_data_model.dart';
import '../../../../delivery_data/data/model/delivery_data_model.dart';
import '../../../../invoice_data/data/model/invoice_data_model.dart';
import '../../model/collection_model.dart';

abstract class CollectionRemoteDataSource {
  /// Load collections by trip ID from remote
  Future<List<CollectionModel>> getCollectionsByTripId(String tripId);

  /// Load collection by ID from remote
  Future<CollectionModel> getCollectionById(String collectionId);

  /// Delete collection from remote
  Future<bool> deleteCollection(String collectionId);

  /// Load all collections
  Future<List<CollectionModel>> getAllCollections();

  /// Filter collections by date range using created field
  Future<List<CollectionModel>> filterCollectionsByDate({
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Update a collection's totalAmount and mop in PocketBase
  Future<CollectionModel> updateCollection({
    required String collectionId,
    required double totalAmount,
    required String mop,
  });

  /// Fix delivery collections by matching deliveryData id with deliveryReceipt
  /// and copying totalAmount and mop from deliveryReceipt to collection
  Future<List<CollectionModel>> fixDeliveryCollections();
}

class CollectionRemoteDataSourceImpl implements CollectionRemoteDataSource {
  const CollectionRemoteDataSourceImpl({required PocketBase pocketBaseClient})
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

      debugPrint(
        '⚠️ PocketBase client not authenticated, attempting to restore from storage',
      );

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
  Future<List<CollectionModel>> getAllCollections() async {
    try {
      debugPrint('🔄 Fetching all collections');

      // Ensure PocketBase client is authenticated
      await _ensureAuthenticated();

      final records = await _pocketBaseClient
          .collection('deliveryCollection')
          .getFullList(
            expand: 'deliveryData,trip,customer,invoice,invoices',
            sort: '-created',
          );

      debugPrint('✅ Retrieved ${records.length} collections from API');

      List<CollectionModel> collections = [];

      for (var record in records) {
        collections.add(_processCollectionRecord(record));
      }

      debugPrint('✨ Successfully processed ${collections.length} collections');
      return collections;
    } catch (e) {
      debugPrint('❌ Failed to fetch all collections: ${e.toString()}');
      throw ServerException(
        message: 'Failed to load all collections: ${e.toString()}',
        statusCode: '500',
      );
    }
  }

  @override
  Future<List<CollectionModel>> getCollectionsByTripId(String tripId) async {
    try {
      // Extract trip ID if we received a JSON object
      String actualTripId;
      if (tripId.startsWith('{')) {
        final tripData = jsonDecode(tripId);
        actualTripId = tripData['id'];
      } else {
        actualTripId = tripId;
      }

      debugPrint('🔄 Fetching collections for trip ID: $actualTripId');

      final records = await _pocketBaseClient
          .collection('deliveryCollection')
          .getFullList(
            filter: 'trip = "$actualTripId"',
            expand: 'deliveryData,trip,customer,invoices',
            sort: '-created',
          );

      debugPrint('✅ Retrieved ${records.length} collections from API');

      List<CollectionModel> collections = [];

      for (var record in records) {
        collections.add(_processCollectionRecord(record));
      }

      debugPrint('✨ Successfully processed ${collections.length} collections');
      return collections;
    } catch (e) {
      debugPrint('❌ Collections fetch failed: ${e.toString()}');
      throw ServerException(
        message: 'Failed to load collections: ${e.toString()}',
        statusCode: '500',
      );
    }
  }

  @override
  Future<CollectionModel> getCollectionById(String collectionId) async {
    try {
      debugPrint('🔄 Fetching collection by ID: $collectionId');

      final record = await _pocketBaseClient
          .collection('deliveryCollection')
          .getOne(collectionId, expand: 'deliveryData,trip,customer,invoices');

      debugPrint('✅ Retrieved collection from API: ${record.id}');

      return _processCollectionRecord(record);
    } catch (e) {
      debugPrint('❌ Collection fetch failed: ${e.toString()}');
      throw ServerException(
        message: 'Failed to load collection: ${e.toString()}',
        statusCode: '500',
      );
    }
  }

  @override
  Future<bool> deleteCollection(String collectionId) async {
    try {
      debugPrint('🔄 Deleting collection: $collectionId');

      await _pocketBaseClient
          .collection('deliveryCollection')
          .delete(collectionId);

      debugPrint('✅ Successfully deleted collection: $collectionId');
      return true;
    } catch (e) {
      debugPrint('❌ Collection deletion failed: ${e.toString()}');
      throw ServerException(
        message: 'Failed to delete collection: ${e.toString()}',
        statusCode: '500',
      );
    }
  }

  // Helper method to process a collection record - matching delivery_data pattern
  CollectionModel _processCollectionRecord(RecordModel record) {
    debugPrint('🔄 Processing collection record: ${record.id}');
    debugPrint('📋 Raw record data: ${record.data}');
    debugPrint('📋 Record expand keys: ${record.expand.keys.toList()}');

    // Process delivery data
    DeliveryDataModel? deliveryDataModel;
    if (record.expand['deliveryData'] != null) {
      final deliveryDataData = record.expand['deliveryData'];
      if (deliveryDataData is List && deliveryDataData!.isNotEmpty) {
        final deliveryDataRecord = deliveryDataData[0];
        deliveryDataModel = DeliveryDataModel.fromJson({
          'id': deliveryDataRecord.id,
          'collectionId': deliveryDataRecord.collectionId,
          'collectionName': deliveryDataRecord.collectionName,
          ...deliveryDataRecord.data,
        });
        debugPrint('✅ Processed delivery data: ${deliveryDataModel.id}');
      }
    } else if (record.data['deliveryData'] != null) {
      deliveryDataModel = DeliveryDataModel(
        id: record.data['deliveryData'].toString(),
      );
      debugPrint(
        '📋 Using delivery data ID reference: ${deliveryDataModel.id}',
      );
    }

    // Process trip data
    TripModel? tripModel;
    if (record.expand['trip'] != null) {
      final tripData = record.expand['trip'];
      if (tripData is List && tripData!.isNotEmpty) {
        final tripRecord = tripData[0];
        tripModel = TripModel.fromJson({
          'id': tripRecord.id,
          'collectionId': tripRecord.collectionId,
          'collectionName': tripRecord.collectionName,
          'tripNumberId': tripRecord.data['tripNumberId'],
          'name': tripRecord.data['name'],
          'qrCode': tripRecord.data['qrCode'],
          'isAccepted': tripRecord.data['isAccepted'],
          'isEndTrip': tripRecord.data['isEndTrip'],
        });
        debugPrint(
          '✅ Processed trip: ${tripModel.id} - ${tripModel.tripNumberId}',
        );
      }
    } else if (record.data['trip'] != null) {
      tripModel = TripModel(id: record.data['trip'].toString());
      debugPrint('📋 Using trip ID reference: ${tripModel.id}');
    }

    // Process customer data
    CustomerDataModel? customerModel;
    if (record.expand['customer'] != null) {
      final customerData = record.expand['customer'];
      if (customerData is List && customerData!.isNotEmpty) {
        final customerRecord = customerData[0];
        customerModel = CustomerDataModel.fromJson({
          'id': customerRecord.id,
          'collectionId': customerRecord.collectionId,
          'collectionName': customerRecord.collectionName,
          'name': customerRecord.data['name'],
          'refId': customerRecord.data['refID'],
          ...customerRecord.data,
        });
        debugPrint(
          '✅ Processed customer: ${customerModel.id} - ${customerModel.name}',
        );
      }
    } else if (record.data['customer'] != null) {
      customerModel = CustomerDataModel(id: record.data['customer'].toString());
      debugPrint('📋 Using customer ID reference: ${customerModel.id}');
    }
    // Process invoices (multiple relation)
    List<InvoiceDataModel> invoicesList = [];
    if (record.expand['invoices'] != null) {
      final invoicesData = record.expand['invoices'];
      if (invoicesData is List) {
        invoicesList =
            invoicesData!.map((invoice) {
              return InvoiceDataModel.fromJson({
                'id': invoice.id,
                'collectionId': invoice.collectionId,
                'collectionName': invoice.collectionName,
                ...invoice.data,
                'expand': invoice.expand,
              });
            }).toList();
      }
    } else if (record.data['invoices'] != null &&
        record.data['invoices'] is List) {
      invoicesList =
          (record.data['invoices'] as List)
              .map((id) => InvoiceDataModel(id: id.toString()))
              .toList();
    }

    // Process invoice data
    InvoiceDataModel? invoiceModel;
    if (record.expand['invoice'] != null) {
      final invoiceData = record.expand['invoice'];
      if (invoiceData is List && invoiceData!.isNotEmpty) {
        final invoiceRecord = invoiceData[0];
        invoiceModel = InvoiceDataModel.fromJson({
          'id': invoiceRecord.id,
          'collectionId': invoiceRecord.collectionId,
          'collectionName': invoiceRecord.collectionName,
          ...invoiceRecord.data,
        });
        debugPrint(
          '✅ Processed invoice: ${invoiceModel.id} - Amount: ${invoiceModel.totalAmount}',
        );
      }
    } else if (record.data['invoice'] != null) {
      invoiceModel = InvoiceDataModel(id: record.data['invoice'].toString());
      debugPrint('📋 Using invoice ID reference: ${invoiceModel.id}');
    }

    // Parse totalAmount with fallback to invoice amount
    double? totalAmount;
    if (record.data['totalAmount'] != null) {
      if (record.data['totalAmount'] is double) {
        totalAmount = record.data['totalAmount'];
      } else if (record.data['totalAmount'] is int) {
        totalAmount = (record.data['totalAmount'] as int).toDouble();
      } else if (record.data['totalAmount'] is String) {
        totalAmount = double.tryParse(record.data['totalAmount']);
      }
    }

    debugPrint(
      '💰 Final totalAmount for collection ${record.id}: $totalAmount',
    );

    // Parse dates safely
    DateTime? parseDate(String? dateString) {
      if (dateString == null || dateString.isEmpty) return null;
      try {
        return DateTime.parse(dateString);
      } catch (e) {
        debugPrint('⚠️ Failed to parse date: $dateString');
        return null;
      }
    }

    final collection = CollectionModel(
      id: record.id,
      collectionId: record.collectionId,
      collectionName: record.collectionName,
      totalAmount: totalAmount,
      deliveryData: deliveryDataModel,
      trip: tripModel,
      customer: customerModel,
      invoices: invoicesList,
      mop: record.data['mop'],
      invoice: invoiceModel,
      status: record.data['status'],
      created: parseDate(record.created),
      updated: parseDate(record.updated),
    );

    debugPrint('✅ Successfully processed collection: ${collection.id}');
    debugPrint('📊 Collection summary:');
    debugPrint('   - ID: ${collection.id}');
    debugPrint('   - Total Amount: ${collection.totalAmount}');
    debugPrint('   - Customer: ${collection.customer?.name ?? "null"}');
    debugPrint('   - Invoice: ${collection.invoice?.id ?? "null"}');
    debugPrint('   - Trip: ${collection.trip?.tripNumberId ?? "null"}');

    return collection;
  }

  @override
  Future<List<CollectionModel>> filterCollectionsByDate({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      // Format dates to ISO 8601 format for PocketBase
      final formattedStartDate = _formatDateForPocketBase(startDate);
      final formattedEndDate = _formatDateForPocketBase(endDate);

      debugPrint('🔄 Filtering collections by date range');
      debugPrint('📅 Start Date: $formattedStartDate');
      debugPrint('📅 End Date: $formattedEndDate');

      // Create filter query for date range
      final filter =
          'created >= "$formattedStartDate" && created <= "$formattedEndDate"';

      debugPrint('🔍 Filter query: $filter');

      final records = await _pocketBaseClient
          .collection('deliveryCollection')
          .getFullList(
            filter: filter,
            expand: 'deliveryData,trip,customer,invoices',
            sort: '-created',
          );

      debugPrint(
        '✅ Retrieved ${records.length} collections from API for date range',
      );

      List<CollectionModel> collections = [];

      for (var record in records) {
        try {
          collections.add(_processCollectionRecord(record));
        } catch (e) {
          debugPrint('⚠️ Error processing collection record ${record.id}: $e');
          // Continue processing other records even if one fails
          continue;
        }
      }

      debugPrint(
        '✨ Successfully processed ${collections.length} collections for date range',
      );
      return collections;
    } catch (e) {
      debugPrint('❌ Failed to filter collections by date: ${e.toString()}');
      throw ServerException(
        message: 'Failed to filter collections by date: ${e.toString()}',
        statusCode: '500',
      );
    }
  }

  /// Helper method to format DateTime for PocketBase queries
  String _formatDateForPocketBase(DateTime date) {
    // Ensure the date is in UTC and formatted properly for PocketBase
    final utcDate = date.toUtc();

    // Format: YYYY-MM-DD HH:MM:SS.sssZ
    final formattedDate = utcDate.toIso8601String();

    debugPrint('🕐 Formatted date: $date -> $formattedDate');
    return formattedDate;
  }

  @override
  Future<CollectionModel> updateCollection({
    required String collectionId,
    required double totalAmount,
    required String mop,
  }) async {
    try {
      debugPrint(
        '🔄 Updating collection: $collectionId with totalAmount: $totalAmount, mop: $mop',
      );

      await _ensureAuthenticated();

      final record = await _pocketBaseClient
          .collection('deliveryCollection')
          .update(collectionId, body: {'totalAmount': totalAmount, 'mop': mop});

      debugPrint('✅ Successfully updated collection: ${record.id}');

      return _processCollectionRecord(record);
    } catch (e) {
      debugPrint('❌ Failed to update collection: ${e.toString()}');
      throw ServerException(
        message: 'Failed to update collection: ${e.toString()}',
        statusCode: '500',
      );
    }
  }

  @override
  Future<List<CollectionModel>> fixDeliveryCollections() async {
    try {
      debugPrint('🔧 FIX: Starting fix delivery collections process');

      await _ensureAuthenticated();

      // Step 1: Fetch collections and receipts in parallel
      debugPrint('🔧 FIX: Fetching collections and receipts in parallel');
      final fetchResults = await Future.wait([
        _pocketBaseClient
            .collection('deliveryCollection')
            .getFullList(sort: '-created'),
        _pocketBaseClient
            .collection('deliveryReceipt')
            .getFullList(sort: '-created'),
      ]);
      final collectionRecords = fetchResults[0];
      final receiptRecords = fetchResults[1];
      debugPrint(
        '🔧 FIX: Fetched ${collectionRecords.length} collections, ${receiptRecords.length} receipts',
      );

      // Step 2: Debug — log sample data to understand field structure
      if (collectionRecords.isNotEmpty) {
        debugPrint(
          '🔧 FIX: Sample collection data keys: ${collectionRecords.first.data.keys.toList()}',
        );
        debugPrint(
          '🔧 FIX: Sample collection data: ${collectionRecords.first.data}',
        );
      }
      if (receiptRecords.isNotEmpty) {
        debugPrint(
          '🔧 FIX: Sample receipt data keys: ${receiptRecords.first.data.keys.toList()}',
        );
        debugPrint('🔧 FIX: Sample receipt data: ${receiptRecords.first.data}');
      }

      // Step 3: Build receipt lookup map — receipt id -> {totalAmount, mop}
      final receiptById = <String, _ReceiptData>{};
      for (final receipt in receiptRecords) {
        final totalAmount = _parseDouble(receipt.data['totalAmount']);
        final mop = receipt.data['mop']?.toString();

        if (totalAmount != null || mop != null) {
          receiptById[receipt.id] = _ReceiptData(
            totalAmount: totalAmount,
            mop: mop,
          );
          debugPrint(
            '🔧 FIX: Receipt ${receipt.id} -> totalAmount: $totalAmount, mop: $mop',
          );
        } else {
          debugPrint('⚠️ FIX: Receipt ${receipt.id} has no totalAmount or mop');
        }
      }
      debugPrint(
        '🔧 FIX: Built receipt map with ${receiptById.length} entries (out of ${receiptRecords.length} receipts)',
      );

      // Step 4: Identify collections that need updating
      final updates = <_CollectionUpdate>[];
      int noReceiptField = 0;
      int noMatchingReceipt = 0;
      int alreadyMatched = 0;

      for (final record in collectionRecords) {
        // Try multiple possible field names for the receipt reference
        final receiptId =
            record.data['deliveryReceipt']?.toString() ??
            record.data['delivery_receipt']?.toString() ??
            record.data['receipt']?.toString();

        if (receiptId == null || receiptId.isEmpty) {
          debugPrint(
            '⚠️ FIX: Collection ${record.id} has no receipt reference field. Fields: ${record.data.keys.toList()}',
          );
          noReceiptField++;
          continue;
        }

        final receiptData = receiptById[receiptId];
        if (receiptData == null) {
          debugPrint(
            '⚠️ FIX: Collection ${record.id} references receipt $receiptId but not found in receipt map',
          );
          noMatchingReceipt++;
          continue;
        }

        final existingTotalAmount = _parseDouble(record.data['totalAmount']);
        final existingMop = record.data['mop']?.toString();

        final newTotalAmount =
            receiptData.totalAmount ?? existingTotalAmount ?? 0.0;
        final newMop = receiptData.mop ?? existingMop ?? '';

        debugPrint(
          '🔧 FIX: Collection ${record.id} | receipt: $receiptId | existing: totalAmount=$existingTotalAmount, mop=$existingMop | new: totalAmount=$newTotalAmount, mop=$newMop',
        );

        // Skip if values already match — no update needed
        if (existingTotalAmount == newTotalAmount && existingMop == newMop) {
          debugPrint(
            '⏭️ FIX: Collection ${record.id} already up to date, skipping',
          );
          alreadyMatched++;
          continue;
        }

        updates.add(
          _CollectionUpdate(
            id: record.id,
            totalAmount: newTotalAmount,
            mop: newMop,
          ),
        );
      }

      debugPrint(
        '🔧 FIX: ${updates.length} to update, $noReceiptField no receipt field, $noMatchingReceipt no matching receipt, $alreadyMatched already matched',
      );

      if (updates.isEmpty) {
        debugPrint('✅ FIX: All collections are already up to date');
        return [];
      }

      // Step 4: Batch update — run all updates in parallel (batches of 10)
      final updatedCollections = <CollectionModel>[];
      const batchSize = 10;

      for (var i = 0; i < updates.length; i += batchSize) {
        final batch = updates.sublist(
          i,
          (i + batchSize).clamp(0, updates.length),
        );

        final results = await Future.wait(
          batch.map((update) async {
            try {
              final record = await _pocketBaseClient
                  .collection('deliveryCollection')
                  .update(
                    update.id,
                    body: {
                      'totalAmount': update.totalAmount,
                      'mop': update.mop,
                    },
                  );
              debugPrint('✅ FIX: Updated collection ${update.id}');
              return _processCollectionRecord(record);
            } catch (e) {
              debugPrint('❌ FIX: Failed to update ${update.id}: $e');
              return null;
            }
          }),
        );

        updatedCollections.addAll(results.whereType<CollectionModel>());
      }

      debugPrint(
        '📊 FIX: Updated ${updatedCollections.length}/${updates.length} collections',
      );

      return updatedCollections;
    } catch (e) {
      debugPrint('❌ FIX: Failed to fix delivery collections: ${e.toString()}');
      throw ServerException(
        message: 'Failed to fix delivery collections: ${e.toString()}',
        statusCode: '500',
      );
    }
  }

  /// Helper to parse dynamic double values (int, double, String)
  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  /// Helper method to create date range for a specific day
  // Map<String, DateTime> _createDayRange(DateTime date) {
  //   final startOfDay = DateTime(date.year, date.month, date.day, 0, 0, 0);
  //   final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59, 999);

  //   return {
  //     'start': startOfDay,
  //     'end': endOfDay,
  //   };
  // }
}

/// Lightweight holder for receipt data used during fix matching
class _ReceiptData {
  const _ReceiptData({this.totalAmount, this.mop});
  final double? totalAmount;
  final String? mop;
}

/// Lightweight holder for a pending collection update
class _CollectionUpdate {
  const _CollectionUpdate({
    required this.id,
    required this.totalAmount,
    required this.mop,
  });
  final String id;
  final double totalAmount;
  final String mop;
}
