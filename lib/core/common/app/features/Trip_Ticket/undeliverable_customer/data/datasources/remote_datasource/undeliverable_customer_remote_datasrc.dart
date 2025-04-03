import 'dart:convert';
import 'dart:io';

import 'package:desktop_app/core/common/app/features/Trip_Ticket/customer/data/model/customer_model.dart'
    show CustomerModel;
import 'package:desktop_app/core/common/app/features/Trip_Ticket/invoice/data/models/invoice_models.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/trip/data/models/trip_models.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/undeliverable_customer/data/model/undeliverable_customer_model.dart';
import 'package:desktop_app/core/enums/undeliverable_reason.dart';
import 'package:desktop_app/core/errors/exceptions.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:pocketbase/pocketbase.dart';

abstract class UndeliverableCustomerRemoteDataSource {
  Future<List<UndeliverableCustomerModel>> getUndeliverableCustomers(
    String tripId,
  );
  Future<UndeliverableCustomerModel> createUndeliverableCustomer(
    UndeliverableCustomerModel undeliverableCustomer,
    String customerId,
  );
  Future<void> saveUndeliverableCustomer(
    UndeliverableCustomerModel undeliverableCustomer,
    String customerId,
  );
  Future<void> updateUndeliverableCustomer(
    UndeliverableCustomerModel undeliverableCustomer,
    String tripId,
  );
  Future<void> deleteUndeliverableCustomer(String undeliverableCustomerId);
  Future<void> setUndeliverableReason(
    String customerId,
    UndeliverableReason reason,
  );
  Future<UndeliverableCustomerModel> getUndeliverableCustomerById(
    String customerId,
  );
  // Add these to the UndeliverableCustomerRemoteDataSource interface
  Future<List<UndeliverableCustomerModel>> getAllUndeliverableCustomers();
  Future<bool> deleteAllUndeliverableCustomers();
}

class UndeliverableCustomerRemoteDataSourceImpl
    implements UndeliverableCustomerRemoteDataSource {
  const UndeliverableCustomerRemoteDataSourceImpl({
    required PocketBase pocketBaseClient,
  }) : _pocketBaseClient = pocketBaseClient;

  final PocketBase _pocketBaseClient;
  @override
  Future<List<UndeliverableCustomerModel>> getUndeliverableCustomers(
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
          .collection('undeliverable_customers')
          .getFullList(
            filter: 'trip = "$actualTripId"',
            expand: 'customer,invoices,trip',
          );

      debugPrint(
        '✅ Retrieved ${records.length} undeliverable customers from API',
      );

      return records.map((record) {
        final customerData = record.expand['customer']?[0];
        final customer =
            customerData != null
                ? CustomerModel(
                  id: customerData.id,
                  collectionId: customerData.collectionId,
                  collectionName: customerData.collectionName,
                  storeName: customerData.data['storeName'],
                  ownerName: customerData.data['ownerName'],
                  contactNumber: [customerData.data['contactNumber']],
                  address: customerData.data['address'],
                  municipality: customerData.data['municipality'],
                  province: customerData.data['province'],
                  modeOfPayment: customerData.data['modeOfPayment'],
                )
                : null;

        final invoicesList =
            (record.expand['invoices'] as List?)?.map((invoice) {
              final invoiceRecord = invoice as RecordModel;
              return InvoiceModel.fromJson({
                'id': invoiceRecord.id,
                'collectionId': invoiceRecord.collectionId,
                'collectionName': invoiceRecord.collectionName,
                'invoiceNumber': invoiceRecord.data['invoiceNumber'],
                'status': invoiceRecord.data['status'],
                'customer': invoiceRecord.data['customer'],
                'created': invoiceRecord.created,
                'updated': invoiceRecord.updated,
              });
            }).toList() ??
            [];

        return UndeliverableCustomerModel(
          id: record.id,
          collectionId: record.collectionId,
          collectionName: record.collectionName,
          reason:
              record.data['reason'] != null
                  ? UndeliverableReason.values.firstWhere(
                    (r) =>
                        r.toString().split('.').last == record.data['reason'],
                    orElse: () => UndeliverableReason.none,
                  )
                  : UndeliverableReason.none,
          time: DateTime.tryParse(record.data['time'] ?? ''),
          customer: customer,
          invoicesList: invoicesList,
        );
      }).toList();
    } catch (e) {
      debugPrint('❌ Remote data fetch failed: ${e.toString()}');
      throw ServerException(
        message: 'Failed to load undeliverable customers: ${e.toString()}',
        statusCode: '500',
      );
    }
  }

  @override
  Future<UndeliverableCustomerModel> getUndeliverableCustomerById(
    String customerId,
  ) async {
    try {
      debugPrint('📍 Fetching data for undeliverable customer: $customerId');

      final record = await _pocketBaseClient
          .collection('undeliverable_customers')
          .getOne(customerId, expand: 'customer,invoices,trip');

      // Map customer data
      final customerData = record.expand['customer']?[0];
      final customer =
          customerData != null
              ? CustomerModel(
                id: customerData.id,
                collectionId: customerData.collectionId,
                collectionName: customerData.collectionName,
                storeName: customerData.data['storeName'],
                ownerName: customerData.data['ownerName'],
                contactNumber: [customerData.data['contactNumber']],
                address: customerData.data['address'],
                municipality: customerData.data['municipality'],
                province: customerData.data['province'],
                modeOfPayment: customerData.data['modeOfPayment'],
              )
              : null;

      // Map invoices
      final invoicesList =
          (record.expand['invoices'] as List?)?.map((invoice) {
            final invoiceRecord = invoice as RecordModel;
            return InvoiceModel.fromJson({
              'id': invoiceRecord.id,
              'collectionId': invoiceRecord.collectionId,
              'collectionName': invoiceRecord.collectionName,
              'invoiceNumber': invoiceRecord.data['invoiceNumber'],
              'status': invoiceRecord.data['status'],
              'customer': invoiceRecord.data['customer'],
              'created': invoiceRecord.created,
              'updated': invoiceRecord.updated,
            });
          }).toList() ??
          [];

      return UndeliverableCustomerModel(
        id: record.id,
        collectionId: record.collectionId,
        collectionName: record.collectionName,
        reason:
            record.data['reason'] != null
                ? UndeliverableReason.values.firstWhere(
                  (r) => r.toString().split('.').last == record.data['reason'],
                  orElse: () => UndeliverableReason.none,
                )
                : UndeliverableReason.none,
        time: DateTime.tryParse(record.data['time'] ?? ''),
        customer: customer,
        invoicesList: invoicesList,
      );
    } catch (e) {
      debugPrint('❌ Error fetching undeliverable customer: ${e.toString()}');
      throw ServerException(
        message: 'Failed to fetch undeliverable customer: ${e.toString()}',
        statusCode: '500',
      );
    }
  }

  @override
  Future<UndeliverableCustomerModel> createUndeliverableCustomer(
    UndeliverableCustomerModel undeliverableCustomer,
    String customerId,
  ) async {
    try {
      debugPrint(
        '🔄 Creating undeliverable customer record for ID: $customerId',
      );

      final customerRecord = await _pocketBaseClient
          .collection('customers')
          .getOne(customerId, expand: 'trip,invoices(customer)');

      final tripId = customerRecord.expand['trip']?[0].id;
      debugPrint('🚚 Found assigned trip ID: $tripId');

      final invoiceIds =
          customerRecord.expand['invoices(customer)']
              ?.map((inv) => inv.id)
              .toList() ??
          [];

      debugPrint('📝 Invoice IDs: $invoiceIds');

      // Extract customer details from the customer record
      final storeName = customerRecord.data['storeName'] as String? ?? '';
      final ownerName = customerRecord.data['ownerName'] as String? ?? '';
      final deliveryNumber =
          customerRecord.data['deliveryNumber'] as String? ?? '';

      debugPrint(
        '👤 Customer details - Store: $storeName, Owner: $ownerName, Delivery #: $deliveryNumber',
      );

      final currentTime = DateTime.now().toUtc().toIso8601String();

      final body = {
        'customer': customerId,
        'invoices': invoiceIds,
        'reason': undeliverableCustomer.reason?.toString().split('.').last,
        'time': currentTime,
        'trip': tripId,
        'transactionDate': currentTime,
        'created': currentTime,
        'updated': currentTime,
        // Add customer details to the undeliverable customer record
        'storeName': storeName,
        'ownerName': ownerName,
        'deliveryNumber': deliveryNumber,
        // Include address fields if available in the customer record
        'address': customerRecord.data['address'] as String? ?? '',
        'municipality': customerRecord.data['municipality'] as String? ?? '',
        'province': customerRecord.data['province'] as String? ?? '',
        'modeOfPayment': customerRecord.data['modeOfPayment'] as String? ?? '',
        // Include contact number if available
        'contactNumber': customerRecord.data['contactNumber'],
      };

      debugPrint('📝 Creating record with body: $body');

      final files = <String, MultipartFile>{};

      if (undeliverableCustomer.customerImage != null) {
        final imagePaths = undeliverableCustomer.customerImage!.split(',');
        for (var i = 0; i < imagePaths.length; i++) {
          final imageBytes = await File(imagePaths[i]).readAsBytes();
          files['customerImage'] = MultipartFile.fromBytes(
            'customerImage',
            imageBytes,
            filename: 'customer_image_$i.jpg',
          );
        }
      }
      // After creating undeliverable customer record
      final record = await _pocketBaseClient
          .collection('undeliverable_customers')
          .create(body: body, files: files.values.toList());

      // Update tripticket with undelivered customer reference
      await _pocketBaseClient
          .collection('tripticket')
          .update(tripId!, body: {'undeliveredCustomer': record.id});
      debugPrint(
        '✅ Updated tripticket with undelivered customer ID: ${record.id}',
      );

      // Update delivery team statistics
      final deliveryTeamRecords = await _pocketBaseClient
          .collection('delivery_team')
          .getList(filter: 'tripTicket = "$tripId"');

      if (deliveryTeamRecords.items.isNotEmpty) {
        final deliveryTeamRecord = deliveryTeamRecords.items.first;
        debugPrint('✅ Found delivery team: ${deliveryTeamRecord.id}');

        final currentUndelivered =
            int.tryParse(
              deliveryTeamRecord.data['undeliveredCustomers']?.toString() ?? '',
            ) ??
            0;
        final currentActive =
            int.tryParse(
              deliveryTeamRecord.data['activeDeliveries']?.toString() ?? '',
            ) ??
            0;

        await _pocketBaseClient
            .collection('delivery_team')
            .update(
              deliveryTeamRecord.id,
              body: {
                'undeliveredCustomers': (currentUndelivered + 1).toString(),
                'activeDeliveries': (currentActive - 1).toString(),
              },
            );

        debugPrint('✅ Delivery team stats updated successfully');
      }

      debugPrint(
        '✅ Undeliverable customer created and team stats updated successfully',
      );
      return UndeliverableCustomerModel.fromJson(record.toJson());
    } catch (e) {
      debugPrint('❌ Failed to create undeliverable customer: $e');
      throw ServerException(
        message: 'Failed to create undeliverable customer: $e',
        statusCode: '500',
      );
    }
  }

  @override
  Future<void> saveUndeliverableCustomer(
    UndeliverableCustomerModel undeliverableCustomer,
    String customerId,
  ) async {
    try {
      debugPrint('🔄 Saving undeliverable customer for ID: $customerId');

      final customerRecord = await _pocketBaseClient
          .collection('customers')
          .getOne(customerId, expand: 'trip,invoices(customer)');

      final tripId = customerRecord.expand['trip']?[0].id;
      debugPrint('🚚 Found assigned trip ID: $tripId');

      await _pocketBaseClient
          .collection('undeliverable_customers')
          .create(
            body: {
              ...undeliverableCustomer.toJson(),
              'customer': customerId,
              'trip': tripId,
            },
          );

      debugPrint('✅ Undeliverable customer saved successfully');
    } catch (e) {
      debugPrint('❌ Failed to save undeliverable customer: ${e.toString()}');
      throw ServerException(
        message: 'Failed to save undeliverable customer: ${e.toString()}',
        statusCode: '500',
      );
    }
  }

  @override
  Future<void> updateUndeliverableCustomer(
    UndeliverableCustomerModel undeliverableCustomer,
    String tripId,
  ) async {
    try {
      debugPrint('🔄 Updating undeliverable customer for trip: $tripId');

      await _pocketBaseClient
          .collection('undeliverable_customers')
          .update(
            undeliverableCustomer.id!,
            body: {
              ...undeliverableCustomer.toJson(),
              'trip': tripId,
              'updated': DateTime.now().toIso8601String(),
            },
          );

      debugPrint('✅ Undeliverable customer updated successfully');
    } catch (e) {
      debugPrint('❌ Failed to update undeliverable customer: ${e.toString()}');
      throw ServerException(
        message: 'Failed to update undeliverable customer: ${e.toString()}',
        statusCode: '500',
      );
    }
  }

  @override
  Future<void> deleteUndeliverableCustomer(
    String undeliverableCustomerId,
  ) async {
    try {
      debugPrint('🔄 Deleting undeliverable customer');

      await _pocketBaseClient
          .collection('undeliverable_customers')
          .delete(undeliverableCustomerId);

      debugPrint('✅ Undeliverable customer deleted successfully');
    } catch (e) {
      debugPrint('❌ Failed to delete undeliverable customer: ${e.toString()}');
      throw ServerException(
        message: 'Failed to delete undeliverable customer: ${e.toString()}',
        statusCode: '500',
      );
    }
  }

  @override
  Future<void> setUndeliverableReason(
    String customerId,
    UndeliverableReason reason,
  ) async {
    try {
      debugPrint('🔄 Setting undeliverable reason for customer: $customerId');

      await _pocketBaseClient
          .collection('undeliverable_customers')
          .update(
            customerId,
            body: {
              'reason': reason.toString().split('.').last,
              'updated': DateTime.now().toIso8601String(),
            },
          );

      debugPrint('✅ Undeliverable reason updated successfully');
    } catch (e) {
      debugPrint('❌ Failed to set undeliverable reason: ${e.toString()}');
      throw ServerException(
        message: 'Failed to set undeliverable reason: ${e.toString()}',
        statusCode: '500',
      );
    }
  }
 @override
Future<List<UndeliverableCustomerModel>> getAllUndeliverableCustomers() async {
  try {
    debugPrint('🔄 Fetching all undeliverable customers');

    final records = await _pocketBaseClient
        .collection('undeliverable_customers')
        .getFullList(expand: 'invoices,trip');

    debugPrint(
      '✅ Retrieved ${records.length} undeliverable customers from API',
    );

    List<UndeliverableCustomerModel> result = [];

    for (var record in records) {
      try {
        // Debug print to identify the problematic field
        debugPrint('Processing record ID: ${record.id}');
        debugPrint('Record data: ${record.data}');
        
        // Check each field type before assignment
        final String? storeName = _safeGetString(record.data, 'storeName');
        final String? ownerName = _safeGetString(record.data, 'ownerName');
        final String? deliveryNumber = _safeGetString(record.data, 'deliveryNumber');
        final String? address = _safeGetString(record.data, 'address');
        final String? municipality = _safeGetString(record.data, 'municipality');
        final String? province = _safeGetString(record.data, 'province');
        final String? modeOfPayment = _safeGetString(record.data, 'modeOfPayment');
        final String? customerImage = _safeGetString(record.data, 'customerImage');
        final String? customerId = _safeGetString(record.data, 'customer');
        final String? tripId = _safeGetString(record.data, 'trip');
        final String? reasonStr = _safeGetString(record.data, 'reason');
        
        // Process invoices
        List<InvoiceModel> invoicesList = [];
        if (record.expand['invoices'] != null && record.expand['invoices'] is List) {
          for (var invoice in record.expand['invoices']!) {
            try {
              final invoiceRecord = invoice;
              invoicesList.add(InvoiceModel.fromJson({
                'id': invoiceRecord.id,
                'collectionId': invoiceRecord.collectionId,
                'collectionName': invoiceRecord.collectionName,
                'invoiceNumber': invoiceRecord.data['invoiceNumber'],
                'status': invoiceRecord.data['status'],
                'customer': invoiceRecord.data['customer'],
                'created': invoiceRecord.created,
                'updated': invoiceRecord.updated,
              }));
            } catch (e) {
              debugPrint('❌ Error processing invoice: $e');
            }
          }
        }

        // Process trip data
        TripModel? trip;
        if (record.expand['trip'] != null && record.expand['trip'] is List && (record.expand['trip'] as List).isNotEmpty) {
          try {
            final tripRecord = (record.expand['trip'] as List)[0] as RecordModel;
            trip = TripModel(
              id: tripRecord.id,
              collectionId: tripRecord.collectionId,
              collectionName: tripRecord.collectionName,
            );
          } catch (e) {
            debugPrint('❌ Error processing trip: $e');
          }
        }

        // Determine reason enum
        UndeliverableReason reason = UndeliverableReason.none;
        if (reasonStr != null) {
          try {
            reason = UndeliverableReason.values.firstWhere(
              (r) => r.toString().split('.').last == reasonStr,
              orElse: () => UndeliverableReason.none,
            );
          } catch (e) {
            debugPrint('❌ Error processing reason: $e');
          }
        }

        // Parse time
        DateTime? time;
        try {
          final timeStr = record.data['time'];
          if (timeStr != null && timeStr is String) {
            time = DateTime.tryParse(timeStr);
          }
        } catch (e) {
          debugPrint('❌ Error parsing time: $e');
        }

        // Create the model
        final model = UndeliverableCustomerModel(
          id: record.id,
          collectionId: record.collectionId,
          collectionName: record.collectionName,
          storeName: storeName ?? '',
          ownerName: ownerName ?? '',
          deliveryNumber: deliveryNumber ?? '',
          address: address ?? '',
          municipality: municipality ?? '',
          province: province ?? '',
          modeOfPayment: modeOfPayment ?? '',
          reason: reason,
          time: time,
          customerImage: customerImage,
          invoicesList: invoicesList,
          trip: trip,
          customerId: customerId,
          tripId: tripId,
        );

        result.add(model);
        debugPrint('✅ Successfully processed undeliverable customer: ${record.id}');
      } catch (e) {
        debugPrint('❌ Error processing undeliverable customer record: $e');
        // Add a minimal model to avoid breaking the list
        result.add(UndeliverableCustomerModel(
          id: record.id,
          reason: UndeliverableReason.none,
        ));
      }
    }

    debugPrint('✅ Successfully retrieved ${result.length} undeliverable customers');
    return result;
  } catch (e) {
    debugPrint('❌ Remote data fetch failed: ${e.toString()}');
    throw ServerException(
      message: 'Failed to load all undeliverable customers: ${e.toString()}',
      statusCode: '500',
    );
  }
}

// Helper method to safely get a string value from a map
String? _safeGetString(Map<String, dynamic> data, String key) {
  final value = data[key];
  if (value == null) {
    return null;
  }
  
  if (value is String) {
    return value;
  }
  
  if (value is List) {
    debugPrint('⚠️ WARNING: Field "$key" is a List, not a String. Value: $value');
    return null;
  }
  
  debugPrint('⚠️ WARNING: Field "$key" is not a String. Type: ${value.runtimeType}, Value: $value');
  return value.toString();
}



  @override
  Future<bool> deleteAllUndeliverableCustomers() async {
    try {
      debugPrint('🔄 Deleting all undeliverable customers');

      // Get all undeliverable customers
      final records =
          await _pocketBaseClient
              .collection('undeliverable_customers')
              .getFullList();

      // Group by trip for efficient updates
      final customersByTrip = <String, List<String>>{};

      for (final record in records) {
        final tripId = record.data['trip'];
        if (tripId != null) {
          customersByTrip.putIfAbsent(tripId, () => []).add(record.id);
        }
      }

      // Delete all records
      for (final record in records) {
        await _pocketBaseClient
            .collection('undeliverable_customers')
            .delete(record.id);
      }

      // Update trip records
      for (final entry in customersByTrip.entries) {
        await _pocketBaseClient
            .collection('tripticket')
            .update(entry.key, body: {'undeliveredCustomer': null});
      }

      debugPrint('✅ All undeliverable customers deleted successfully');
      return true;
    } catch (e) {
      debugPrint(
        '❌ Failed to delete all undeliverable customers: ${e.toString()}',
      );
      throw ServerException(
        message:
            'Failed to delete all undeliverable customers: ${e.toString()}',
        statusCode: '500',
      );
    }
  }
}
