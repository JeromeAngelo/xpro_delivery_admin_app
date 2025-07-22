import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  Future<List<CustomerDataModel>> getAllUnassignedCustomerData();
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
  Future<List<CustomerDataModel>> getAllUnassignedCustomerData() async {
    try {
      debugPrint('🔄 Fetching all unassigned customer data from remote');
      
      // Ensure PocketBase client is authenticated
      await _ensureAuthenticated();

      // 1. First, get all customer data
      final allCustomers = await _pocketBaseClient
          .collection('customerData')
          .getFullList(sort: '-created');

      debugPrint(
        '✅ Retrieved ${allCustomers.length} total customer data records',
      );

      // 2. Get all customers that have already been assigned (have an invoiceStatus)
      final assignedCustomers = await _pocketBaseClient
          .collection('invoiceStatus')
          .getFullList(expand: 'customerData', fields: 'id,customerData');

      // Create a set of assigned customer IDs for faster lookup
      final Set<String> assignedCustomerIds = {};
      for (var statusRecord in assignedCustomers) {
        // Get the customer ID from the customerData relation
        if (statusRecord.expand.containsKey('customerData') &&
            statusRecord.expand['customerData'] != null) {
          final customerData = statusRecord.expand['customerData'];
          if (customerData is List && customerData!.isNotEmpty) {
            for (var customer in customerData) {
              assignedCustomerIds.add(customer.id);
            }
          }
        } else if (statusRecord.data.containsKey('customerData') &&
            statusRecord.data['customerData'] != null) {
          // If not expanded but we have the customer ID
          final customerId = statusRecord.data['customerData'].toString();
          if (customerId.isNotEmpty) {
            assignedCustomerIds.add(customerId);
          }
        }
      }

      debugPrint(
        'ℹ️ Found ${assignedCustomerIds.length} already assigned customers',
      );

      List<CustomerDataModel> unassignedCustomers = [];

      // 3. Filter customers to only include those that are unassigned
      for (var customer in allCustomers) {
        final customerId = customer.id;

        if (!assignedCustomerIds.contains(customerId)) {
          // This customer is unassigned
          final customerModel = CustomerDataModel.fromJson({
            'id': customer.id,
            'collectionId': customer.collectionId,
            'collectionName': customer.collectionName,
            'name': customer.data['name'],
            'refId': customer.data['refID'],
            'province': customer.data['province'],
            'ownerName': customer.data['ownerName'],
            'paymentMode': customer.data['paymentMode'],
            'contactNumber': customer.data['contactNumber'],
            'municipality': customer.data['municipality'],
            'barangay': customer.data['barangay'],
            'longitude': customer.data['longitude'],
            'latitude': customer.data['latitude'],
          });

          unassignedCustomers.add(customerModel);
          debugPrint(
            '✅ Added unassigned customer ${customer.id} (${customer.data['name']})',
          );
        } else {
          debugPrint(
            'ℹ️ Customer ${customer.id} (${customer.data['name']}) is already assigned, skipping',
          );
        }
      }

      debugPrint(
        '✅ Returning ${unassignedCustomers.length} unassigned customer data records',
      );
      return unassignedCustomers;
    } catch (e) {
      debugPrint('❌ Failed to fetch unassigned customer data: ${e.toString()}');
      throw ServerException(
        message: 'Failed to load unassigned customer data: ${e.toString()}',
        statusCode: '500',
      );
    }
  }

  @override
  Future<List<CustomerDataModel>> getAllCustomerData() async {
    try {
      debugPrint('🔄 Fetching all customer data from remote');
      
      // Ensure PocketBase client is authenticated
      await _ensureAuthenticated();

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
          'refId': record.data['refID'],
          'province': record.data['province'],
          'ownerName': record.data['ownerName'],
          'paymentMode': record.data['paymentMode'],
          'contactNumber': record.data['contactNumber'],
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
      
      // Ensure PocketBase client is authenticated
      await _ensureAuthenticated();

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
        'paymentMode': record.data['paymentMode'],
        'contactNumber': record.data['contactNumber'],
        'refId': record.data['refID'],
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
        'refId': record.data['refID'],
        'ownerName': record.data['ownerName'],
        'paymentMode': record.data['paymentMode'],
        'contactNumber': record.data['contactNumber'],
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
      if (refId != null) body['refID'] = refId;
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
        'refId': record.data['refID'],
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
          'refId': customerRecord.data['refID'],
          'province': customerRecord.data['province'],
          'municipality': customerRecord.data['municipality'],
          'ownerName': customerRecord.data['ownerName'],
          'paymentMode': customerRecord.data['paymentMode'],
          'contactNumber': customerRecord.data['contactNumber'],
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
