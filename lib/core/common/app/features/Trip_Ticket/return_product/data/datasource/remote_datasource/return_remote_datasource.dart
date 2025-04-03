import 'dart:convert';

import 'package:desktop_app/core/common/app/features/Trip_Ticket/customer/data/model/customer_model.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/invoice/data/models/invoice_models.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/return_product/data/model/return_model.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/trip/data/models/trip_models.dart';
import 'package:desktop_app/core/enums/product_return_reason.dart';
import 'package:desktop_app/core/errors/exceptions.dart';
import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';

abstract class ReturnRemoteDatasource {
  Future<List<ReturnModel>> getReturns(String tripId);
  Future<ReturnModel> getReturnByCustomerId(String customerId);

  // New functions
  Future<List<ReturnModel>> getAllReturns();
  Future<ReturnModel> createReturn({
    required String productName,
    required String productDescription,
    required ProductReturnReason reason,
    required DateTime returnDate,
    required int? productQuantityCase,
    required int? productQuantityPcs,
    required int? productQuantityPack,
    required int? productQuantityBox,
    required bool? isCase,
    required bool? isPcs,
    required bool? isBox,
    required bool? isPack,
    String? invoiceId,
    String? customerId,
    String? tripId,
  });
  Future<ReturnModel> updateReturn({
    required String id,
    String? productName,
    String? productDescription,
    ProductReturnReason? reason,
    DateTime? returnDate,
    int? productQuantityCase,
    int? productQuantityPcs,
    int? productQuantityPack,
    int? productQuantityBox,
    bool? isCase,
    bool? isPcs,
    bool? isBox,
    bool? isPack,
    String? invoiceId,
    String? customerId,
    String? tripId,
  });
  Future<bool> deleteReturn(String id);
  Future<bool> deleteAllReturns(List<String> ids);
}

class ReturnRemoteDatasourceImpl implements ReturnRemoteDatasource {
  const ReturnRemoteDatasourceImpl({required PocketBase pocketBaseClient})
    : _pocketBaseClient = pocketBaseClient;

  final PocketBase _pocketBaseClient;

  @override
  Future<List<ReturnModel>> getReturns(String tripId) async {
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
          .collection('returns')
          .getFullList(
            filter: 'trip = "$actualTripId"',
            expand: 'invoice,customer,trip',
          );

      debugPrint('✅ Retrieved ${records.length} returns from API');

      return records.map((record) {
        final mappedData = {
          'id': record.id,
          'collectionId': record.collectionId,
          'collectionName': record.collectionName,
          'productName': record.data['productName']?.toString(),
          'productDescription': record.data['productDescription']?.toString(),
          'productQuantityCase': int.tryParse(
            record.data['productQuantityCase']?.toString() ?? '0',
          ),
          'productQuantityPcs': int.tryParse(
            record.data['productQuantityPcs']?.toString() ?? '0',
          ),
          'productQuantityPack': int.tryParse(
            record.data['productQuantityPack']?.toString() ?? '0',
          ),
          'productQuantityBox': int.tryParse(
            record.data['productQuantityBox']?.toString() ?? '0',
          ),
          'isCase': record.data['isCase'] as bool?,
          'isPcs': record.data['isPcs'] as bool?,
          'isBox': record.data['isBox'] as bool?,
          'isPack': record.data['isPack'] as bool?,
          'reason': record.data['reason'],
          'returnDate': record.data['returnDate'],
          'trip': actualTripId,
          'expand': {
            'invoice':
                record.expand['invoice']?.map((invoice) => invoice.data).first,
            'customer':
                record.expand['customer']
                    ?.map((customer) => customer.data)
                    .first,
            'trip': record.expand['trip']?.map((trip) => trip.data).first,
          },
        };

        return ReturnModel.fromJson(mappedData);
      }).toList();
    } catch (e) {
      debugPrint('❌ Returns fetch failed: ${e.toString()}');
      throw ServerException(
        message: 'Failed to load returns: ${e.toString()}',
        statusCode: '500',
      );
    }
  }

  @override
  Future<ReturnModel> getReturnByCustomerId(String customerId) async {
    try {
      debugPrint('📍 Fetching returns for customer: $customerId');

      final customerRecord = await _pocketBaseClient
          .collection('customers')
          .getOne(
            customerId,
            expand: 'returnList,returnList.invoice,returnList.trip',
          );

      final returns = customerRecord.expand['returnList'] as List?;
      if (returns == null || returns.isEmpty) {
        throw const ServerException(
          message: 'No returns found for this customer',
          statusCode: '404',
        );
      }

      final returnRecord = returns.first as RecordModel;

      final invoices = returnRecord.expand['invoice'] as List?;
      final invoice =
          invoices?.isNotEmpty == true
              ? InvoiceModel.fromJson({
                'id': (invoices!.first as RecordModel).id,
                'collectionId': (invoices.first as RecordModel).collectionId,
                'collectionName':
                    (invoices.first as RecordModel).collectionName,
                ...(invoices.first as RecordModel).data,
              })
              : null;

      final customer = CustomerModel.fromJson({
        'id': customerRecord.id,
        'collectionId': customerRecord.collectionId,
        'collectionName': customerRecord.collectionName,
        ...customerRecord.data,
      });

      final trips = returnRecord.expand['trip'] as List?;
      final trip =
          trips?.isNotEmpty == true
              ? TripModel.fromJson({
                'id': (trips!.first as RecordModel).id,
                'collectionId': (trips.first as RecordModel).collectionId,
                'collectionName': (trips.first as RecordModel).collectionName,
                ...(trips.first as RecordModel).data,
              })
              : null;

      return ReturnModel(
        id: returnRecord.id,
        collectionId: returnRecord.collectionId,
        collectionName: returnRecord.collectionName,
        productName: returnRecord.data['productName']?.toString(),
        productDescription: returnRecord.data['productDescription']?.toString(),
        productQuantityCase: int.tryParse(
          returnRecord.data['productQuantityCase']?.toString() ?? '0',
        ),
        productQuantityPcs: int.tryParse(
          returnRecord.data['productQuantityPcs']?.toString() ?? '0',
        ),
        productQuantityPack: int.tryParse(
          returnRecord.data['productQuantityPack']?.toString() ?? '0',
        ),
        productQuantityBox: int.tryParse(
          returnRecord.data['productQuantityBox']?.toString() ?? '0',
        ),
        isCase: returnRecord.data['isCase'] as bool?,
        isPcs: returnRecord.data['isPcs'] as bool?,
        isBox: returnRecord.data['isBox'] as bool?,
        isPack: returnRecord.data['isPack'] as bool?,
        reason:
            returnRecord.data['reason'] != null
                ? ProductReturnReason.values.firstWhere(
                  (r) => r.toString() == returnRecord.data['reason'],
                  orElse: () => ProductReturnReason.damaged,
                )
                : null,
        returnDate: DateTime.tryParse(
          returnRecord.data['returnDate']?.toString() ?? '',
        ),
        invoice: invoice,
        customer: customer,
        trip: trip,
      );
    } catch (e) {
      debugPrint('❌ Error fetching return: ${e.toString()}');
      throw ServerException(
        message: 'Failed to fetch return: ${e.toString()}',
        statusCode: '500',
      );
    }
  }

  @override
  Future<ReturnModel> createReturn({
    required String productName,
    required String productDescription,
    required ProductReturnReason reason,
    required DateTime returnDate,
    required int? productQuantityCase,
    required int? productQuantityPcs,
    required int? productQuantityPack,
    required int? productQuantityBox,
    required bool? isCase,
    required bool? isPcs,
    required bool? isBox,
    required bool? isPack,
    String? invoiceId,
    String? customerId,
    String? tripId,
  }) async {
    try {
      debugPrint('🔄 Creating new return for product: $productName');

      final body = {
        'productName': productName,
        'productDescription': productDescription,
        'reason': reason.name,
        'returnDate': returnDate.toIso8601String(),
        'productQuantityCase': productQuantityCase?.toString() ?? '0',
        'productQuantityPcs': productQuantityPcs?.toString() ?? '0',
        'productQuantityPack': productQuantityPack?.toString() ?? '0',
        'productQuantityBox': productQuantityBox?.toString() ?? '0',
        'isCase': isCase?.toString() ?? 'false',
        'isPcs': isPcs?.toString() ?? 'false',
        'isBox': isBox?.toString() ?? 'false',
        'isPack': isPack?.toString() ?? 'false',
      };

      if (invoiceId != null) body['invoice'] = invoiceId;
      if (customerId != null) body['customer'] = customerId;
      if (tripId != null) body['trip'] = tripId;

      final record = await _pocketBaseClient
          .collection('returns')
          .create(body: body);

      // Fetch the created record with expanded relations
      final createdRecord = await _pocketBaseClient
          .collection('returns')
          .getOne(record.id, expand: 'invoice,customer,trip');

      debugPrint('✅ Return record created successfully: ${record.id}');

      // Process expanded data
      InvoiceModel? invoice;
      CustomerModel? customer;
      TripModel? trip;

      if (createdRecord.expand['invoice'] != null) {
        final invoiceData = createdRecord.expand['invoice']![0];
        invoice = InvoiceModel.fromJson({
          'id': invoiceData.id,
          'collectionId': invoiceData.collectionId,
          'collectionName': invoiceData.collectionName,
          ...invoiceData.data,
        });
      }

      if (createdRecord.expand['customer'] != null) {
        final customerData = createdRecord.expand['customer']![0];
        customer = CustomerModel.fromJson({
          'id': customerData.id,
          'collectionId': customerData.collectionId,
          'collectionName': customerData.collectionName,
          ...customerData.data,
        });
      }

      if (createdRecord.expand['trip'] != null) {
        final tripData = createdRecord.expand['trip']![0];
        trip = TripModel.fromJson({
          'id': tripData.id,
          'collectionId': tripData.collectionId,
          'collectionName': tripData.collectionName,
          ...tripData.data,
        });
      }

      return ReturnModel(
        id: createdRecord.id,
        collectionId: createdRecord.collectionId,
        collectionName: createdRecord.collectionName,
        productName: createdRecord.data['productName'],
        productDescription: createdRecord.data['productDescription'],
        productQuantityCase: int.tryParse(
          createdRecord.data['productQuantityCase']?.toString() ?? '0',
        ),
        productQuantityPcs: int.tryParse(
          createdRecord.data['productQuantityPcs']?.toString() ?? '0',
        ),
        productQuantityPack: int.tryParse(
          createdRecord.data['productQuantityPack']?.toString() ?? '0',
        ),
        productQuantityBox: int.tryParse(
          createdRecord.data['productQuantityBox']?.toString() ?? '0',
        ),
        isCase:
            createdRecord.data['isCase'] == 'true' ||
            createdRecord.data['isCase'] == true,
        isPcs:
            createdRecord.data['isPcs'] == 'true' ||
            createdRecord.data['isPcs'] == true,
        isBox:
            createdRecord.data['isBox'] == 'true' ||
            createdRecord.data['isBox'] == true,
        isPack:
            createdRecord.data['isPack'] == 'true' ||
            createdRecord.data['isPack'] == true,
        reason: reason,
        returnDate: returnDate,
        invoice: invoice,
        customer: customer,
        trip: trip,
      );
    } catch (e) {
      debugPrint('❌ Return creation failed: ${e.toString()}');
      throw ServerException(
        message: 'Failed to create return: ${e.toString()}',
        statusCode: '500',
      );
    }
  }

  @override
  Future<bool> deleteAllReturns(List<String> ids) async {
    try {
      debugPrint('🔄 Deleting multiple returns: ${ids.length} items');

      int successCount = 0;
      List<String> failedIds = [];

      // Process each deletion individually to handle partial failures
      for (final id in ids) {
        try {
          await _pocketBaseClient.collection('returns').delete(id);
          successCount++;
          debugPrint('✓ Successfully deleted return: $id');
        } catch (individualError) {
          failedIds.add(id);
          debugPrint('⚠️ Failed to delete return $id: $individualError');
          // Continue with other deletions even if one fails
        }
      }

      // Log summary of operation
      if (failedIds.isEmpty) {
        debugPrint('✅ All ${ids.length} returns deleted successfully');
        return true;
      } else {
        debugPrint(
          '⚠️ Partial success: $successCount/${ids.length} returns deleted',
        );
        debugPrint('❌ Failed to delete returns: ${failedIds.join(', ')}');

        // If more than half were successful, consider it a success
        if (successCount > ids.length / 2) {
          return true;
        } else {
          throw ServerException(
            message:
                'Failed to delete majority of returns. Only $successCount/${ids.length} were successful.',
            statusCode: '500',
          );
        }
      }
    } catch (e) {
      debugPrint('❌ Bulk return deletion failed: ${e.toString()}');
      throw ServerException(
        message: 'Failed to delete returns: ${e.toString()}',
        statusCode: '500',
      );
    }
  }

  @override
  Future<bool> deleteReturn(String id) async {
    try {
      debugPrint('🔄 Deleting return: $id');

      await _pocketBaseClient.collection('returns').delete(id);

      debugPrint('✅ Return deleted successfully');
      return true;
    } catch (e) {
      debugPrint('❌ Return deletion failed: ${e.toString()}');
      throw ServerException(
        message: 'Failed to delete return: ${e.toString()}',
        statusCode: '500',
      );
    }
  }
  @override
Future<List<ReturnModel>> getAllReturns() async {
  try {
    debugPrint('🔄 Fetching all returns');
    
    final records = await _pocketBaseClient
        .collection('returns')
        .getFullList(expand: 'invoice,customer,trip');
    
    debugPrint('✅ Retrieved ${records.length} returns from API');
    
    List<ReturnModel> returnsList = [];
    
    for (final record in records) {
      try {
        debugPrint('📦 Processing return record: ${record.id}');
        
        // Check if we have product data or just an ID
        if (record.data['productName'] == null) {
          debugPrint('   🏷️ Product data: ${record.id} (ID only)');
          // This is just an ID reference, create a minimal model
          returnsList.add(ReturnModel(id: record.id));
          continue;
        }
        
        // Create a direct ReturnModel without using fromJson
        final returnModel = ReturnModel(
          id: record.id,
          collectionId: record.collectionId,
          collectionName: record.collectionName,
          productName: record.data['productName']?.toString(),
          productDescription: record.data['productDescription']?.toString(),
          productQuantityCase: int.tryParse(
            record.data['productQuantityCase']?.toString() ?? '0',
          ),
          productQuantityPcs: int.tryParse(
            record.data['productQuantityPcs']?.toString() ?? '0',
          ),
          productQuantityPack: int.tryParse(
            record.data['productQuantityPack']?.toString() ?? '0',
          ),
          productQuantityBox: int.tryParse(
            record.data['productQuantityBox']?.toString() ?? '0',
          ),
          isCase: record.data['isCase'] == true || record.data['isCase'] == 'true',
          isPcs: record.data['isPcs'] == true || record.data['isPcs'] == 'true',
          isBox: record.data['isBox'] == true || record.data['isBox'] == 'true',
          isPack: record.data['isPack'] == true || record.data['isPack'] == 'true',
          reason: record.data['reason'] != null 
              ? _parseReturnReason(record.data['reason'].toString())
              : null,
          returnDate: record.data['returnDate'] != null 
              ? DateTime.tryParse(record.data['returnDate'].toString())
              : null,
          tripId: record.data['trip']?.toString(),
        );
        
        // Process expanded data if available
        if (record.expand.isNotEmpty) {
          // Process invoice
          if (record.expand['invoice'] != null) {
            final invoiceData = record.expand['invoice'];
            if (invoiceData is List && invoiceData!.isNotEmpty) {
              try {
                final invoiceRecord = invoiceData.first;
                final invoice = InvoiceModel.fromJson({
                  'id': invoiceRecord.id,
                  'collectionId': invoiceRecord.collectionId,
                  'collectionName': invoiceRecord.collectionName,
                  ...Map<String, dynamic>.from(invoiceRecord.data),
                });
                returnModel.invoice = invoice;
                            } catch (e) {
                debugPrint('⚠️ Error processing invoice: $e');
              }
            }
          }
          
          // Process customer
          if (record.expand['customer'] != null) {
            final customerData = record.expand['customer'];
            if (customerData is List && customerData!.isNotEmpty) {
              try {
                final customerRecord = customerData.first;
                final customer = CustomerModel.fromJson({
                  'id': customerRecord.id,
                  'collectionId': customerRecord.collectionId,
                  'collectionName': customerRecord.collectionName,
                  ...Map<String, dynamic>.from(customerRecord.data),
                });
                returnModel.customer = customer;
                            } catch (e) {
                debugPrint('⚠️ Error processing customer: $e');
              }
            }
          }
          
          // Process trip
          if (record.expand['trip'] != null) {
            final tripData = record.expand['trip'];
            if (tripData is List && tripData!.isNotEmpty) {
              try {
                final tripRecord = tripData.first;
                final trip = TripModel.fromJson({
                  'id': tripRecord.id,
                  'collectionId': tripRecord.collectionId,
                  'collectionName': tripRecord.collectionName,
                  ...Map<String, dynamic>.from(tripRecord.data),
                });
                returnModel.trip = trip;
                            } catch (e) {
                debugPrint('⚠️ Error processing trip: $e');
              }
            }
          }
        }
        
        returnsList.add(returnModel);
        debugPrint('✅ Successfully processed return: ${record.id}');
        
      } catch (itemError) {
        debugPrint('⚠️ Error processing return item: $itemError');
        // Add a minimal model with just the ID to avoid losing the entire list
        returnsList.add(ReturnModel(id: record.id));
      }
    }
    
    debugPrint('✅ Successfully fetched ${returnsList.length} returns');
    return returnsList;
    
  } catch (e) {
    debugPrint('❌ Returns fetch failed: ${e.toString()}');
    throw ServerException(
      message: 'Failed to load all returns: ${e.toString()}',
      statusCode: '500',
    );
  }
}


// Helper method to parse return reason
ProductReturnReason _parseReturnReason(String reasonStr) {
  try {
    // First try to match the exact string
    for (var reason in ProductReturnReason.values) {
      if (reason.toString() == reasonStr || 
          reason.toString() == 'ProductReturnReason.$reasonStr') {
        return reason;
      }
    }
    
    // If not found, try to match just the name part
    for (var reason in ProductReturnReason.values) {
      final reasonName = reason.toString().split('.').last;
      if (reasonStr == reasonName) {
        return reason;
      }
    }
    
    // Default fallback
    return ProductReturnReason.damaged;
  } catch (_) {
    return ProductReturnReason.damaged;
  }
}

  @override
  Future<ReturnModel> updateReturn({
    required String id,
    String? productName,
    String? productDescription,
    ProductReturnReason? reason,
    DateTime? returnDate,
    int? productQuantityCase,
    int? productQuantityPcs,
    int? productQuantityPack,
    int? productQuantityBox,
    bool? isCase,
    bool? isPcs,
    bool? isBox,
    bool? isPack,
    String? invoiceId,
    String? customerId,
    String? tripId,
  }) async {
    try {
      debugPrint('🔄 Updating return: $id');

      final body = <String, dynamic>{};

      if (productName != null) body['productName'] = productName;
      if (productDescription != null) {
        body['productDescription'] = productDescription;
      }
      if (reason != null) body['reason'] = reason.name;
      if (returnDate != null) body['returnDate'] = returnDate.toIso8601String();
      if (productQuantityCase != null) {
        body['productQuantityCase'] = productQuantityCase.toString();
      }
      if (productQuantityPcs != null) {
        body['productQuantityPcs'] = productQuantityPcs.toString();
      }
      if (productQuantityPack != null) {
        body['productQuantityPack'] = productQuantityPack.toString();
      }
      if (productQuantityBox != null) {
        body['productQuantityBox'] = productQuantityBox.toString();
      }
      if (isCase != null) body['isCase'] = isCase.toString();
      if (isPcs != null) body['isPcs'] = isPcs.toString();
      if (isBox != null) body['isBox'] = isBox.toString();
      if (isPack != null) body['isPack'] = isPack.toString();
      if (invoiceId != null) body['invoice'] = invoiceId;
      if (customerId != null) body['customer'] = customerId;
      if (tripId != null) body['trip'] = tripId;

      await _pocketBaseClient.collection('returns').update(id, body: body);

      // Fetch the updated record with expanded relations
      final updatedRecord = await _pocketBaseClient
          .collection('returns')
          .getOne(id, expand: 'invoice,customer,trip');

      debugPrint('✅ Return record updated successfully');

      // Process expanded data
      InvoiceModel? invoice;
      CustomerModel? customer;
      TripModel? trip;

      if (updatedRecord.expand['invoice'] != null) {
        final invoiceData = updatedRecord.expand['invoice']![0];
        invoice = InvoiceModel.fromJson({
          'id': invoiceData.id,
          'collectionId': invoiceData.collectionId,
          'collectionName': invoiceData.collectionName,
          ...invoiceData.data,
        });
      }

      if (updatedRecord.expand['customer'] != null) {
        final customerData = updatedRecord.expand['customer']![0];
        customer = CustomerModel.fromJson({
          'id': customerData.id,
          'collectionId': customerData.collectionId,
          'collectionName': customerData.collectionName,
          ...customerData.data,
        });
      }

      if (updatedRecord.expand['trip'] != null) {
        final tripData = updatedRecord.expand['trip']![0];
        trip = TripModel.fromJson({
          'id': tripData.id,
          'collectionId': tripData.collectionId,
          'collectionName': tripData.collectionName,
          ...tripData.data,
        });
      }

      return ReturnModel(
        id: updatedRecord.id,
        collectionId: updatedRecord.collectionId,
        collectionName: updatedRecord.collectionName,
        productName: updatedRecord.data['productName'],
        productDescription: updatedRecord.data['productDescription'],
        productQuantityCase: int.tryParse(
          updatedRecord.data['productQuantityCase']?.toString() ?? '0',
        ),
        productQuantityPcs: int.tryParse(
          updatedRecord.data['productQuantityPcs']?.toString() ?? '0',
        ),
        productQuantityPack: int.tryParse(
          updatedRecord.data['productQuantityPack']?.toString() ?? '0',
        ),
        productQuantityBox: int.tryParse(
          updatedRecord.data['productQuantityBox']?.toString() ?? '0',
        ),
        isCase:
            updatedRecord.data['isCase'] == 'true' ||
            updatedRecord.data['isCase'] == true,
        isPcs:
            updatedRecord.data['isPcs'] == 'true' ||
            updatedRecord.data['isPcs'] == true,
        isBox:
            updatedRecord.data['isBox'] == 'true' ||
            updatedRecord.data['isBox'] == true,
        isPack:
            updatedRecord.data['isPack'] == 'true' ||
            updatedRecord.data['isPack'] == true,
        reason:
            reason ??
            ProductReturnReason.values.firstWhere(
              (r) => r.name == updatedRecord.data['reason'],
              orElse: () => ProductReturnReason.damaged,
            ),
        returnDate:
            returnDate ??
            DateTime.tryParse(updatedRecord.data['returnDate'] ?? ''),
        invoice: invoice,
        customer: customer,
        trip: trip,
      );
    } catch (e) {
      debugPrint('❌ Return update failed: ${e.toString()}');
      throw ServerException(
        message: 'Failed to update return: ${e.toString()}',
        statusCode: '500',
      );
    }
  }
}
