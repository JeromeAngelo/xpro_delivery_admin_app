import 'dart:convert';

import 'package:desktop_app/core/common/app/features/Trip_Ticket/customer/data/model/customer_model.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/invoice/data/models/invoice_models.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/products/data/model/product_model.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/trip/data/models/trip_models.dart';
import 'package:desktop_app/core/enums/invoice_status.dart';
//import 'package:desktop_app/core/enums/product_return_reason.dart';
import 'package:desktop_app/core/enums/product_unit.dart';
import 'package:desktop_app/core/enums/products_status.dart';
import 'package:desktop_app/core/errors/exceptions.dart';
import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';


abstract class InvoiceRemoteDatasource {
  Future<List<InvoiceModel>> getInvoices();
  Future<List<InvoiceModel>> getInvoicesByTripId(String tripId);
  Future<List<InvoiceModel>> getInvoicesByCustomerId(String customerId);
   Future<InvoiceModel> getInvoiceById(String invoiceId); // New method
   // New function
  Future<List<InvoiceModel>> getInvoicesByCompletedCustomerId(String completedCustomerId);

  // New functions
  Future<InvoiceModel> createInvoice({
    required String invoiceNumber,
    required String customerId,
    required String tripId,
    required List<String> productIds,
    InvoiceStatus? status,
    double? totalAmount,
    double? confirmTotalAmount,
    String? customerDeliveryStatus,
  });
  
  Future<InvoiceModel> updateInvoice({
    required String id,
    String? invoiceNumber,
    String? customerId,
    String? tripId,
    List<String>? productIds,
    InvoiceStatus? status,
    double? totalAmount,
    double? confirmTotalAmount,
    String? customerDeliveryStatus,
  });
  
  Future<bool> deleteInvoice(String id);
  
  Future<bool> deleteAllInvoices(List<String> ids);
}

class InvoiceRemoteDatasourceImpl implements InvoiceRemoteDatasource {
  InvoiceRemoteDatasourceImpl({required PocketBase pocketBaseClient})
      : _pocketBaseClient = pocketBaseClient;

  final PocketBase _pocketBaseClient;
  @override
  Future<List<InvoiceModel>> getInvoices() async {
    try {
      debugPrint('🔄 Fetching all invoices');

      // Get invoices with expanded relations
      final result = await _pocketBaseClient.collection('invoices').getFullList(
            expand: 'customer,customer.deliveryStatus,productsList,trip',
            sort: '-created'
          );

      debugPrint('✅ Retrieved ${result.length} invoices from API');

      List<InvoiceModel> invoices = [];

      for (var record in result) {
        final mappedData = {
          'id': record.id,
          'collectionId': record.collectionId,
          'collectionName': record.collectionName,
          'invoiceNumber': record.data['invoiceNumber'],
          'customerId': record.data['customer'],
          'tripId': record.data['trip'],
          'status': record.data['status'],
          'totalAmount': record.data['totalAmount'],
          'expand': {
            'customer': record.expand['customer']?[0].data,
            'productsList': record.expand['productsList']
                    ?.map((product) => {
                          'id': product.id,
                          'collectionId': product.collectionId,
                          'collectionName': product.collectionName,
                          ...product.data,
                        })
                    .toList() ??
                [],
            'trip': record.expand['trip']?[0].data,
          }
        };

        invoices.add(InvoiceModel.fromJson(mappedData));
        await Future.delayed(const Duration(milliseconds: 300));
      }

      return invoices;
    } catch (e) {
      debugPrint('❌ Error fetching invoices: $e');
      throw ServerException(message: e.toString(), statusCode: '500');
    }
  }
@override
Future<List<InvoiceModel>> getInvoicesByTripId(String tripId) async {
  try {
    // Extract trip ID if we received a JSON object
    String actualTripId;
    if (tripId.startsWith('{')) {
      final tripData = jsonDecode(tripId);
      actualTripId = tripData['id'];
    } else {
      actualTripId = tripId;
    }

    debugPrint('🔄 Fetching invoices for trip: $actualTripId');

    // Get invoices using trip ID
    final result = await _pocketBaseClient
        .collection('invoices')
        .getFullList(
          filter: 'trip = "$actualTripId"',
          expand: 'customer,productsList,trip',
        );

    debugPrint('✅ Successfully fetched ${result.length} invoices for trip: $actualTripId');

    List<InvoiceModel> invoices = [];

    for (var record in result) {
      try {
        debugPrint('🔄 Processing invoice: ${record.id}');
        
        // Process products
        List<ProductModel> products = [];
        double calculatedTotalAmount = 0.0;
        
        if (record.expand['productsList'] != null) {
          for (var productData in record.expand['productsList']!) {
            try {
              final product = ProductModel(
                id: productData.id,
                name: productData.data['name'],
                description: productData.data['description'],
                totalAmount: double.tryParse(productData.data['totalAmount']?.toString() ?? '0'),
                case_: int.tryParse(productData.data['case']?.toString() ?? '0'),
                pcs: int.tryParse(productData.data['pcs']?.toString() ?? '0'),
                pack: int.tryParse(productData.data['pack']?.toString() ?? '0'),
                box: int.tryParse(productData.data['box']?.toString() ?? '0'),
                pricePerCase: double.tryParse(productData.data['pricePerCase']?.toString() ?? '0'),
                pricePerPc: double.tryParse(productData.data['pricePerPc']?.toString() ?? '0'),
                primaryUnit: ProductUnit.values.firstWhere(
                  (e) => e.name == (productData.data['primaryUnit'] ?? 'case'),
                  orElse: () => ProductUnit.cases,
                ),
                secondaryUnit: ProductUnit.values.firstWhere(
                  (e) => e.name == (productData.data['secondaryUnit'] ?? 'pc'),
                  orElse: () => ProductUnit.pc,
                ),
                status: _getProductStatus(productData.data['status']),
              );
              products.add(product);
              calculatedTotalAmount += product.totalAmount ?? 0.0;
              debugPrint('✅ Processed product: ${product.name}');
            } catch (e) {
              debugPrint('⚠️ Error processing product: $e');
            }
          }
        }
        
        // Process customer data
        CustomerModel? customer;
        if (record.expand['customer'] != null) {
          final customerData = record.expand['customer'];
          if (customerData is List && customerData!.isNotEmpty) {
            try {
              final customerRecord = customerData[0];
              customer = CustomerModel(
                id: customerRecord.id,
                collectionId: customerRecord.collectionId,
                collectionName: customerRecord.collectionName,
                storeName: customerRecord.data['storeName'],
                ownerName: customerRecord.data['ownerName'],
                deliveryNumber: customerRecord.data['deliveryNumber'],
                address: customerRecord.data['address'],
                municipality: customerRecord.data['municipality'],
                province: customerRecord.data['province'],
                modeOfPayment: customerRecord.data['modeOfPayment'],
              );
              debugPrint('✅ Processed customer: ${customer.storeName}');
            } catch (e) {
              debugPrint('⚠️ Error processing customer: $e');
            }
          }
        }
        
        // Process trip data
        TripModel? trip;
        if (record.expand['trip'] != null) {
          final tripData = record.expand['trip'];
          if (tripData is List && tripData!.isNotEmpty) {
            try {
              final tripRecord = tripData[0];
              trip = TripModel(
                id: tripRecord.id,
                collectionId: tripRecord.collectionId,
                collectionName: tripRecord.collectionName,
                tripNumberId: tripRecord.data['tripNumberId'],
              );
              debugPrint('✅ Processed trip: ${trip.tripNumberId}');
            } catch (e) {
              debugPrint('⚠️ Error processing trip: $e');
            }
          }
        }
        
        // Create invoice model
        final invoice = InvoiceModel(
          id: record.id,
          collectionId: record.collectionId,
          collectionName: record.collectionName,
          invoiceNumber: record.data['invoiceNumber'],
          customerId: record.data['customer'],
          tripId: record.data['trip'],
          productsList: products,
          status: _getInvoiceStatus(record.data['status']),
          totalAmount: double.tryParse(record.data['totalAmount']?.toString() ?? '0') ?? calculatedTotalAmount,
          confirmTotalAmount: double.tryParse(record.data['confirmTotalAmount']?.toString() ?? '0'),
          customerDeliveryStatus: record.data['customerDeliveryStatus'],
          customer: customer,
          trip: trip,
          created: DateTime.tryParse(record.created),
          updated: DateTime.tryParse(record.updated),
        );
        
        invoices.add(invoice);
        debugPrint('✅ Successfully processed invoice: ${record.id}');
      } catch (e) {
        debugPrint('❌ Error processing invoice record: $e');
        // Add a minimal model to avoid breaking the list
        invoices.add(InvoiceModel(
          id: record.id,
          invoiceNumber: record.data['invoiceNumber'],
          customerId: record.data['customer'],
          tripId: record.data['trip'],
          productsList: [],
          status: InvoiceStatus.truck,
        ));
      }
    }

    debugPrint('✅ Successfully fetched ${invoices.length} invoices for trip');
    return invoices;
  } catch (e) {
    debugPrint('❌ Error fetching invoices for trip: $e');
    throw ServerException(
      message: 'Failed to load invoices by trip id: ${e.toString()}',
      statusCode: '500',
    );
  }
}


@override
Future<List<InvoiceModel>> getInvoicesByCustomerId(String customerId) async {
  try {
    // Extract the actual ID if we received a CustomerModel object or a string representation of it
    String actualCustomerId;
    
    if (customerId.startsWith(':')) {
      customerId = customerId.substring(1); // Remove the leading colon
    }
    
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
    
    debugPrint('🔄 Fetching invoices for customer ID: $actualCustomerId');

    // Get invoices with expanded product relationships
    final result = await _pocketBaseClient.collection('invoices').getFullList(
          filter: 'customer = "$actualCustomerId"',
          expand: 'productsList,customer,trip',
        );

    debugPrint('📦 Raw API Response: ${result.length} records');
    List<InvoiceModel> invoices = [];

    for (var record in result) {
      debugPrint('🔍 Processing invoice: ${record.id}');
      
      // Process products
      List<ProductModel> products = [];
      if (record.expand['productsList'] != null) {
        for (var productData in record.expand['productsList']!) {
          final product = ProductModel(
            id: productData.id,
            name: productData.data['name'],
            description: productData.data['description'],
            totalAmount: double.tryParse(productData.data['totalAmount']?.toString() ?? '0'),
            case_: int.tryParse(productData.data['case']?.toString() ?? '0'),
            pcs: int.tryParse(productData.data['pcs']?.toString() ?? '0'),
            pack: int.tryParse(productData.data['pack']?.toString() ?? '0'),
            box: int.tryParse(productData.data['box']?.toString() ?? '0'),
            pricePerCase: double.tryParse(productData.data['pricePerCase']?.toString() ?? '0'),
            pricePerPc: double.tryParse(productData.data['pricePerPc']?.toString() ?? '0'),
            primaryUnit: ProductUnit.values.firstWhere(
              (e) => e.name == (productData.data['primaryUnit'] ?? 'case'),
              orElse: () => ProductUnit.cases,
            ),
            secondaryUnit: ProductUnit.values.firstWhere(
              (e) => e.name == (productData.data['secondaryUnit'] ?? 'pc'),
              orElse: () => ProductUnit.pc,
            ),
            status: _getProductStatus(productData.data['status']),
          );
          products.add(product);
        }
      }
      
      // Process customer data
      CustomerModel? customer;
      if (record.expand['customer'] != null) {
        final customerData = record.expand['customer'];
        if (customerData is List && customerData!.isNotEmpty) {
          final customerRecord = customerData[0];
          customer = CustomerModel(
            id: customerRecord.id,
            collectionId: customerRecord.collectionId,
            collectionName: customerRecord.collectionName,
            storeName: customerRecord.data['storeName'],
            ownerName: customerRecord.data['ownerName'],
            deliveryNumber: customerRecord.data['deliveryNumber'],
            // Add other customer fields as needed
          );
        }
      }
      
      // Process trip data
      TripModel? trip;
      if (record.expand['trip'] != null) {
        final tripData = record.expand['trip'];
        if (tripData is List && tripData!.isNotEmpty) {
          final tripRecord = tripData[0];
          trip = TripModel(
            id: tripRecord.id,
            collectionId: tripRecord.collectionId,
            collectionName: tripRecord.collectionName,
            tripNumberId: tripRecord.data['tripNumberId'],
            // Add other trip fields as needed
          );
        }
      }

      // Create invoice model
      final invoice = InvoiceModel(
        id: record.id,
        collectionId: record.collectionId,
        collectionName: record.collectionName,
        invoiceNumber: record.data['invoiceNumber'],
        customerId: record.data['customer'],
        tripId: record.data['trip'],
        productsList: products,
        status: _getInvoiceStatus(record.data['status']),
        totalAmount: double.tryParse(record.data['totalAmount']?.toString() ?? '0') ?? 
                    products.fold(0.0, (sum, product) => sum! + (product.totalAmount ?? 0.0)),
        confirmTotalAmount: double.tryParse(record.data['confirmTotalAmount']?.toString() ?? '0'),
        customerDeliveryStatus: record.data['customerDeliveryStatus'],
        customer: customer,
        trip: trip,
        created: DateTime.tryParse(record.created),
        updated: DateTime.tryParse(record.updated),
      );
      
      invoices.add(invoice);
      debugPrint('✅ Processed invoice: ${record.id}, products: ${products.length}');
    }

    debugPrint('✅ Successfully processed ${invoices.length} invoices for customer');
    return invoices;
  } catch (e) {
    debugPrint('❌ Error fetching customer invoices: $e');
    throw ServerException(message: e.toString(), statusCode: '500');
  }
}


//   List<InvoiceModel> _processInvoiceRecords(List<RecordModel> records) {
//   List<InvoiceModel> invoices = [];
//   debugPrint('📦 Processing ${records.length} invoice records');

//   for (var record in records) {
//     try {
//       double totalAmount = 0.0;
//       List<ProductModel> products = [];

//       // Process products
//       final productsExpand = record.expand['productsList'];
//       if (productsExpand != null) {
//         for (var productData in productsExpand) {
//           try {
//             final product = ProductModel(
//               id: productData.id,
//               name: productData.data['name'],
//               description: productData.data['description'],
//               totalAmount: double.tryParse(
//                   productData.data['totalAmount']?.toString() ?? '0'),
//               case_: int.tryParse(productData.data['case']?.toString() ?? '0'),
//               pcs: int.tryParse(productData.data['pcs']?.toString() ?? '0'),
//               pack: int.tryParse(productData.data['pack']?.toString() ?? '0'),
//               box: int.tryParse(productData.data['box']?.toString() ?? '0'),
//               pricePerCase: double.tryParse(
//                   productData.data['pricePerCase']?.toString() ?? '0'),
//               pricePerPc: double.tryParse(
//                   productData.data['pricePerPc']?.toString() ?? '0'),
//               primaryUnit: ProductUnit.values.firstWhere(
//                 (e) => e.name == (productData.data['primaryUnit'] ?? 'case'),
//                 orElse: () => ProductUnit.cases,
//               ),
//               secondaryUnit: ProductUnit.values.firstWhere(
//                 (e) => e.name == (productData.data['secondaryUnit'] ?? 'pc'),
//                 orElse: () => ProductUnit.pc,
//               ),
//               image: productData.data['image'],
//               isCase: productData.data['isCase'] ?? false,
//               isPc: productData.data['isPc'] ?? false,
//               isPack: productData.data['isPack'] ?? false,
//               isBox: productData.data['isBox'] ?? false,
//               unloadedProductCase: int.tryParse(
//                   productData.data['unloadedProductCase']?.toString() ?? '0'),
//               unloadedProductPc: int.tryParse(
//                   productData.data['unloadedProductPc']?.toString() ?? '0'),
//               unloadedProductPack: int.tryParse(
//                   productData.data['unloadedProductPack']?.toString() ?? '0'),
//               unloadedProductBox: int.tryParse(
//                   productData.data['unloadedProductBox']?.toString() ?? '0'),
//               status: _getProductStatus(productData.data['status']),
//               returnReason: ProductReturnReason.values.firstWhere(
//                 (e) => e.name == (productData.data['returnReason'] ?? 'none'),
//                 orElse: () => ProductReturnReason.none,
//               ),
//             );
//             products.add(product);
//             totalAmount += product.totalAmount ?? 0.0;
//           } catch (e) {
//             debugPrint('⚠️ Error processing product: $e');
//           }
//         }
//       }
//       debugPrint('✅ Processed ${products.length} products');

//       // Process customer data
//       CustomerModel? customer;
//       if (record.expand['customer'] != null) {
//         final customerData = record.expand['customer'];
//         if (customerData is List && customerData!.isNotEmpty) {
//           final customerRecord = customerData[0];
//           customer = CustomerModel(
//             id: customerRecord.id,
//             collectionId: customerRecord.collectionId,
//             collectionName: customerRecord.collectionName,
//             storeName: customerRecord.data['storeName'],
//             ownerName: customerRecord.data['ownerName'],
//             deliveryNumber: customerRecord.data['deliveryNumber'],
//             // Add other customer fields as needed
//           );
//           debugPrint('✅ Processed customer: ${customer.storeName}');
//         }
//       }

//       // Process trip data
//       TripModel? trip;
//       if (record.expand['trip'] != null) {
//         final tripData = record.expand['trip'];
//         if (tripData is List && tripData!.isNotEmpty) {
//           final tripRecord = tripData[0];
//           trip = TripModel(
//             id: tripRecord.id,
//             collectionId: tripRecord.collectionId,
//             collectionName: tripRecord.collectionName,
//             tripNumberId: tripRecord.data['tripNumberId'],
//             // Add other trip fields as needed
//           );
//           debugPrint('✅ Processed trip: ${trip.id} (${trip.tripNumberId})');
//         }
//       }

//       // Create the invoice model with all expanded data
//       final model = InvoiceModel(
//         id: record.id,
//         collectionId: record.collectionId,
//         collectionName: record.collectionName,
//         invoiceNumber: record.data['invoiceNumber'],
//         customerId: record.data['customer'],
//         tripId: record.data['trip'],
//         productsList: products,
//         status: _getInvoiceStatus(record.data['status']),
//         totalAmount: double.tryParse(record.data['totalAmount']?.toString() ?? '0') ?? totalAmount,
//         confirmTotalAmount: double.tryParse(record.data['confirmTotalAmount']?.toString() ?? '0'),
//         customerDeliveryStatus: _getLatestDeliveryStatus(record),
//         customer: customer, // Add the expanded customer object
//         trip: trip, // Add the expanded trip object
//         created: DateTime.tryParse(record.created),
//         updated: DateTime.tryParse(record.updated),
//       );

//       debugPrint('✅ Processed invoice: ${model.id} (${model.invoiceNumber})');
//       invoices.add(model);
//     } catch (e) {
//       debugPrint('❌ Error processing invoice record: $e');
//     }
//   }

//   debugPrint('✅ Successfully processed ${invoices.length} invoices');
//   return invoices;
// }


  // Existing helper methods remain unchanged
  InvoiceStatus _getInvoiceStatus(dynamic status) {
    if (status == null) return InvoiceStatus.truck;
    final statusStr = status.toString().toLowerCase();
    return InvoiceStatus.values.firstWhere(
      (e) => e.name.toLowerCase() == statusStr,
      orElse: () => InvoiceStatus.truck,
    );
  }

  ProductsStatus _getProductStatus(dynamic status) {
    if (status == null) return ProductsStatus.truck;
    final statusStr = status.toString().toLowerCase();
    return ProductsStatus.values.firstWhere(
      (e) => e.name.toLowerCase() == statusStr,
      orElse: () => ProductsStatus.truck,
    );
  }

  // String _getLatestDeliveryStatus(RecordModel invoiceRecord) {
  //   final customerExpand = invoiceRecord.expand['customer'];
  //   final deliveryStatusExpand = customerExpand?[0].expand['deliveryStatus'];

  //   final latestStatus = deliveryStatusExpand?.isNotEmpty == true
  //       ? deliveryStatusExpand![deliveryStatusExpand.length - 1]
  //               .data['title']
  //               ?.toString()
  //               .toLowerCase() ??
  //           'pending'
  //       : 'pending';

  //   return latestStatus;
  // }
  
  @override
  Future<InvoiceModel> createInvoice({
    required String invoiceNumber,
    required String customerId,
    required String tripId,
    required List<String> productIds,
    InvoiceStatus? status,
    double? totalAmount,
    double? confirmTotalAmount,
    String? customerDeliveryStatus,
  }) async {
    try {
      debugPrint('🔄 Creating new invoice');
      
      final body = {
        'invoiceNumber': invoiceNumber,
        'customer': customerId,
        'trip': tripId,
        'productsList': productIds,
      };
      
      if (status != null) body['status'] = status.name;
      if (totalAmount != null) body['totalAmount'] = totalAmount.toString();
      if (confirmTotalAmount != null) body['confirmTotalAmount'] = confirmTotalAmount.toString();
      if (customerDeliveryStatus != null) body['customerDeliveryStatus'] = customerDeliveryStatus;
      
      final record = await _pocketBaseClient
          .collection('invoices')
          .create(body: body);
      
      // Fetch the created record with expanded relations
      final createdRecord = await _pocketBaseClient
          .collection('invoices')
          .getOne(
            record.id,
            expand: 'customer,productsList,trip',
          );
      
      debugPrint('✅ Successfully created invoice: ${record.id}');
      
      // Process products to calculate total amount if not provided
      double calculatedTotalAmount = 0.0;
      final products = <ProductModel>[];
      
      if (createdRecord.expand['productsList'] != null) {
        for (var productData in createdRecord.expand['productsList']!) {
          final product = ProductModel(
            id: productData.id,
            name: productData.data['name'],
            description: productData.data['description'],
            totalAmount: double.tryParse(productData.data['totalAmount']?.toString() ?? '0'),
            case_: int.tryParse(productData.data['case']?.toString() ?? '0'),
            pcs: int.tryParse(productData.data['pcs']?.toString() ?? '0'),
            pack: int.tryParse(productData.data['pack']?.toString() ?? '0'),
            box: int.tryParse(productData.data['box']?.toString() ?? '0'),
            pricePerCase: double.tryParse(productData.data['pricePerCase']?.toString() ?? '0'),
            pricePerPc: double.tryParse(productData.data['pricePerPc']?.toString() ?? '0'),
            primaryUnit: ProductUnit.values.firstWhere(
              (e) => e.name == (productData.data['primaryUnit'] ?? 'case'),
              orElse: () => ProductUnit.cases,
            ),
            secondaryUnit: ProductUnit.values.firstWhere(
              (e) => e.name == (productData.data['secondaryUnit'] ?? 'pc'),
              orElse: () => ProductUnit.pc,
            ),
          );
          products.add(product);
          calculatedTotalAmount += product.totalAmount ?? 0.0;
        }
      }
      
      // If totalAmount wasn't provided, update it with calculated value
      if (totalAmount == null && calculatedTotalAmount > 0) {
        await _pocketBaseClient.collection('invoices').update(
          record.id,
          body: {
            'totalAmount': calculatedTotalAmount.toString(),
          },
        );
      }
      
      return InvoiceModel(
        id: createdRecord.id,
        collectionId: createdRecord.collectionId,
        collectionName: createdRecord.collectionName,
        invoiceNumber: createdRecord.data['invoiceNumber'],
        customerId: customerId,
        tripId: tripId,
        productsList: products,
        status: status ?? InvoiceStatus.truck,
        totalAmount: totalAmount ?? calculatedTotalAmount,
        confirmTotalAmount: confirmTotalAmount,
        customerDeliveryStatus: customerDeliveryStatus,
        created: DateTime.tryParse(createdRecord.created),
        updated: DateTime.tryParse(createdRecord.updated),
      );
    } catch (e) {
      debugPrint('❌ Create Invoice failed: ${e.toString()}');
      throw ServerException(
        message: 'Failed to create invoice: ${e.toString()}',
        statusCode: '500',
      );
    }
  }
    @override
  Future<bool> deleteAllInvoices(List<String> ids) async {
    try {
      debugPrint('🔄 Deleting multiple invoices: ${ids.length} items');
      
      // Get all invoices to find customer IDs
      final customerInvoices = <String, List<String>>{};
      
      for (final id in ids) {
        try {
          final record = await _pocketBaseClient
              .collection('invoices')
              .getOne(id);
          
          final customerId = record.data['customer'];
          if (customerId != null) {
            customerInvoices[customerId] = [...(customerInvoices[customerId] ?? []), id];
          }
          
          // Delete the invoice
          await _pocketBaseClient.collection('invoices').delete(id);
        } catch (e) {
          debugPrint('⚠️ Error processing invoice $id: $e');
          // Continue with other deletions
        }
      }
      
      // Update customer records to remove invoice references
      for (final entry in customerInvoices.entries) {
        try {
          final customerId = entry.key;
          final invoiceIds = entry.value;
          
          final customerRecord = await _pocketBaseClient
              .collection('customers')
              .getOne(customerId);
          
          final invoices = customerRecord.data['invoices'] as List? ?? [];
          final updatedInvoices = invoices.where((id) => !invoiceIds.contains(id)).toList();
          
          await _pocketBaseClient.collection('customers').update(
            customerId,
            body: {
              'invoices': updatedInvoices,
            },
          );
        } catch (e) {
          debugPrint('⚠️ Error updating customer ${entry.key}: $e');
          // Continue with other customers
        }
      }
      
      debugPrint('✅ Successfully deleted all invoices');
      return true;
    } catch (e) {
      debugPrint('❌ Delete All Invoices failed: ${e.toString()}');
      throw ServerException(
        message: 'Failed to delete multiple invoices: ${e.toString()}',
        statusCode: '500',
      );
    }
  }

  
  @override
  Future<bool> deleteInvoice(String id) async {
    try {
      debugPrint('🔄 Deleting invoice: $id');
      
      // Get the invoice to find related entities
      final record = await _pocketBaseClient
          .collection('invoices')
          .getOne(id);
      
      final customerId = record.data['customer'];
      
      // Delete the invoice
      await _pocketBaseClient.collection('invoices').delete(id);
      
      // Update the customer record to remove the invoice reference if needed
      if (customerId != null) {
        try {
          final customerRecord = await _pocketBaseClient
              .collection('customers')
              .getOne(customerId);
          
          final invoices = customerRecord.data['invoices'] as List? ?? [];
          if (invoices.contains(id)) {
            invoices.remove(id);
            
            await _pocketBaseClient.collection('customers').update(
              customerId,
              body: {
                'invoices': invoices,
              },
            );
          }
        } catch (e) {
          debugPrint('⚠️ Error updating customer references: $e');
          // Continue with deletion even if customer update fails
        }
      }
      
      debugPrint('✅ Successfully deleted invoice');
      return true;
    } catch (e) {
      debugPrint('❌ Delete Invoice failed: ${e.toString()}');
      throw ServerException(
        message: 'Failed to delete invoice: ${e.toString()}',
        statusCode: '500',
      );
    }
  }
 
  @override
  Future<InvoiceModel> updateInvoice({
    required String id,
    String? invoiceNumber,
    String? customerId,
    String? tripId,
    List<String>? productIds,
    InvoiceStatus? status,
    double? totalAmount,
    double? confirmTotalAmount,
    String? customerDeliveryStatus,
  }) async {
    try {
      debugPrint('🔄 Updating invoice: $id');
      
      final body = <String, dynamic>{};
      
      if (invoiceNumber != null) body['invoiceNumber'] = invoiceNumber;
      if (customerId != null) body['customer'] = customerId;
      if (tripId != null) body['trip'] = tripId;
      if (productIds != null) body['productsList'] = productIds;
      if (status != null) body['status'] = status.name;
      if (totalAmount != null) body['totalAmount'] = totalAmount.toString();
      if (confirmTotalAmount != null) body['confirmTotalAmount'] = confirmTotalAmount.toString();
      if (customerDeliveryStatus != null) body['customerDeliveryStatus'] = customerDeliveryStatus;
      
      await _pocketBaseClient
          .collection('invoices')
          .update(id, body: body);
      
      // Fetch the updated record with expanded relations
      final updatedRecord = await _pocketBaseClient
          .collection('invoices')
          .getOne(
            id,
            expand: 'customer,productsList,trip',
          );
      
      debugPrint('✅ Successfully updated invoice');
      
      // Process products
      final products = <ProductModel>[];
      double calculatedTotalAmount = 0.0;
      
      if (updatedRecord.expand['productsList'] != null) {
        for (var productData in updatedRecord.expand['productsList']!) {
          final product = ProductModel(
            id: productData.id,
            name: productData.data['name'],
            description: productData.data['description'],
            totalAmount: double.tryParse(productData.data['totalAmount']?.toString() ?? '0'),
            case_: int.tryParse(productData.data['case']?.toString() ?? '0'),
            pcs: int.tryParse(productData.data['pcs']?.toString() ?? '0'),
            pack: int.tryParse(productData.data['pack']?.toString() ?? '0'),
            box: int.tryParse(productData.data['box']?.toString() ?? '0'),
            pricePerCase: double.tryParse(productData.data['pricePerCase']?.toString() ?? '0'),
            pricePerPc: double.tryParse(productData.data['pricePerPc']?.toString() ?? '0'),
            primaryUnit: ProductUnit.values.firstWhere(
              (e) => e.name == (productData.data['primaryUnit'] ?? 'case'),
              orElse: () => ProductUnit.cases,
            ),
            secondaryUnit: ProductUnit.values.firstWhere(
              (e) => e.name == (productData.data['secondaryUnit'] ?? 'pc'),
              orElse: () => ProductUnit.pc,
            ),
          );
          products.add(product);
          calculatedTotalAmount += product.totalAmount ?? 0.0;
        }
      }
      
      return InvoiceModel(
        id: updatedRecord.id,
        collectionId: updatedRecord.collectionId,
        collectionName: updatedRecord.collectionName,
        invoiceNumber: updatedRecord.data['invoiceNumber'],
        customerId: updatedRecord.data['customer'],
        tripId: updatedRecord.data['trip'],
        productsList: products,
        status: _getInvoiceStatus(updatedRecord.data['status']),
        totalAmount: double.tryParse(updatedRecord.data['totalAmount']?.toString() ?? '0') ?? calculatedTotalAmount,
        confirmTotalAmount: double.tryParse(updatedRecord.data['confirmTotalAmount']?.toString() ?? '0'),
        customerDeliveryStatus: updatedRecord.data['customerDeliveryStatus'],
        created: DateTime.tryParse(updatedRecord.created),
        updated: DateTime.tryParse(updatedRecord.updated),
      );
    } catch (e) {
      debugPrint('❌ Update Invoice failed: ${e.toString()}');
      throw ServerException(
        message: 'Failed to update invoice: ${e.toString()}',
        statusCode: '500',
      );
    }
  }
@override
Future<InvoiceModel> getInvoiceById(String invoiceId) async {
  try {
    debugPrint('🔄 Fetching data for invoice: $invoiceId');

    // Get basic invoice data with expanded relations
    final record = await _pocketBaseClient
        .collection('invoices')
        .getOne(
          invoiceId, 
          expand: 'customer,trip,productsList'
        );

    // Process products
    final productsList = <ProductModel>[];
    double totalAmount = 0.0;
    
    if (record.expand['productsList'] != null) {
      for (var productData in record.expand['productsList']!) {
        final product = ProductModel(
          id: productData.id,
         
          name: productData.data['name'],
          description: productData.data['description'],
          totalAmount: double.tryParse(productData.data['totalAmount']?.toString() ?? '0'),
          case_: int.tryParse(productData.data['case']?.toString() ?? '0'),
          pcs: int.tryParse(productData.data['pcs']?.toString() ?? '0'),
          pack: int.tryParse(productData.data['pack']?.toString() ?? '0'),
          box: int.tryParse(productData.data['box']?.toString() ?? '0'),
          pricePerCase: double.tryParse(productData.data['pricePerCase']?.toString() ?? '0'),
          pricePerPc: double.tryParse(productData.data['pricePerPc']?.toString() ?? '0'),
          status: _getProductStatus(productData.data['status']),
        );
        productsList.add(product);
        totalAmount += product.totalAmount ?? 0.0;
            }
    }
    
    // Process customer data - using the exact pattern from the provided code
    CustomerModel? customer;
    if (record.expand['customer'] != null) {
      final customerData = record.expand['customer'];
      
      if (customerData is List && customerData!.isNotEmpty) {
        // List case - access the first element
        final customerRecord = customerData[0];
        customer = CustomerModel(
          id: customerRecord.id,
          collectionId: customerRecord.collectionId,
          collectionName: customerRecord.collectionName,
          storeName: customerRecord.data['storeName'],
          ownerName: customerRecord.data['ownerName'],
          deliveryNumber: customerRecord.data['deliveryNumber'],
          // Add other customer fields as needed
        );
            }
    }

    // Process trip data - using the exact pattern from the provided code
    TripModel? trip;
    if (record.expand['trip'] != null) {
      final tripData = record.expand['trip'];
      
      if (tripData is List && tripData!.isNotEmpty) {
        // List case - access the first element
        final tripRecord = tripData[0];
        trip = TripModel(
          id: tripRecord.id,
          collectionId: tripRecord.collectionId,
          collectionName: tripRecord.collectionName,
          tripNumberId: tripRecord.data['tripNumberId'],
          // Add other trip fields as needed
        );
            }
    }

    // Create and return the invoice model
    return InvoiceModel(
      id: record.id,
      collectionId: record.collectionId,
      collectionName: record.collectionName,
      invoiceNumber: record.data['invoiceNumber'],
      customerId: record.data['customer'],
      tripId: record.data['trip'],
      productsList: productsList,
      status: _getInvoiceStatus(record.data['status']),
      totalAmount: double.tryParse(record.data['totalAmount']?.toString() ?? '0') ?? totalAmount,
      confirmTotalAmount: double.tryParse(record.data['confirmTotalAmount']?.toString() ?? '0'),
      customerDeliveryStatus: record.data['customerDeliveryStatus'],
      customer: customer,
      trip: trip,
      created: DateTime.tryParse(record.created),
      updated: DateTime.tryParse(record.updated),
    );
  } catch (e) {
    debugPrint('❌ Error fetching invoice data: $e');
    throw ServerException(message: e.toString(), statusCode: '500');
  }
}
@override
Future<List<InvoiceModel>> getInvoicesByCompletedCustomerId(String completedCustomerId) async {
  try {
    // Extract the actual ID if we received a CompletedCustomerModel object or a string representation of it
    String actualCompletedCustomerId = completedCustomerId;
    
    // Check if the ID is actually a string representation of a CompletedCustomerModel
    if (completedCustomerId.contains('CompletedCustomerModel')) {
      // Extract just the ID - it should be the first part before a comma
      final idMatch = RegExp(r'CompletedCustomerModel\(([^,]+)').firstMatch(completedCustomerId);
      if (idMatch != null && idMatch.groupCount >= 1) {
        actualCompletedCustomerId = idMatch.group(1)!;
      } else {
        // Fallback to using the first part before a comma if regex fails
        actualCompletedCustomerId = completedCustomerId.split(',').first.replaceAll('CompletedCustomerModel(', '').trim();
      }
    }
    
    debugPrint('🔄 Fetching invoices for completed customer ID: $actualCompletedCustomerId');
    
    // First, get the completed customer to find its associated customer ID
    final completedCustomerRecord = await _pocketBaseClient
        .collection('completedCustomer')
        .getOne(
          actualCompletedCustomerId,
          expand: 'customer',
        );
    
    // Get the customer ID from the completed customer
    String? customerId;
    if (completedCustomerRecord.data['customer'] != null) {
      customerId = completedCustomerRecord.data['customer'].toString();
    } else if (completedCustomerRecord.expand['customer'] != null) {
      final customerExpand = completedCustomerRecord.expand['customer'];
      if (customerExpand is List && customerExpand!.isNotEmpty) {
        customerId = customerExpand[0].id;
      } 
    }
    
    if (customerId == null) {
      debugPrint('⚠️ No customer ID found for completed customer: $actualCompletedCustomerId');
      return [];
    }
    
    debugPrint('🔍 Found customer ID: $customerId for completed customer: $actualCompletedCustomerId');
    
    // Get invoices by customer ID
    final invoiceRecords = await _pocketBaseClient
        .collection('invoices')
        .getFullList(
          filter: 'customer = "$customerId"',
          expand: 'customer,trip',
        );
    
    debugPrint('✅ Retrieved ${invoiceRecords.length} invoices for customer: $customerId');
    
    List<InvoiceModel> invoicesList = [];
    
    for (final record in invoiceRecords) {
      try {
        // Create a simplified invoice model with only essential data
        final invoice = InvoiceModel(
          id: record.id,
          collectionId: record.collectionId,
          collectionName: record.collectionName,
          invoiceNumber: record.data['invoiceNumber'],
          customerId: record.data['customer'],
          tripId: record.data['trip'],
          productsList: [], // Empty list - we don't need product details
          status: _getInvoiceStatus(record.data['status']),
          totalAmount: double.tryParse(record.data['totalAmount']?.toString() ?? '0'),
          confirmTotalAmount: double.tryParse(record.data['confirmTotalAmount']?.toString() ?? '0'),
          customerDeliveryStatus: record.data['customerDeliveryStatus'],
          created: DateTime.tryParse(record.created),
          updated: DateTime.tryParse(record.updated),
        );
        
        invoicesList.add(invoice);
        debugPrint('✅ Processed invoice: ${record.id}');
      } catch (itemError) {
        debugPrint('⚠️ Error processing invoice item: ${itemError.toString()}');
      }
    }
    
    debugPrint('✅ Successfully processed ${invoicesList.length} invoices for completed customer');
    return invoicesList;
    
  } catch (e) {
    debugPrint('❌ Error fetching invoices by completed customer ID: $e');
    throw ServerException(
      message: 'Failed to load invoices by completed customer ID: ${e.toString()}',
      statusCode: '500',
    );
  }
}



}
