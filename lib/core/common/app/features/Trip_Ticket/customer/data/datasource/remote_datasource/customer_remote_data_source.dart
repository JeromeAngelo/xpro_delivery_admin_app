import 'dart:convert';

import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/customer/data/model/customer_model.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/delivery_update/data/models/delivery_update_model.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/invoice/data/models/invoice_models.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/trip/data/models/trip_models.dart';
import 'package:xpro_delivery_admin_app/core/errors/exceptions.dart' show ServerException;
import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';

abstract class CustomerRemoteDataSource {
  Future<List<CustomerModel>> getCustomers(String tripId);
  Future<CustomerModel> getCustomerLocation(String customerId);
  Future<void> updateCustomer(CustomerModel customer);
  Future<String> calculateCustomerTotalTime(String customerId);
  // New functions
  Future<List<CustomerModel>> getAllCustomers();
  Future<CustomerModel> createCustomer({
    required String deliveryNumber,
    required String storeName,
    required String ownerName,
    required List<String> contactNumber,
    required String address,
    required String municipality,
    required String province,
    required String modeOfPayment,
    required String tripId,
    String? totalAmount,
    String? latitude,
    String? longitude,
    String? notes,
    String? remarks,
    bool? hasNotes,
    double? confirmedTotalPayment,
  });
  Future<bool> deleteCustomer(String id);
  Future<bool> deleteAllCustomers(List<String> ids);
}

class CustomerRemoteDataSourceImpl implements CustomerRemoteDataSource {
  const CustomerRemoteDataSourceImpl({required PocketBase pocketBaseClient})
    : _pocketBaseClient = pocketBaseClient;

  final PocketBase _pocketBaseClient;
  @override
  Future<List<CustomerModel>> getCustomers(String tripId) async {
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

      // Get customers using trip ID
      final result = await _pocketBaseClient
          .collection('customers')
          .getFullList(
            filter: 'trip = "$actualTripId"',
            expand: 'deliveryStatus,invoices,trip',
          );

      debugPrint(
        '✅ Retrieved ${result.length} customers for trip: $actualTripId',
      );

      List<CustomerModel> customers = [];

      for (var record in result) {
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
          'latitude': record.data['latitude'],
          'longitude': record.data['longitude'],
          'remarks': record.data['remarks'] ?? '',
          'notes': record.data['notes'] ?? '',
          'totalTime': record.data['totalTime'] ?? '',
          'trip': actualTripId,
          'hasNotes': record.data['hasNotes'] ?? false,
          'confirmedTotalPayment': double.tryParse(
            record.data['confirmedTotalPayment']?.toString() ?? '0',
          ),
          'deliveryTeam': record.data['deliveryTeam'],
          'expand': {
            'deliveryStatus': record.expand['deliveryStatus'] ?? [],
            'invoices': record.expand['invoices'] ?? [],
          },
        };

        customers.add(CustomerModel.fromJson(mappedData));
      }

      return customers;
    } catch (e) {
      debugPrint('❌ Get Customer Remote data fetch failed: ${e.toString()}');
      throw ServerException(
        message: 'Failed to load customers by trip id: ${e.toString()}',
        statusCode: '500',
      );
    }
  }
  @override
Future<CustomerModel> getCustomerLocation(String customerId) async {
  try {
    // Extract the actual ID if we received a CustomerModel object or a string representation of it
    String actualCustomerId;
    
    if (customerId.contains('CustomerModel')) {
      // This is a string representation of a CustomerModel object
      // Extract just the ID from it - it should be the first part before a comma
      final idMatch = RegExp(r'CustomerModel\(([^,]+)').firstMatch(customerId);
      if (idMatch != null && idMatch.groupCount >= 1) {
        actualCustomerId = idMatch.group(1)!;
      } else {
        // Fallback to using the first part before a comma if regex fails
        actualCustomerId = customerId.split(',').first.replaceAll('CustomerModel(', '').trim();
      }
    } else {
      // This is already just an ID
      actualCustomerId = customerId;
    }
    
    debugPrint('📍 Fetching data for customer with ID: $actualCustomerId');

    // Get basic customer data first with expanded trip relationship
    final record = await _pocketBaseClient
        .collection('customers')
        .getOne(actualCustomerId, expand: 'deliveryStatus,trip');

    // Then get invoices separately
    final invoices = await _pocketBaseClient
        .collection('invoices')
        .getFullList(
          filter: 'customer = "$actualCustomerId"',
          expand: 'productList',
        );

    // Process delivery status
    final deliveryStatusList =
        (record.expand['deliveryStatus'] as List?)?.map((status) {
          final statusRecord = status as RecordModel;
          return DeliveryUpdateModel.fromJson({
            'id': statusRecord.id,
            'collectionId': statusRecord.collectionId,
            'collectionName': statusRecord.collectionName,
            'title': statusRecord.data['title'],
            'subtitle': statusRecord.data['subtitle'],
            'time': statusRecord.data['time'],
            'customer': statusRecord.data['customer'],
            'isAssigned': statusRecord.data['isAssigned'],
            'created': null,
            'updated': null,
          });
        }).toList() ??
        [];

    // Process invoices
    final invoicesList =
        invoices
            .map(
              (invoice) => InvoiceModel.fromJson({
                'id': invoice.id,
                'collectionId': invoice.collectionId,
                'collectionName': invoice.collectionName,
                'invoiceNumber': invoice.data['invoiceNumber'],
                'status': invoice.data['status'],
                'productList': invoice.expand['productList'] ?? [],
                'customer': invoice.data['customer'],
                'totalAmount': record.data['totalAmount'],
                'created': null,
                'updated': null,
              }),
            )
            .toList();

    // Process trip data
    TripModel? tripModel;
    String? tripId;
    String? tripNumberId; // Added to store the trip number ID
    
    if (record.expand['trip'] != null) {
      final tripData = record.expand['trip'];
      if (tripData is List && tripData!.isNotEmpty) {
        final tripRecord = tripData[0];
        tripId = tripRecord.id;
        tripNumberId = tripRecord.data['tripNumberId']; // Extract the tripNumberId
        tripModel = TripModel.fromJson({
          'id': tripRecord.id,
          'collectionId': tripRecord.collectionId,
          'collectionName': tripRecord.collectionName,
          'tripNumberId': tripRecord.data['tripNumberId'], // Include tripNumberId
          'qrCode': tripRecord.data['qrCode'],
          'isAccepted': tripRecord.data['isAccepted'],
          'isEndTrip': tripRecord.data['isEndTrip'],
        });
        debugPrint('✅ Found trip ID: $tripId (Number: $tripNumberId) for customer: $actualCustomerId');
      } else if (tripData is String) {
        tripId = tripData as String?;
        // If we only have the trip ID, try to fetch the trip details to get the tripNumberId
        try {
          final tripRecord = await _pocketBaseClient
              .collection('tripticket')
              .getOne(tripId!);
          tripNumberId = tripRecord.data['tripNumberId'];
          tripModel = TripModel.fromJson({
            'id': tripRecord.id,
            'collectionId': tripRecord.collectionId,
            'collectionName': tripRecord.collectionName,
            'tripNumberId': tripRecord.data['tripNumberId'],
            'qrCode': tripRecord.data['qrCode'],
            'isAccepted': tripRecord.data['isAccepted'],
            'isEndTrip': tripRecord.data['isEndTrip'],
          });
          debugPrint('✅ Fetched trip details - Number: $tripNumberId for customer: $actualCustomerId');
        } catch (e) {
          debugPrint('⚠️ Could not fetch trip details: $e');
        }
      }
    } else {
      debugPrint('⚠️ No trip found for customer: $actualCustomerId');
    }

    return CustomerModel(
      id: record.id,
      collectionId: record.collectionId,
      collectionName: record.collectionName,
      deliveryNumber: record.data['deliveryNumber'],
      storeName: record.data['storeName'],
      ownerName: record.data['ownerName'],
      contactNumber: [record.data['contactNumber']],
      address: record.data['address'],
      municipality: record.data['municipality'],
      province: record.data['province'],
      modeOfPayment: record.data['modeOfPayment'],
      deliveryStatusList: deliveryStatusList,
      invoicesList: invoicesList,
      numberOfInvoices: invoicesList.length,
      hasNotes: record.data['hasNotes'] ?? false,
      confirmedTotalPayment: double.tryParse(
        record.data['confirmedTotalPayment']?.toString() ?? '0',
      ),
      totalAmount: record.data['totalAmount'],
      latitude: record.data['latitude'],
      longitude: record.data['longitude'],
      remarks: record.data['remarks'],
      notes: record.data['notes'],
      tripModel: tripModel,  // Set the trip model with tripNumberId
      tripId: tripId,        // Set the trip ID
    );
  } catch (e) {
    debugPrint('❌ Customer Location Error fetching customer data: $e');
    throw ServerException(message: e.toString(), statusCode: '500');
  }
}

  // Add this implementation
  @override
  Future<void> updateCustomer(CustomerModel customer) async {
    try {
      debugPrint('🌐 Updating customer in remote: ${customer.id}');

      await _pocketBaseClient
          .collection('customers')
          .update(
            customer.id!,
            body: {
              'deliveryNumber': customer.deliveryNumber,
              'storeName': customer.storeName,
              'ownerName': customer.ownerName,
              'contactNumber': customer.contactNumber,
              'address': customer.address,
              'municipality': customer.municipality,
              'province': customer.province,
              'modeOfPayment': customer.modeOfPayment,
              'latitude': customer.latitude,
              'longitude': customer.longitude,
              'totalAmount': customer.totalAmount?.toString(),
              'remarks': customer.remarks,
              'notes': customer.notes,
            },
          );

      debugPrint('✅ Customer updated successfully in remote');
    } catch (e) {
      debugPrint('❌ Remote update failed: ${e.toString()}');
      throw ServerException(
        message: 'Failed to update customer: ${e.toString()}',
        statusCode: '500',
      );
    }
  }

  @override
  Future<String> calculateCustomerTotalTime(String customerId) async {
    try {
      debugPrint('⏱️ Calculating total time for customer: $customerId');

      final record = await _pocketBaseClient
          .collection('customers')
          .getOne(customerId, expand: 'deliveryStatus');

      final deliveryUpdates = record.expand['deliveryStatus'] as List? ?? [];
      if (deliveryUpdates.isEmpty) return '0m';

      final sortedUpdates =
          deliveryUpdates.map((update) {
              final data = update.data;
              return DeliveryUpdateModel.fromJson({
                'id': update.id,
                'collectionId': update.collectionId,
                'collectionName': update.collectionName,
                'title': data['title'],
                'subtitle': data['subtitle'],
                'time': data['time'],
                'customer': data['customer'],
                'isAssigned': data['isAssigned'],
              });
            }).toList()
            ..sort((a, b) => a.time!.compareTo(b.time!));

      final arrivedIndex = sortedUpdates.indexWhere(
        (update) => update.title?.toLowerCase().trim() == 'arrived',
      );

      if (arrivedIndex == -1) return '0m';

      // Check for undelivered status
      final undeliveredIndex = sortedUpdates.indexWhere(
        (update) => update.title?.toLowerCase().trim() == 'mark as undelivered',
      );

      // Get end delivery status
      final endDeliveryIndex = sortedUpdates.indexWhere(
        (update) => update.title?.toLowerCase().trim() == 'end delivery',
      );

      // Determine relevant updates based on delivery scenario
      List<DeliveryUpdateModel> relevantUpdates;
      if (undeliveredIndex != -1) {
        // Undelivered scenario - calculate until mark as undelivered
        relevantUpdates = sortedUpdates.sublist(
          arrivedIndex,
          undeliveredIndex + 1,
        );
      } else if (endDeliveryIndex != -1) {
        // Normal delivery - include end delivery
        relevantUpdates = sortedUpdates.sublist(
          arrivedIndex,
          endDeliveryIndex + 1,
        );
      } else {
        // Fallback to all updates from arrived
        relevantUpdates = sortedUpdates.sublist(arrivedIndex);
      }

      int totalSeconds = 0;
      for (int i = 0; i < relevantUpdates.length - 1; i++) {
        final currentTime = relevantUpdates[i].time!;
        final nextTime = relevantUpdates[i + 1].time!;
        final diffInSeconds = nextTime.difference(currentTime).inSeconds;
        totalSeconds += diffInSeconds;

        debugPrint(
          'Status: ${relevantUpdates[i].title} -> ${relevantUpdates[i + 1].title}',
        );
        debugPrint(
          'Time: ${_formatTime(currentTime)} -> ${_formatTime(nextTime)}',
        );
        debugPrint(
          'Difference: ${diffInSeconds ~/ 60} minutes ${diffInSeconds % 60} seconds\n',
        );
      }

      final hours = totalSeconds ~/ 3600;
      final minutes = (totalSeconds % 3600) ~/ 60;
      final seconds = totalSeconds % 60;

      String totalTime;
      if (hours > 0) {
        totalTime = '${hours}h ${minutes}m ${seconds}s';
      } else if (minutes > 0) {
        totalTime = '${minutes}m ${seconds}s';
      } else {
        totalTime = '${seconds}s';
      }

      await _pocketBaseClient
          .collection('customers')
          .update(customerId, body: {'totalTime': totalTime});

      debugPrint(
        '✅ Total accumulated time: $totalTime ($totalSeconds seconds)',
      );
      return totalTime;
    } catch (e) {
      debugPrint('❌ Failed to calculate total time: $e');
      throw ServerException(message: e.toString(), statusCode: '404');
    }
  }

  String _formatTime(DateTime time) {
    return '${time.hour}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}';
  }

  @override
Future<List<CustomerModel>> getAllCustomers() async {
  try {
    debugPrint('🔄 Getting all customers with complete data');

    final result = await _pocketBaseClient
        .collection('customers')
        .getFullList(
          expand: 'deliveryStatus,invoices,trip',
          sort: '-created',
        );

    debugPrint('✅ Retrieved ${result.length} customers from API');

    List<CustomerModel> customers = [];

    for (var record in result) {
      // Process delivery status
      final deliveryStatusList =
          (record.expand['deliveryStatus'] as List?)?.map((status) {
                final statusRecord = status as RecordModel;
                return DeliveryUpdateModel.fromJson({
                  'id': statusRecord.id,
                  'collectionId': statusRecord.collectionId,
                  'collectionName': statusRecord.collectionName,
                  'title': statusRecord.data['title'],
                  'subtitle': statusRecord.data['subtitle'],
                  'time': statusRecord.data['time'],
                  'customer': statusRecord.data['customer'],
                  'isAssigned': statusRecord.data['isAssigned'],
                  'created': statusRecord.created,
                  'updated': statusRecord.updated
                });
              }).toList() ??
              [];

      // Process invoices
      final invoicesList =
          (record.expand['invoices'] as List?)?.map((invoice) {
                final invoiceRecord = invoice as RecordModel;
                return InvoiceModel.fromJson({
                  'id': invoiceRecord.id,
                  'collectionId': invoiceRecord.collectionId,
                  'collectionName': invoiceRecord.collectionName,
                  'invoiceNumber': invoiceRecord.data['invoiceNumber'],
                  'status': invoiceRecord.data['status'],
                  'productList': invoiceRecord.data['productsList'] ?? [],
                  'customer': invoiceRecord.data['customer'],
                  'totalAmount': record.data['totalAmount'],
                  'created': invoiceRecord.created,
                  'updated': invoiceRecord.updated
                });
              }).toList() ??
              [];

      // Process trip data
      TripModel? tripModel;
      String? tripId;
      String? tripNumberId;
      
      if (record.expand['trip'] != null) {
        final tripData = record.expand['trip'];
        if (tripData is List && tripData!.isNotEmpty) {
          final tripRecord = tripData[0];
          tripId = tripRecord.id;
          tripNumberId = tripRecord.data['tripNumberId'];
          tripModel = TripModel.fromJson({
            'id': tripRecord.id,
            'collectionId': tripRecord.collectionId,
            'collectionName': tripRecord.collectionName,
            'tripNumberId': tripRecord.data['tripNumberId'],
            'qrCode': tripRecord.data['qrCode'],
            'isAccepted': tripRecord.data['isAccepted'],
            'isEndTrip': tripRecord.data['isEndTrip'],
          });
          debugPrint('✅ Found trip ID: $tripId (Number: $tripNumberId) for customer: ${record.id}');
        }  else if (tripData is String) {
          tripId = tripData as String?;
          // If we only have the trip ID, try to fetch the trip details
          try {
            final tripRecord = await _pocketBaseClient
                .collection('tripticket')
                .getOne(tripId!);
            tripNumberId = tripRecord.data['tripNumberId'];
            tripModel = TripModel.fromJson({
              'id': tripRecord.id,
              'collectionId': tripRecord.collectionId,
              'collectionName': tripRecord.collectionName,
              'tripNumberId': tripRecord.data['tripNumberId'],
              'qrCode': tripRecord.data['qrCode'],
              'isAccepted': tripRecord.data['isAccepted'],
              'isEndTrip': tripRecord.data['isEndTrip'],
            });
          } catch (e) {
            debugPrint('⚠️ Could not fetch trip details: $e');
          }
        }
      }

      customers.add(CustomerModel(
        id: record.id,
        collectionId: record.collectionId,
        collectionName: record.collectionName,
        deliveryNumber: record.data['deliveryNumber'],
        storeName: record.data['storeName'],
        ownerName: record.data['ownerName'],
        contactNumber: record.data['contactNumber'] is String
            ? [record.data['contactNumber']]
            : (record.data['contactNumber'] as List?)?.map((e) => e.toString()).toList() ?? [],
        address: record.data['address'],
        municipality: record.data['municipality'],
        province: record.data['province'],
        modeOfPayment: record.data['modeOfPayment'],
        deliveryStatusList: deliveryStatusList,
        invoicesList: invoicesList,
        numberOfInvoices: invoicesList.length,
        hasNotes: record.data['hasNotes'] ?? false,
        confirmedTotalPayment: double.tryParse(
          record.data['confirmedTotalPayment']?.toString() ?? '0',
        ),
        totalAmount: record.data['totalAmount'],
        latitude: record.data['latitude'],
        longitude: record.data['longitude'],
        remarks: record.data['remarks'],
        notes: record.data['notes'],
        tripModel: tripModel,
        tripId: tripId,
      ));
    }

    return customers;
  } catch (e) {
    debugPrint('❌ Get All Customers failed: ${e.toString()}');
    throw ServerException(
      message: 'Failed to load all customers: ${e.toString()}',
      statusCode: '500',
    );
  }
}


  @override
  Future<CustomerModel> createCustomer({
    required String deliveryNumber,
    required String storeName,
    required String ownerName,
    required List<String> contactNumber,
    required String address,
    required String municipality,
    required String province,
    required String modeOfPayment,
    required String tripId,
    String? totalAmount,
    String? latitude,
    String? longitude,
    String? notes,
    String? remarks,
    bool? hasNotes,
    double? confirmedTotalPayment,
  }) async {
    try {
      debugPrint('🔄 Creating new customer');

      final body = {
        'deliveryNumber': deliveryNumber,
        'storeName': storeName,
        'ownerName': ownerName,
        'contactNumber': contactNumber.join(','),
        'address': address,
        'municipality': municipality,
        'province': province,
        'modeOfPayment': modeOfPayment,
        'trip': tripId,
      };

      if (totalAmount != null) body['totalAmount'] = totalAmount.toString();
      if (latitude != null) body['latitude'] = latitude;
      if (longitude != null) body['longitude'] = longitude;
      if (notes != null) body['notes'] = notes;
      if (remarks != null) body['remarks'] = remarks;
      if (hasNotes != null) body['hasNotes'] = hasNotes.toString();
      if (confirmedTotalPayment != null) {
        body['confirmedTotalPayment'] = confirmedTotalPayment.toString();
      }

      final record = await _pocketBaseClient
          .collection('customers')
          .create(body: body);

      // Fetch the created record with expanded relations
      final createdRecord = await _pocketBaseClient
          .collection('customers')
          .getOne(record.id, expand: 'deliveryStatus,invoices,trip');

      debugPrint('✅ Successfully created customer: ${record.id}');

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
        'latitude': createdRecord.data['latitude'],
        'longitude': createdRecord.data['longitude'],
        'remarks': createdRecord.data['remarks'] ?? '',
        'notes': createdRecord.data['notes'] ?? '',
        'totalTime': createdRecord.data['totalTime'] ?? '',
        'trip': tripId,
        'hasNotes': createdRecord.data['hasNotes'] ?? false,
        'confirmedTotalPayment': double.tryParse(
          createdRecord.data['confirmedTotalPayment']?.toString() ?? '0',
        ),
        'expand': {
          'deliveryStatus': createdRecord.expand['deliveryStatus'] ?? [],
          'invoices': createdRecord.expand['invoices'] ?? [],
        },
      };

      return CustomerModel.fromJson(mappedData);
    } catch (e) {
      debugPrint('❌ Create Customer failed: ${e.toString()}');
      throw ServerException(
        message: 'Failed to create customer: ${e.toString()}',
        statusCode: '500',
      );
    }
  }

  @override
  Future<bool> deleteCustomer(String id) async {
    try {
      debugPrint('🔄 Deleting customer: $id');

      await _pocketBaseClient.collection('customers').delete(id);

      debugPrint('✅ Successfully deleted customer');
      return true;
    } catch (e) {
      debugPrint('❌ Delete Customer failed: ${e.toString()}');
      throw ServerException(
        message: 'Failed to delete customer: ${e.toString()}',
        statusCode: '500',
      );
    }
  }

  @override
  Future<bool> deleteAllCustomers(List<String> ids) async {
    try {
      debugPrint('🔄 Deleting multiple customers: ${ids.length} items');

      for (final id in ids) {
        await _pocketBaseClient.collection('customers').delete(id);
      }

      debugPrint('✅ Successfully deleted all customers');
      return true;
    } catch (e) {
      debugPrint('❌ Delete All Customers failed: ${e.toString()}');
      throw ServerException(
        message: 'Failed to delete multiple customers: ${e.toString()}',
        statusCode: '500',
      );
    }
  }
}
