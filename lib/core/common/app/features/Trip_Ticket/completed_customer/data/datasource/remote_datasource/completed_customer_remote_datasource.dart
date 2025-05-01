import 'dart:convert';

import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/completed_customer/data/models/completed_customer_model.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/delivery_update/data/models/delivery_update_model.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/invoice/data/models/invoice_models.dart';
import 'package:xpro_delivery_admin_app/core/errors/exceptions.dart';
import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';

abstract class CompletedCustomerRemoteDatasource {
  Future<List<CompletedCustomerModel>> getCompletedCustomers(String tripId);
  Future<CompletedCustomerModel> getCompletedCustomerById(String customerId);
  Future<List<CompletedCustomerModel>> getAllCompletedCustomers();
  Future<CompletedCustomerModel> createCompletedCustomer({
    required String deliveryNumber,
    required String storeName,
    required String ownerName,
    required List<String> contactNumber,
    required String address,
    required String municipality,
    required String province,
    required String modeOfPayment,
    required DateTime timeCompleted,
    required double totalAmount,
    required String totalTime,
    required String tripId,
    String? transactionId,
    String? customerId,
  });
  Future<CompletedCustomerModel> updateCompletedCustomer({
    required String id,
    String? deliveryNumber,
    String? storeName,
    String? ownerName,
    List<String>? contactNumber,
    String? address,
    String? municipality,
    String? province,
    String? modeOfPayment,
    DateTime? timeCompleted,
    double? totalAmount,
    String? totalTime,
    String? tripId,
    String? transactionId,
    String? customerId,
  });
  Future<bool> deleteCompletedCustomer(String id);
  Future<bool> deleteAllCompletedCustomers(List<String> ids);
}

class CompletedCustomerRemoteDatasourceImpl
    implements CompletedCustomerRemoteDatasource {
  const CompletedCustomerRemoteDatasourceImpl({
    required PocketBase pocketBaseClient,
  }) : _pocketBaseClient = pocketBaseClient;

  final PocketBase _pocketBaseClient;
  
  @override
  Future<List<CompletedCustomerModel>> getCompletedCustomers(
    String tripId,
  ) async {
    try {
      // Extract trip ID if we received a JSON object
      String actualTripId;
      if (tripId.startsWith('{')) {
        final tripData = jsonDecode(tripId);
        actualTripId = tripData['id'];
      } else {
        actualTripId = tripId;
      }

      debugPrint('🎯 Using trip ID: $actualTripId');

      final records = await _pocketBaseClient
          .collection('completedCustomer')
          .getFullList(
            filter: 'trip = "$actualTripId"',
            expand: 'deliveryStatus,invoices,transaction,returns,customer,trip',
            sort: '-created',
          );

      debugPrint('✅ Retrieved ${records.length} completed customers from API');

      return records.map((record) {
        final mappedData = {
          'id': record.id,
          'collectionId': record.collectionId,
          'collectionName': record.collectionName,
          'deliveryNumber': record.data['deliveryNumber'] ?? '',
          'storeName': record.data['storeName'] ?? '',
          'ownerName': record.data['ownerName'] ?? '',
          'contactNumber': record.data['contactNumber'] ?? '',
          'address': record.data['address'] ?? '',
          'municipality': record.data['municipality'] ?? '',
          'province': record.data['province'] ?? '',
          'modeOfPayment': record.data['modeOfPayment'] ?? '',
          'timeCompleted': record.data['timeCompleted'],
          'totalAmount': record.data['totalAmount'],
          'trip': actualTripId,
          'expand': {
            'deliveryStatus':
                record.expand['deliveryStatus']
                    ?.map((status) => status.data)
                    .toList(),
            'invoices':
                record.expand['invoices']
                    ?.map((invoice) => invoice.data)
                    .toList(),
            'transaction':
                record.expand['transaction']
                    ?.map((transaction) => transaction.data)
                    .first,
            'returns':
                record.expand['returns']
                    ?.map((returnItem) => returnItem.data)
                    .toList(),
            'customer':
                record.expand['customer']
                    ?.map((customer) => customer.data)
                    .first,
            'trip': record.expand['trip']?.map((trip) => trip.data).first,
          },
        };
        return CompletedCustomerModel.fromJson(mappedData);
      }).toList();
    } catch (e) {
      debugPrint(
        '❌ Get Completed Customer Remote data fetch failed: ${e.toString()}',
      );
      throw ServerException(
        message: 'Failed to load completed customers: ${e.toString()}',
        statusCode: '500',
      );
    }
  }

  @override
  Future<CompletedCustomerModel> getCompletedCustomerById(
    String customerId,
  ) async {
    try {
      debugPrint('📍 Fetching data for completed customer: $customerId');

      final record = await _pocketBaseClient
          .collection('completedCustomer')
          .getOne(customerId, expand: 'deliveryStatus');

      final invoices = await _pocketBaseClient
          .collection('invoices')
          .getFullList(
            filter: 'customer = "$customerId"',
            expand: 'productList',
          );

      final deliveryStatusList =
          (record.expand['deliveryStatus'] as List?)?.map((status) {
            final statusRecord = status as RecordModel;
            return DeliveryUpdateModel.fromJson({
              'id': statusRecord.id,
              'collectionId': statusRecord.collectionId,
              'collectionName': statusRecord.collectionName,
              'title': statusRecord.data['title'] ?? '',
              'subtitle': statusRecord.data['subtitle'] ?? '',
              'time': statusRecord.data['time'] ?? '',
              'customer': statusRecord.data['customer'] ?? '',
              'isAssigned': statusRecord.data['isAssigned'] ?? false,
              'created': statusRecord.created.toString(),
              'updated': statusRecord.updated.toString(),
            });
          }).toList() ??
          [];

      final invoicesList =
          invoices
              .map(
                (invoice) => InvoiceModel.fromJson({
                  'id': invoice.id,
                  'collectionId': invoice.collectionId,
                  'collectionName': invoice.collectionName,
                  'invoiceNumber': invoice.data['invoiceNumber'] ?? '',
                  'status': invoice.data['status'] ?? '',
                  'productList': invoice.expand['productList'] ?? [],
                  'customer': invoice.data['customer'] ?? '',
                  'totalAmount': record.data['totalAmount'] ?? '0',
                  'created': invoice.created.toString(),
                  'updated': invoice.updated.toString(),
                }),
              )
              .toList();

      return CompletedCustomerModel(
        id: record.id,
        collectionId: record.collectionId,
        collectionName: record.collectionName,
        deliveryNumber: record.data['deliveryNumber'] ?? '',
        storeName: record.data['storeName'] ?? '',
        ownerName: record.data['ownerName'] ?? '',
        contactNumber: [record.data['contactNumber'] ?? ''],
        address: record.data['address'] ?? '',
        municipality: record.data['municipality'] ?? '',
        province: record.data['province'] ?? '',
        modeOfPayment: record.data['modeOfPayment'] ?? '',
        deliveryStatusList: deliveryStatusList,
        invoicesList: invoicesList,
        timeCompleted: DateTime.tryParse(record.data['timeCompleted'] ?? ''),
        totalAmount: double.tryParse(
          record.data['totalAmount']?.toString() ?? '0',
        ),
      );
    } catch (e) {
      debugPrint('❌ Error fetching completed customer: ${e.toString()}');
      throw ServerException(
        message: 'Failed to fetch completed customer: ${e.toString()}',
        statusCode: '500',
      );
    }
  }

  @override
  Future<List<CompletedCustomerModel>> getAllCompletedCustomers() async {
    try {
      debugPrint('🔄 Getting all completed customers');

      final records = await _pocketBaseClient
          .collection('completedCustomer')
          .getFullList(
            sort: '-created',

            expand: 'deliveryStatus,invoices,transaction,returns,customer,trip',
          );

      debugPrint('✅ Retrieved ${records.length} completed customers from API');

      return records.map((record) {
        final mappedData = {
          'id': record.id,
          'collectionId': record.collectionId,
          'collectionName': record.collectionName,
          'deliveryNumber': record.data['deliveryNumber'] ?? '',
          'storeName': record.data['storeName'] ?? '',
          'ownerName': record.data['ownerName'] ?? '',
          'contactNumber': record.data['contactNumber'] ?? '',
          'address': record.data['address'] ?? '',
          'municipality': record.data['municipality'] ?? '',
          'province': record.data['province'] ?? '',
          'modeOfPayment': record.data['modeOfPayment'] ?? '',
          'timeCompleted': record.data['timeCompleted'],
          'totalAmount': record.data['totalAmount'],
          'totalTime': record.data['totalTime'] ?? '',
          'trip': record.data['trip'] ?? '',
          'expand': {
            'deliveryStatus':
                record.expand['deliveryStatus']
                    ?.map((status) => status.data)
                    .toList(),
            'invoices':
                record.expand['invoices']
                    ?.map((invoice) => invoice.data)
                    .toList(),
            'transaction':
                record.expand['transaction']
                    ?.map((transaction) => transaction.data)
                    .first,
            'returns':
                record.expand['returns']
                    ?.map((returnItem) => returnItem.data)
                    .toList(),
            'customer':
                record.expand['customer']
                    ?.map((customer) => customer.data)
                    .first,
            'trip': record.expand['trip']?.map((trip) => trip.data).first,
          },
        };
        return CompletedCustomerModel.fromJson(mappedData);
      }).toList();
    } catch (e) {
      debugPrint('❌ Get All Completed Customers failed: ${e.toString()}');
      throw ServerException(
        message: 'Failed to load all completed customers: ${e.toString()}',
        statusCode: '500',
      );
    }
  }

  @override
  Future<CompletedCustomerModel> createCompletedCustomer({
    required String deliveryNumber,
    required String storeName,
    required String ownerName,
    required List<String> contactNumber,
    required String address,
    required String municipality,
    required String province,
    required String modeOfPayment,
    required DateTime timeCompleted,
    required double totalAmount,
    required String totalTime,
    required String tripId,
    String? transactionId,
    String? customerId,
  }) async {
    try {
      debugPrint('🔄 Creating new completed customer');

      final body = {
        'deliveryNumber': deliveryNumber,
        'storeName': storeName,
        'ownerName': ownerName,
        'contactNumber': contactNumber.join(','),
        'address': address,
        'municipality': municipality,
        'province': province,
        'modeOfPayment': modeOfPayment,
        'timeCompleted': timeCompleted.toIso8601String(),
        'totalAmount': totalAmount.toString(),
        'totalTime': totalTime,
        'trip': tripId,
      };

      if (transactionId != null) {
        body['transaction'] = transactionId;
      }

      if (customerId != null) {
        body['customer'] = customerId;
      }

      final record = await _pocketBaseClient
          .collection('completedCustomer')
          .create(body: body);

      // Fetch the created record with expanded relations
      final createdRecord = await _pocketBaseClient
          .collection('completedCustomer')
          .getOne(
            record.id,
            expand: 'deliveryStatus,invoices,transaction,returns,customer,trip',
          );

      debugPrint('✅ Successfully created completed customer: ${record.id}');

      final mappedData = {
        'id': createdRecord.id,
        'collectionId': createdRecord.collectionId,
        'collectionName': createdRecord.collectionName,
        'deliveryNumber': createdRecord.data['deliveryNumber'] ?? '',
        'storeName': createdRecord.data['storeName'] ?? '',
        'ownerName': createdRecord.data['ownerName'] ?? '',
        'contactNumber': createdRecord.data['contactNumber'] ?? '',
        'address': createdRecord.data['address'] ?? '',
        'municipality': createdRecord.data['municipality'] ?? '',
        'province': createdRecord.data['province'] ?? '',
        'modeOfPayment': createdRecord.data['modeOfPayment'] ?? '',
        'timeCompleted': createdRecord.data['timeCompleted'],
        'totalAmount': createdRecord.data['totalAmount'],
        'totalTime': createdRecord.data['totalTime'] ?? '',
        'trip': tripId,
        'expand': {
          'deliveryStatus':
              createdRecord.expand['deliveryStatus']
                  ?.map((status) => status.data)
                  .toList(),
          'invoices':
              createdRecord.expand['invoices']
                  ?.map((invoice) => invoice.data)
                  .toList(),
          'transaction':
              createdRecord.expand['transaction']
                  ?.map((transaction) => transaction.data)
                  .first,
          'returns':
              createdRecord.expand['returns']
                  ?.map((returnItem) => returnItem.data)
                  .toList(),
          'customer':
              createdRecord.expand['customer']
                  ?.map((customer) => customer.data)
                  .first,
          'trip': createdRecord.expand['trip']?.map((trip) => trip.data).first,
        },
      };

      return CompletedCustomerModel.fromJson(mappedData);
    } catch (e) {
      debugPrint('❌ Create Completed Customer failed: ${e.toString()}');
      throw ServerException(
        message: 'Failed to create completed customer: ${e.toString()}',
        statusCode: '500',
      );
    }
  }

  @override
  Future<CompletedCustomerModel> updateCompletedCustomer({
    required String id,
    String? deliveryNumber,
    String? storeName,
    String? ownerName,
    List<String>? contactNumber,
    String? address,
    String? municipality,
    String? province,
    String? modeOfPayment,
    DateTime? timeCompleted,
    double? totalAmount,
    String? totalTime,
    String? tripId,
    String? transactionId,
    String? customerId,
  }) async {
    try {
      debugPrint('🔄 Updating completed customer: $id');

      final body = <String, dynamic>{};

      if (deliveryNumber != null) body['deliveryNumber'] = deliveryNumber;
      if (storeName != null) body['storeName'] = storeName;
      if (ownerName != null) body['ownerName'] = ownerName;
      if (contactNumber != null)
        body['contactNumber'] = contactNumber.join(',');
      if (address != null) body['address'] = address;
      if (municipality != null) body['municipality'] = municipality;
      if (province != null) body['province'] = province;
      if (modeOfPayment != null) body['modeOfPayment'] = modeOfPayment;
      if (timeCompleted != null)
        body['timeCompleted'] = timeCompleted.toIso8601String();
      if (totalAmount != null) body['totalAmount'] = totalAmount.toString();
      if (totalTime != null) body['totalTime'] = totalTime;
      if (tripId != null) body['trip'] = tripId;
      if (transactionId != null) body['transaction'] = transactionId;
      if (customerId != null) body['customer'] = customerId;

      await _pocketBaseClient
          .collection('completedCustomer')
          .update(id, body: body);

      // Fetch the updated record with expanded relations
      final updatedRecord = await _pocketBaseClient
          .collection('completedCustomer')
          .getOne(
            id,
            expand: 'deliveryStatus,invoices,transaction,returns,customer,trip',
          );

      debugPrint('✅ Successfully updated completed customer');

      final mappedData = {
        'id': updatedRecord.id,
        'collectionId': updatedRecord.collectionId,
        'collectionName': updatedRecord.collectionName,
        'deliveryNumber': updatedRecord.data['deliveryNumber'] ?? '',
        'storeName': updatedRecord.data['storeName'] ?? '',
        'ownerName': updatedRecord.data['ownerName'] ?? '',
        'contactNumber': updatedRecord.data['contactNumber'] ?? '',
        'address': updatedRecord.data['address'] ?? '',
        'municipality': updatedRecord.data['municipality'] ?? '',
        'province': updatedRecord.data['province'] ?? '',
        'modeOfPayment': updatedRecord.data['modeOfPayment'] ?? '',
        'timeCompleted': updatedRecord.data['timeCompleted'],
        'totalAmount': updatedRecord.data['totalAmount'],
        'totalTime': updatedRecord.data['totalTime'] ?? '',
        'trip': updatedRecord.data['trip'] ?? '',
        'expand': {
          'deliveryStatus':
              updatedRecord.expand['deliveryStatus']
                  ?.map((status) => status.data)
                  .toList(),
          'invoices':
              updatedRecord.expand['invoices']
                  ?.map((invoice) => invoice.data)
                  .toList(),
          'transaction':
              updatedRecord.expand['transaction']
                  ?.map((transaction) => transaction.data)
                  .first,
          'returns':
              updatedRecord.expand['returns']
                  ?.map((returnItem) => returnItem.data)
                  .toList(),
          'customer':
              updatedRecord.expand['customer']
                  ?.map((customer) => customer.data)
                  .first,
          'trip': updatedRecord.expand['trip']?.map((trip) => trip.data).first,
        },
      };

      return CompletedCustomerModel.fromJson(mappedData);
    } catch (e) {
      debugPrint('❌ Update Completed Customer failed: ${e.toString()}');
      throw ServerException(
        message: 'Failed to update completed customer: ${e.toString()}',
        statusCode: '500',
      );
    }
  }

  @override
  Future<bool> deleteCompletedCustomer(String id) async {
    try {
      debugPrint('🔄 Deleting completed customer: $id');

      await _pocketBaseClient.collection('completedCustomer').delete(id);

      debugPrint('✅ Successfully deleted completed customer');
      return true;
    } catch (e) {
      debugPrint('❌ Delete Completed Customer failed: ${e.toString()}');
      throw ServerException(
        message: 'Failed to delete completed customer: ${e.toString()}',
        statusCode: '500',
      );
    }
  }

  @override
  Future<bool> deleteAllCompletedCustomers(List<String> ids) async {
    try {
      debugPrint(
        '🔄 Deleting multiple completed customers: ${ids.length} items',
      );

      for (final id in ids) {
        await _pocketBaseClient.collection('completedCustomer').delete(id);
      }

      debugPrint('✅ Successfully deleted all completed customers');
      return true;
    } catch (e) {
      debugPrint('❌ Delete All Completed Customers failed: ${e.toString()}');
      throw ServerException(
        message:
            'Failed to delete multiple completed customers: ${e.toString()}',
        statusCode: '500',
      );
    }
  }
}
