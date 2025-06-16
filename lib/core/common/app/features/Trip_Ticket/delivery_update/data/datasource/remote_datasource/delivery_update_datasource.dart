import 'dart:convert';
import 'dart:io';

import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/delivery_update/data/models/delivery_update_model.dart';
import 'package:xpro_delivery_admin_app/core/errors/exceptions.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:pocketbase/pocketbase.dart';


abstract class DeliveryUpdateDatasource {
  Future<List<DeliveryUpdateModel>> getDeliveryStatusChoices(String customerId);
  Future<void> updateDeliveryStatus(String customerId, String statusId);

 Future<DataMap> checkEndDeliverStatus(String tripId);
  Future<void> initializePendingStatus(List<String> customerIds);
  Future<void> createDeliveryStatus(
    String customerId, {
    required String title,
    required String subtitle,
    required DateTime time,
    required bool isAssigned,
    required String image,
  });
  Future<void> updateQueueRemarks(
    String customerId,
    String queueCount,
  );

   // New functions
  Future<List<DeliveryUpdateModel>> getAllDeliveryUpdates();
  
  Future<DeliveryUpdateModel> createDeliveryUpdate({
    required String title,
    required String subtitle,
    required DateTime time,
    required String customerId,
    required bool isAssigned,
    String? assignedTo,
    String? image,
    String? remarks,
  });
  
  Future<DeliveryUpdateModel> updateDeliveryUpdate({
    required String id,
    String? title,
    String? subtitle,
    DateTime? time,
    String? customerId,
    bool? isAssigned,
    String? assignedTo,
    String? image,
    String? remarks,
  });
  
  Future<bool> deleteDeliveryUpdate(String id);
  
  Future<bool> deleteAllDeliveryUpdates(List<String> ids);
}

class DeliveryUpdateDatasourceImpl implements DeliveryUpdateDatasource {
  const DeliveryUpdateDatasourceImpl({required PocketBase pocketBaseClient})
      : _pocketBaseClient = pocketBaseClient;

  final PocketBase _pocketBaseClient;
  @override
  Future<void> updateQueueRemarks(
    String customerId,
    String queueCount,
  ) async {
    try {
      debugPrint('🔄 Updating queue remarks for customer: $customerId');

      // Update customer record
      await _pocketBaseClient.collection('customers').update(
        customerId,
        body: {
          'remarks': queueCount,
          'updated': DateTime.now().toIso8601String(),
        },
      );

      ;

      debugPrint('✅ Queue remarks updated across all collections');
    } catch (e) {
      debugPrint('❌ Failed to update queue remarks: $e');
      throw ServerException(message: e.toString(), statusCode: '404');
    }
  }

  @override
  Future<List<DeliveryUpdateModel>> getDeliveryStatusChoices(
      String customerId) async {
    try {
      debugPrint(
          '🚚 Fetching delivery status choices for customer: $customerId');

      final customerRecord =
          await _pocketBaseClient.collection('customers').getOne(
                customerId,
                expand: 'deliveryStatus',
              );

      final deliveryUpdates = customerRecord.expand['deliveryStatus'] as List?;
      final latestStatus = deliveryUpdates?.isNotEmpty == true
          ? deliveryUpdates!.last.data['title'].toString().toLowerCase()
          : '';

      debugPrint('📍 Latest status for customer $customerId: $latestStatus');

      final allStatuses = await _pocketBaseClient
          .collection('delivery_status_choices')
          .getFullList();

      // Log available status choices
      for (var status in allStatuses) {
        debugPrint(
            '🏷️ Available Status - ID: ${status.id}, Title: ${status.data['title']}');
      }

      // Handle In Transit status
      if (latestStatus == 'in transit') {
        final allowedTitles = ['mark as undelivered', 'arrived'];
        return _filterStatusChoices(allStatuses, allowedTitles);
      }

      // Handle Waiting for customers

      // Handle Unloading
      if (latestStatus == 'unloading') {
        final allowedTitles = ['mark as received'];
        return _filterStatusChoices(allStatuses, allowedTitles);
      }

      if (latestStatus == 'mark as received') {
        final allowedTitles = ['end delivery'];
        return _filterStatusChoices(allStatuses, allowedTitles);
      }

      // Handle Arrived status
      if (latestStatus == 'arrived') {
        final allowedTitles = [
          'mark as undelivered',
          'unloading',
          'waiting for customer'
        ];
        return _filterStatusChoices(allStatuses, allowedTitles);
      }

      if (latestStatus == 'mark as undelivered') {
        return [];
      }

      if (latestStatus == 'end delivery') {
        return [];
      }

      final assignedTitles = deliveryUpdates
              ?.map((record) => record.data['title'].toString().toLowerCase())
              .toSet() ??
          {};

      debugPrint('📋 Already assigned titles: $assignedTitles');

      return allStatuses
          .where((status) => !assignedTitles
              .contains(status.data['title'].toString().toLowerCase()))
          .map((record) => DeliveryUpdateModel.fromJson(record.toJson()))
          .toList();
    } catch (e) {
      debugPrint('❌ Error fetching delivery status choices: ${e.toString()}');
      throw ServerException(
        message: 'Failed to fetch delivery status choices: ${e.toString()}',
        statusCode: '500',
      );
    }
  }

  List<DeliveryUpdateModel> _filterStatusChoices(
      List<RecordModel> allStatuses, List<String> allowedTitles) {
    return allStatuses
        .where((status) => allowedTitles
            .contains(status.data['title'].toString().toLowerCase()))
        .map((record) {
      final statusId = record.id;
      debugPrint(
          '🏷️ Processing status - ID: $statusId, Title: ${record.data['title']}');

      return DeliveryUpdateModel.fromJson({
        'id': statusId, // Explicit ID assignment
        'collectionId': record.collectionId,
        'collectionName': record.collectionName,
        'title': record.data['title'],
        'subtitle': record.data['subtitle'],
      });
    }).toList();
  }

  @override
  Future<void> updateDeliveryStatus(String customerId, String statusId) async {
    try {
      debugPrint(
          '🔄 Processing status update - Customer: $customerId, Status: $statusId');

      // Validate status ID
      if (statusId.isEmpty) {
        debugPrint('⚠️ Invalid status ID provided');
        throw const ServerException(
          message: 'Invalid status ID',
          statusCode: '400',
        );
      }

      // Get the status record
      final statusRecord = await _pocketBaseClient
          .collection('delivery_status_choices')
          .getOne(statusId);

      debugPrint('✅ Retrieved status: ${statusRecord.data['title']}');

      // Create delivery update with validated data
      final currentTime = DateTime.now().toIso8601String();
      final deliveryUpdateRecord =
          await _pocketBaseClient.collection('delivery_update').create(body: {
        'customer': customerId,
        'status': statusId,
        'title': statusRecord.data['title'],
        'subtitle': statusRecord.data['subtitle'],
        'created': currentTime,
        'time': currentTime,
        'isAssigned': true,
      });

      debugPrint('📝 Created delivery update: ${deliveryUpdateRecord.id}');

      // Update customer record
      await _pocketBaseClient.collection('customers').update(
        customerId,
        body: {
          'deliveryStatus+': [deliveryUpdateRecord.id],
        },
      );

      debugPrint('✅ Successfully updated customer status');
    } catch (e) {
      debugPrint('❌ Operation failed: ${e.toString()}');
      throw ServerException(
        message: e is ServerException
            ? e.message
            : 'Operation failed: ${e.toString()}',
        statusCode: e is ServerException ? e.statusCode : '500',
      );
    }
  }

@override
Future<DataMap> checkEndDeliverStatus(String tripId) async {
  try {
    debugPrint('🔍 Checking end delivery status for trip: $tripId');

    // Extract trip ID if received as JSON
    String actualTripId;
    if (tripId.startsWith('{')) {
      final tripData = jsonDecode(tripId);
      actualTripId = tripData['id'];
    } else {
      actualTripId = tripId;
    }

    // Get customers using trip ID
    final customerRecords = await _pocketBaseClient.collection('customers').getFullList(
      filter: 'trip = "$actualTripId"',
      expand: 'deliveryStatus',
    );

    final totalCustomers = customerRecords.length;
    debugPrint('📦 Total customers in trip: $totalCustomers');

   final completedDeliveries = customerRecords.where((customer) {
  final deliveryStatuses = customer.expand['deliveryStatus'] as List? ?? [];
  final hasEndDelivery = deliveryStatuses.any((status) {
    final title = status.data['title'].toString().toLowerCase();
    if (title == 'end delivery') {
      debugPrint('   ✅ Customer ${customer.data['storeName']} has End Delivery status');
      return true;
    }
    if (title == 'mark as undelivered') {
      debugPrint('   ⚠️ Customer ${customer.data['storeName']} is marked Undelivered');
      return true;
    }
    return false;
  });
  return hasEndDelivery;
}).length;


    debugPrint('📊 Delivery Status Summary:');
    debugPrint('   - Total Customers: $totalCustomers');
    debugPrint('   - Completed Deliveries: $completedDeliveries');
    debugPrint('   - Pending Deliveries: ${totalCustomers - completedDeliveries}');

    return {
      'total': totalCustomers,
      'completed': completedDeliveries,
      'pending': totalCustomers - completedDeliveries,
    };
  } catch (e) {
    debugPrint('❌ Error checking end delivery status: $e');
    throw ServerException(
      message: 'Failed to check end delivery status: $e',
      statusCode: '500',
    );
  }
}


  @override
  Future<void> initializePendingStatus(List<String> customerIds) async {
    try {
      debugPrint('🔄 Initializing pending status for customers');

      final pendingStatus = await _pocketBaseClient
          .collection('delivery_status_choices')
          .getFirstListItem('title = "Pending"');

      for (final customerId in customerIds) {
        // Check if customer already has a pending status
        final customerRecord = await _pocketBaseClient
            .collection('customers')
            .getOne(customerId, expand: 'deliveryStatus');

        final existingStatuses =
            customerRecord.expand['deliveryStatus'] as List? ?? [];
        final hasPendingStatus =
            existingStatuses.any((status) => status.data['title'] == 'Pending');

        if (!hasPendingStatus) {
          final currentTime = DateTime.now().toIso8601String();
          final deliveryUpdateRecord = await _pocketBaseClient
              .collection('delivery_update')
              .create(body: {
            'customer': customerId,
            'status': pendingStatus.id,
            'title': pendingStatus.data['title'],
            'subtitle': pendingStatus.data['subtitle'],
            'created': currentTime,
            'time': currentTime,
            'isAssigned': true,
          });

          await _pocketBaseClient.collection('customers').update(
            customerId,
            body: {
              'deliveryStatus': [deliveryUpdateRecord.id],
            },
          );
        }
      }

      debugPrint('✅ Successfully initialized pending status');
    } catch (e) {
      debugPrint('❌ Failed to initialize pending status: $e');
      throw ServerException(
        message: 'Failed to initialize pending status: $e',
        statusCode: '500',
      );
    }
  }

  @override
  Future<void> createDeliveryStatus(
    String customerId, {
    required String title,
    required String subtitle,
    required DateTime time,
    required bool isAssigned,
    required String image,
  }) async {
    try {
      debugPrint('📝 Creating delivery status for customer: $customerId');

      final files = <String, MultipartFile>{};

      if (image.isNotEmpty) {
        final imageBytes = await File(image).readAsBytes();
        files['image'] = MultipartFile.fromBytes(
          'image',
          imageBytes,
          filename: 'delivery_status_image.jpg',
        );
      }

      final deliveryUpdateRecord =
          await _pocketBaseClient.collection('delivery_update').create(
        body: {
          'customer': customerId,
          'title': title,
          'subtitle': subtitle,
          'time': time.toIso8601String(),
          'isAssigned': true,
        },
        files: files.values.toList(),
      );

      debugPrint('✅ Created delivery status: ${deliveryUpdateRecord.id}');

      await _pocketBaseClient.collection('customers').update(
        customerId,
        body: {
          'deliveryStatus+': [deliveryUpdateRecord.id],
        },
      );

      debugPrint('✅ Updated customer with new delivery status');
    } catch (e) {
      debugPrint('❌ Failed to create delivery status: $e');
      throw ServerException(
        message: 'Failed to create delivery status: $e',
        statusCode: '500',
      );
    }
  }
  
  @override
  Future<List<DeliveryUpdateModel>> getAllDeliveryUpdates() async {
    try {
      debugPrint('🔄 Getting all delivery updates');
      
      final records = await _pocketBaseClient
          .collection('delivery_update')
          .getFullList(
            expand: 'customer',
          );
      
      debugPrint('✅ Retrieved ${records.length} delivery updates from API');
      
      return records.map((record) {
        return DeliveryUpdateModel.fromJson({
          'id': record.id,
          'collectionId': record.collectionId,
          'collectionName': record.collectionName,
          'title': record.data['title'] ?? '',
          'subtitle': record.data['subtitle'] ?? '',
          'time': record.data['time'],
          'customer': record.data['customer'],
          'isAssigned': record.data['isAssigned'] ?? false,
          'assignedTo': record.data['assignedTo'],
          'image': record.data['image'],
          'remarks': record.data['remarks'],
          'created': record.created.toString(),
          'updated': record.updated.toString(),
          'expand': {
            'customer': record.expand['customer'],
          }
        });
      }).toList();
    } catch (e) {
      debugPrint('❌ Get All Delivery Updates failed: ${e.toString()}');
      throw ServerException(
        message: 'Failed to load all delivery updates: ${e.toString()}',
        statusCode: '500',
      );
    }
  }
  
  @override
  Future<DeliveryUpdateModel> createDeliveryUpdate({
    required String title,
    required String subtitle,
    required DateTime time,
    required String customerId,
    required bool isAssigned,
    String? assignedTo,
    String? image,
    String? remarks,
  }) async {
    try {
      debugPrint('🔄 Creating new delivery update');
      
      final body = {
        'title': title,
        'subtitle': subtitle,
        'time': time.toIso8601String(),
        'customer': customerId,
        'isAssigned': isAssigned,
      };
      
      if (assignedTo != null) body['assignedTo'] = assignedTo;
      if (remarks != null) body['remarks'] = remarks;
      
      final files = <String, MultipartFile>{};
      if (image != null && image.isNotEmpty) {
        final imageBytes = await File(image).readAsBytes();
        files['image'] = MultipartFile.fromBytes(
          'image',
          imageBytes,
          filename: 'delivery_update_image.jpg',
        );
      }
      
      final record = await _pocketBaseClient
          .collection('delivery_update')
          .create(
            body: body,
          );
      
      // Update customer record with new delivery status
      await _pocketBaseClient.collection('customers').update(
        customerId,
        body: {
          'deliveryStatus+': [record.id],
        },
      );
      
      // Fetch the created record with expanded relations
      final createdRecord = await _pocketBaseClient
          .collection('delivery_update')
          .getOne(
            record.id,
            expand: 'customer',
          );
      
      debugPrint('✅ Successfully created delivery update: ${record.id}');
      
      return DeliveryUpdateModel.fromJson({
        'id': createdRecord.id,
        'collectionId': createdRecord.collectionId,
        'collectionName': createdRecord.collectionName,
        'title': createdRecord.data['title'] ?? '',
        'subtitle': createdRecord.data['subtitle'] ?? '',
        'time': createdRecord.data['time'],
        'customer': createdRecord.data['customer'],
        'isAssigned': createdRecord.data['isAssigned'] ?? false,
        'assignedTo': createdRecord.data['assignedTo'],
        'image': createdRecord.data['image'],
        'remarks': createdRecord.data['remarks'],
        'created': createdRecord.created.toString(),
        'updated': createdRecord.updated.toString(),
        'expand': {
          'customer': createdRecord.expand['customer'],
        }
      });
    } catch (e) {
      debugPrint('❌ Create Delivery Update failed: ${e.toString()}');
      throw ServerException(
        message: 'Failed to create delivery update: ${e.toString()}',
        statusCode: '500',
      );
    }
  }
  
  @override
  Future<DeliveryUpdateModel> updateDeliveryUpdate({
    required String id,
    String? title,
    String? subtitle,
    DateTime? time,
    String? customerId,
    bool? isAssigned,
    String? assignedTo,
    String? image,
    String? remarks,
  }) async {
    try {
      debugPrint('🔄 Updating delivery update: $id');
      
      final body = <String, dynamic>{};
      
      if (title != null) body['title'] = title;
      if (subtitle != null) body['subtitle'] = subtitle;
      if (time != null) body['time'] = time.toIso8601String();
      if (customerId != null) body['customer'] = customerId;
      if (isAssigned != null) body['isAssigned'] = isAssigned;
      if (assignedTo != null) body['assignedTo'] = assignedTo;
      if (remarks != null) body['remarks'] = remarks;
      
      final files = <String, MultipartFile>{};
      if (image != null && image.isNotEmpty) {
        final imageBytes = await File(image).readAsBytes();
        files['image'] = MultipartFile.fromBytes(
          'image',
          imageBytes,
          filename: 'delivery_update_image.jpg',
        );
      }
      
      await _pocketBaseClient
          .collection('delivery_update')
          .update(
            id,
            body: body,
          );
      
      // Fetch the updated record with expanded relations
      final updatedRecord = await _pocketBaseClient
          .collection('delivery_update')
          .getOne(
            id,
            expand: 'customer',
          );
      
      debugPrint('✅ Successfully updated delivery update');
      
      return DeliveryUpdateModel.fromJson({
        'id': updatedRecord.id,
        'collectionId': updatedRecord.collectionId,
        'collectionName': updatedRecord.collectionName,
        'title': updatedRecord.data['title'] ?? '',
        'subtitle': updatedRecord.data['subtitle'] ?? '',
        'time': updatedRecord.data['time'],
        'customer': updatedRecord.data['customer'],
        'isAssigned': updatedRecord.data['isAssigned'] ?? false,
        'assignedTo': updatedRecord.data['assignedTo'],
        'image': updatedRecord.data['image'],
        'remarks': updatedRecord.data['remarks'],
        'created': updatedRecord.created.toString(),
        'updated': updatedRecord.updated.toString(),
        'expand': {
          'customer': updatedRecord.expand['customer'],
        }
      });
    } catch (e) {
      debugPrint('❌ Update Delivery Update failed: ${e.toString()}');
      throw ServerException(
        message: 'Failed to update delivery update: ${e.toString()}',
        statusCode: '500',
      );
    }
  }
  
  @override
  Future<bool> deleteDeliveryUpdate(String id) async {
    try {
      debugPrint('🔄 Deleting delivery update: $id');
      
      // Get the delivery update to find the customer ID
      final record = await _pocketBaseClient
          .collection('delivery_update')
          .getOne(id);
      
      final customerId = record.data['customer'];
      
      // Delete the delivery update
      await _pocketBaseClient.collection('delivery_update').delete(id);
      
      // Update the customer record to remove the delivery status reference
      if (customerId != null) {
        final customerRecord = await _pocketBaseClient
            .collection('customers')
            .getOne(customerId);
        
        final deliveryStatuses = customerRecord.data['deliveryStatus'] as List? ?? [];
        deliveryStatuses.remove(id);
        
        await _pocketBaseClient.collection('customers').update(
          customerId,
          body: {
            'deliveryStatus': deliveryStatuses,
          },
        );
      }
      
      debugPrint('✅ Successfully deleted delivery update');
      return true;
    } catch (e) {
      debugPrint('❌ Delete Delivery Update failed: ${e.toString()}');
      throw ServerException(
        message: 'Failed to delete delivery update: ${e.toString()}',
        statusCode: '500',
      );
    }
  }
  
  @override
  Future<bool> deleteAllDeliveryUpdates(List<String> ids) async {
    try {
      debugPrint('🔄 Deleting multiple delivery updates: ${ids.length} items');
      
      // Get all delivery updates to find customer IDs
      final customerUpdates = <String, List<String>>{};
      
      for (final id in ids) {
        try {
          final record = await _pocketBaseClient
              .collection('delivery_update')
              .getOne(id);
          
          final customerId = record.data['customer'];
          if (customerId != null) {
            customerUpdates[customerId] = [...(customerUpdates[customerId] ?? []), id];
          }
          
          // Delete the delivery update
          await _pocketBaseClient.collection('delivery_update').delete(id);
        } catch (e) {
          debugPrint('⚠️ Error processing delivery update $id: $e');
          // Continue with other deletions
        }
      }
      
      // Update customer records to remove delivery status references
      for (final entry in customerUpdates.entries) {
        try {
          final customerId = entry.key;
          final updateIds = entry.value;
          
          final customerRecord = await _pocketBaseClient
              .collection('customers')
              .getOne(customerId);
          
          final deliveryStatuses = customerRecord.data['deliveryStatus'] as List? ?? [];
          final updatedStatuses = deliveryStatuses.where((id) => !updateIds.contains(id)).toList();
          
          await _pocketBaseClient.collection('customers').update(
            customerId,
            body: {
              'deliveryStatus': updatedStatuses,
            },
          );
        } catch (e) {
          debugPrint('⚠️ Error updating customer ${entry.key}: $e');
          // Continue with other customers
        }
      }
      
      debugPrint('✅ Successfully deleted all delivery updates');
      return true;
    } catch (e) {
      debugPrint('❌ Delete All Delivery Updates failed: ${e.toString()}');
      throw ServerException(
        message: 'Failed to delete multiple delivery updates: ${e.toString()}',
        statusCode: '500',
      );
    }
  }
}
