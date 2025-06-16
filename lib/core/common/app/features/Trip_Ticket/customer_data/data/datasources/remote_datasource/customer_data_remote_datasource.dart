import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/customer_data/data/model/customer_data_model.dart';
import 'package:xpro_delivery_admin_app/core/errors/exceptions.dart'
    show ServerException;

abstract class CustomerDataRemoteDataSource {
  // CRUD Operations
  Future<List<CustomerDataModel>> getAllCustomerData();
  Future<CustomerDataModel> getCustomerDataById(String id);
  Future<CustomerDataModel> createCustomerData({
    required String name,
    required String refId,
    required String province,
    required String municipality,
    required String barangay,
    double? longitude,
    double? latitude,
  });
  Future<CustomerDataModel> updateCustomerData({
    required String id,
    String? name,
    String? refId,
    String? province,
    String? municipality,
    String? barangay,
    double? longitude,
    double? latitude,
  });
  Future<bool> deleteCustomerData(String id);
  Future<bool> deleteAllCustomerData(List<String> ids);

  // Additional Operations
  Future<bool> addCustomerToDelivery({
    required String customerId,
    required String deliveryId,
  });
  Future<List<CustomerDataModel>> getCustomersByDeliveryId(String deliveryId);
}

class CustomerDataRemoteDataSourceImpl implements CustomerDataRemoteDataSource {
  const CustomerDataRemoteDataSourceImpl({required PocketBase pocketBaseClient})
    : _pocketBaseClient = pocketBaseClient;

  final PocketBase _pocketBaseClient;

  @override
  Future<List<CustomerDataModel>> getAllCustomerData() async {
    try {
      debugPrint('🔄 Fetching all customer data from remote');

      final result = await _pocketBaseClient
          .collection('customerData')
          .getFullList(sort: '-created');

      debugPrint('✅ Retrieved ${result.length} customer data records');

      return result.map((record) {
        return CustomerDataModel.fromJson({
          'id': record.id,
          'collectionId': record.collectionId,
          'collectionName': record.collectionName,
          'name': record.data['name'],
          'refId': record.data['refId'],
          'province': record.data['province'],
          'ownerName': record.data['ownerName'],
          'paymentMode':record.data['paymentMode'],
          'contactNumber':record.data['contactNumber'],
          'municipality': record.data['municipality'],
          'barangay': record.data['barangay'],
          'longitude': record.data['longitude'],
          'latitude': record.data['latitude'],
        });
      }).toList();
    } catch (e) {
      debugPrint('❌ Failed to fetch customer data: ${e.toString()}');
      throw ServerException(
        message: 'Failed to load customer data: ${e.toString()}',
        statusCode: '500',
      );
    }
  }

  @override
  Future<CustomerDataModel> getCustomerDataById(String id) async {
    try {
      debugPrint('🔄 Fetching customer data by ID: $id');

      final record = await _pocketBaseClient
          .collection('customerData')
          .getOne(id);

      debugPrint('✅ Retrieved customer data: ${record.id}');

      return CustomerDataModel.fromJson({
        'id': record.id,
        'collectionId': record.collectionId,
        'collectionName': record.collectionName,
        'name': record.data['name'],
        'ownerName': record.data['ownerName'],
          'paymentMode':record.data['paymentMode'],
          'contactNumber':record.data['contactNumber'],
        'refId': record.data['refId'],
        'province': record.data['province'],
        'municipality': record.data['municipality'],
        'barangay': record.data['barangay'],
        'longitude': record.data['longitude'],
        'latitude': record.data['latitude'],
      });
    } catch (e) {
      debugPrint('❌ Failed to fetch customer data by ID: ${e.toString()}');
      throw ServerException(
        message: 'Failed to load customer data: ${e.toString()}',
        statusCode: '404',
      );
    }
  }

  @override
  Future<CustomerDataModel> createCustomerData({
    required String name,
    required String refId,
    required String province,
    required String municipality,
    required String barangay,
    double? longitude,
    double? latitude,
  }) async {
    try {
      debugPrint('🔄 Creating new customer data');

      final body = {
        'name': name,
        'refId': refId,
        'province': province,
        'municipality': municipality,
        'barangay': barangay,
      };

      if (longitude != null) body['longitude'] = longitude.toString();
      if (latitude != null) body['latitude'] = latitude.toString();

      final record = await _pocketBaseClient
          .collection('customerData')
          .create(body: body);

      debugPrint('✅ Created customer data: ${record.id}');

      return CustomerDataModel.fromJson({
        'id': record.id,
        'collectionId': record.collectionId,
        'collectionName': record.collectionName,
        'name': record.data['name'],
        'refId': record.data['refId'],
        'ownerName': record.data['ownerName'],
          'paymentMode':record.data['paymentMode'],
          'contactNumber':record.data['contactNumber'],
        'province': record.data['province'],
        'municipality': record.data['municipality'],
        'barangay': record.data['barangay'],
        'longitude': record.data['longitude'],
        'latitude': record.data['latitude'],
      });
    } catch (e) {
      debugPrint('❌ Failed to create customer data: ${e.toString()}');
      throw ServerException(
        message: 'Failed to create customer data: ${e.toString()}',
        statusCode: '500',
      );
    }
  }

  @override
  Future<CustomerDataModel> updateCustomerData({
    required String id,
    String? name,
    String? refId,
    String? province,
    String? municipality,
    String? barangay,
    double? longitude,
    double? latitude,
  }) async {
    try {
      debugPrint('🔄 Updating customer data: $id');

      final body = <String, dynamic>{};

      if (name != null) body['name'] = name;
      if (refId != null) body['refId'] = refId;
      if (province != null) body['province'] = province;
      if (municipality != null) body['municipality'] = municipality;
      if (barangay != null) body['barangay'] = barangay;
      if (longitude != null) body['longitude'] = longitude.toString();
      if (latitude != null) body['latitude'] = latitude.toString();

      final record = await _pocketBaseClient
          .collection('customerData')
          .update(id, body: body);

      debugPrint('✅ Updated customer data: ${record.id}');

      return CustomerDataModel.fromJson({
        'id': record.id,
        'collectionId': record.collectionId,
        'collectionName': record.collectionName,
        'name': record.data['name'],
        'refId': record.data['refId'],
        'province': record.data['province'],
        'municipality': record.data['municipality'],
        'barangay': record.data['barangay'],
        'longitude': record.data['longitude'],
        'latitude': record.data['latitude'],
      });
    } catch (e) {
      debugPrint('❌ Failed to update customer data: ${e.toString()}');
      throw ServerException(
        message: 'Failed to update customer data: ${e.toString()}',
        statusCode: '500',
      );
    }
  }

  @override
  Future<bool> deleteCustomerData(String id) async {
    try {
      debugPrint('🔄 Deleting customer data: $id');

      await _pocketBaseClient.collection('customerData').delete(id);

      debugPrint('✅ Deleted customer data: $id');
      return true;
    } catch (e) {
      debugPrint('❌ Failed to delete customer data: ${e.toString()}');
      throw ServerException(
        message: 'Failed to delete customer data: ${e.toString()}',
        statusCode: '500',
      );
    }
  }

  @override
  Future<bool> deleteAllCustomerData(List<String> ids) async {
    try {
      debugPrint(
        '🔄 Deleting multiple customer data records: ${ids.length} items',
      );

      for (final id in ids) {
        await _pocketBaseClient.collection('customerData').delete(id);
      }

      debugPrint('✅ Deleted ${ids.length} customer data records');
      return true;
    } catch (e) {
      debugPrint(
        '❌ Failed to delete multiple customer data records: ${e.toString()}',
      );
      throw ServerException(
        message:
            'Failed to delete multiple customer data records: ${e.toString()}',
        statusCode: '500',
      );
    }
  }
@override
Future<bool> addCustomerToDelivery({
  required String customerId,
  required String deliveryId,
}) async {
  try {
    debugPrint('🔄 Adding customer $customerId to delivery $deliveryId');

    // Update the existing deliveryData record with the customer relation
    await _pocketBaseClient
        .collection('deliveryData')
        .update(
          deliveryId,
          body: {
            'customer': customerId, // Set the relation to the customerData
          },
        );

    debugPrint('✅ Updated deliveryData with customer relation');
    return true;
  } catch (e) {
    // If the deliveryData record doesn't exist yet, create it
    if (e.toString().contains('404') || e.toString().contains('not found')) {
      try {
        await _pocketBaseClient
            .collection('deliveryData')
            .create(
              body: {
                'id':
                    deliveryId, // If you want to use a specific ID (this might not work depending on PocketBase config)
                'customer':
                    customerId, // Set the relation to the customerData
              },
            );

        debugPrint('✅ Created new deliveryData with customer relation');
        return true;
      } catch (createError) {
        debugPrint(
          '❌ Failed to create deliveryData: ${createError.toString()}',
        );
        throw ServerException(
          message: 'Failed to create deliveryData: ${createError.toString()}',
          statusCode: '500',
        );
      }
    }

    debugPrint('❌ Failed to add customer to delivery: ${e.toString()}');
    throw ServerException(
      message: 'Failed to add customer to delivery: ${e.toString()}',
      statusCode: '500',
    );
  }
}


  @override
  Future<List<CustomerDataModel>> getCustomersByDeliveryId(
    String deliveryId,
  ) async {
    try {
      debugPrint('🔄 Fetching customers for delivery: $deliveryId');

      // Get the delivery data record
      final deliveryData = await _pocketBaseClient
          .collection('deliveryData')
          .getOne(deliveryId);

      // Check if there's a customer relation
      if (deliveryData.data.containsKey('customer') &&
          deliveryData.data['customer'] != null) {
        // Get the customer ID from the relation
        final customerId = deliveryData.data['customer'];

        // Fetch the customer data
        final customerRecord = await _pocketBaseClient
            .collection('customerData')
            .getOne(customerId);

        // Create a CustomerDataModel from the record
        final customer = CustomerDataModel.fromJson({
          'id': customerRecord.id,
          'collectionId': customerRecord.collectionId,
          'collectionName': customerRecord.collectionName,
          'name': customerRecord.data['name'],
          'refId': customerRecord.data['refId'],
          'province': customerRecord.data['province'],
          'municipality': customerRecord.data['municipality'],
          'ownerName': customerRecord.data['ownerName'],
          'paymentMode':customerRecord.data['paymentMode'],
          'contactNumber':customerRecord.data['contactNumber'],
          'barangay': customerRecord.data['barangay'],
          'longitude': customerRecord.data['longitude'],
          'latitude': customerRecord.data['latitude'],
        });

        debugPrint('✅ Retrieved customer for delivery: ${customer.name}');
        return [customer]; // Return as a list with a single customer
      }

      // If no customer relation found
      debugPrint('⚠️ No customer found for delivery: $deliveryId');
      return [];
    } catch (e) {
      debugPrint('❌ Failed to fetch customer by delivery ID: ${e.toString()}');
      throw ServerException(
        message: 'Failed to load customer by delivery ID: ${e.toString()}',
        statusCode: '500',
      );
    }
  }
}
