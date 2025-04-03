import 'dart:io';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/invoice/data/models/invoice_models.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/transaction/data/model/transaction_model.dart';
import 'package:desktop_app/core/enums/mode_of_payment.dart';
import 'package:desktop_app/core/enums/transaction_status.dart';
import 'package:desktop_app/core/errors/exceptions.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pocketbase/pocketbase.dart';


abstract class TransactionRemoteDatasource {
  Future<List<TransactionModel>> getTransactions(String customerId);
  Future<TransactionModel> getTransactionById(String id);
  Future<List<TransactionModel>> getTransactionsByDateRange(
      DateTime startDate, DateTime endDate, String customerId);
Future<TransactionModel> createTransaction({
  required TransactionModel transaction,
  required String customerId,
  required String tripId,
});
  Future<TransactionModel> updateTransaction(TransactionModel transaction);
  Future<void> deleteTransaction(String id);
  Future<List<TransactionModel>> getTransactionsByCompletedCustomer(
      String completedCustomerId);
  Future<File> downloadTransactionPdf(String transactionId);

  // New functions
  Future<List<TransactionModel>> getAllTransactions();
  Future<TransactionModel> processCompleteTransaction({
    required String customerName,
    required String totalAmount,
    required String refNumber,
    required File? signature,
    required String? customerImage,
    required List<InvoiceModel> invoices,
    required String deliveryNumber,
    required DateTime transactionDate,
    required TransactionStatus transactionStatus,
    required ModeOfPayment modeOfPayment,
    required bool isCompleted,
    required File? pdf,
    required String? tripId,
    required String? customerId,
    required String? completedCustomerId,
  });
  Future<TransactionModel> updateTransactionDetails({
    required String id,
    String? customerName,
    String? totalAmount,
    String? refNumber,
    File? signature,
    String? customerImage,
    List<InvoiceModel>? invoices,
    String? deliveryNumber,
    DateTime? transactionDate,
    TransactionStatus? transactionStatus,
    ModeOfPayment? modeOfPayment,
    bool? isCompleted,
    File? pdf,
    String? tripId,
    String? customerId,
    String? completedCustomerId,
  });
  Future<bool> deleteAllTransactions(List<String> ids);
}

class TransactionRemoteDatasourceImpl implements TransactionRemoteDatasource {
  const TransactionRemoteDatasourceImpl({
    required PocketBase pocketBaseClient,
  }) : _pocketBase = pocketBaseClient;

  final PocketBase _pocketBase;
  @override
Future<TransactionModel> createTransaction({
  required TransactionModel transaction,
  required String customerId,
  required String tripId,
}) async {
  try {
    debugPrint('🔄 Creating transaction with data:');
    debugPrint('Customer ID: $customerId');
    debugPrint('Trip ID: $tripId');
    debugPrint('ModeOfPayment: ${transaction.modeOfPayment}');
    debugPrint('TotalAmount: ${transaction.totalAmount}');
    debugPrint('Invoices: ${transaction.invoices.map((inv) => inv.id).toList()}');

    final currentTime = DateTime.now().toUtc().toIso8601String();

    final body = {
      'customer': customerId,
      'customerName': transaction.customerName,
      'deliveryNumber': transaction.deliveryNumber,
      'invoice': transaction.invoices.map((inv) => inv.id).toList(),
      'status': 'completed',
      'modeOfPayment': transaction.modeOfPayment.toString().split('.').last,
      'totalAmount': transaction.totalAmount,
      'transactionDate': currentTime,
      'created': currentTime,
      'updated': currentTime,
      'isCompleted': true,
      'refNumber': transaction.refNumber,
      'trip': tripId,
    };

    debugPrint('📝 Request body prepared: $body');

    final files = <String, MultipartFile>{};

    if (transaction.signature != null) {
      final signatureBytes = await transaction.signature!.readAsBytes();
      files['signature'] = MultipartFile.fromBytes(
        'signature',
        signatureBytes,
        filename: 'signature.pdf',
        contentType: MediaType('application', 'pdf'),
      );
      debugPrint('📄 Signature file prepared: ${signatureBytes.length} bytes');
    }

    if (transaction.customerImage != null) {
      final imagePaths = transaction.customerImage!.split(',');
      for (var i = 0; i < imagePaths.length; i++) {
        final imageBytes = await File(imagePaths[i]).readAsBytes();
        files['customerImage'] = MultipartFile.fromBytes(
          'customerImage',
          imageBytes,
          filename: 'customer_image_$i.jpg',
        );
        debugPrint('📸 Customer image prepared: ${imageBytes.length} bytes');
      }
    }

    if (transaction.pdf != null) {
      final pdfBytes = await transaction.pdf!.readAsBytes();
      files['pdf'] = MultipartFile.fromBytes(
        'pdf',
        pdfBytes,
        filename: 'receipt.pdf',
        contentType: MediaType('application', 'pdf'),
      );
      debugPrint('📑 PDF file prepared: ${pdfBytes.length} bytes');
    }

    final record = await _pocketBase.collection('transactions').create(
      body: body,
      files: files.values.toList(),
    );

    // Update trip's transaction list
    await _pocketBase.collection('tripticket').update(
      tripId,
      body: {
        'transactionList+': record.id,
      },
    );

    // Update customer's transactionList
    await _pocketBase.collection('customers').update(
      customerId,
      body: {
        'transactionList+': record.id,
      },
    );

    // Update all invoices status to completed
    for (var invoice in transaction.invoices) {
      await _pocketBase.collection('invoices').update(
        invoice.id ?? '',
        body: {
          'status': 'completed',
          'customer': customerId,
          'isCompleted': true,
        },
      );
    }

    final responseMap = {
      'id': record.id,
      'collectionId': record.collectionId,
      'collectionName': record.collectionName,
      'transactionDate': currentTime,
      ...record.data,
    };

    debugPrint('✅ Transaction created successfully');
    return TransactionModel.fromJson(responseMap);
  } catch (e) {
    debugPrint('❌ Transaction creation error: ${e.toString()}');
    throw ServerException(
      message: 'Failed to create transaction: ${e.toString()}',
      statusCode: '500',
    );
  }
}


  @override
  Future<void> deleteTransaction(String id) async {
    try {
      await _pocketBase.collection('transactions').delete(id);
    } catch (e) {
      throw ServerException(
        message: 'Failed to delete transaction: ${e.toString()}',
        statusCode: '500',
      );
    }
  }

  @override
  Future<TransactionModel> getTransactionById(String id) async {
    try {
      final record = await _pocketBase.collection('transactions').getOne(
            id,
            expand: 'customer,invoice',
          );
      return TransactionModel.fromJson(record.toJson());
    } catch (e) {
      throw ServerException(
        message: 'Failed to get transaction: ${e.toString()}',
        statusCode: '500',
      );
    }
  }

  @override
  Future<List<TransactionModel>> getTransactions(String customerId) async {
    try {
      final records = await _pocketBase.collection('transactions').getList(
            filter: 'customer = "$customerId"',
            expand: 'invoice',
          );
      return records.items
          .map((record) => TransactionModel.fromJson(record.toJson()))
          .toList();
    } catch (e) {
      throw ServerException(
        message: 'Failed to get transactions: ${e.toString()}',
        statusCode: '500',
      );
    }
  }

  @override
  Future<List<TransactionModel>> getTransactionsByDateRange(
    DateTime startDate,
    DateTime endDate,
    String customerId,
  ) async {
    try {
      final records = await _pocketBase.collection('transactions').getList(
            filter:
                'customer = "$customerId" && transactionDate >= "$startDate" && transactionDate <= "$endDate"',
            expand: 'invoice',
          );
      return records.items
          .map((record) => TransactionModel.fromJson(record.toJson()))
          .toList();
    } catch (e) {
      throw ServerException(
        message: 'Failed to get transactions by date range: ${e.toString()}',
        statusCode: '500',
      );
    }
  }

  @override
  Future<TransactionModel> updateTransaction(
      TransactionModel transaction) async {
    try {
      final record = await _pocketBase.collection('transactions').update(
            transaction.id ?? '',
            body: transaction.toJson(),
          );
      return TransactionModel.fromJson(record.toJson());
    } catch (e) {
      throw ServerException(
        message: 'Failed to update transaction: ${e.toString()}',
        statusCode: '500',
      );
    }
  }

  @override
  Future<List<TransactionModel>> getTransactionsByCompletedCustomer(
      String completedCustomerId) async {
    try {
      debugPrint(
          '🔍 Fetching transactions for completed customer: $completedCustomerId');

      final records = await _pocketBase.collection('transactions').getList(
            filter: 'completedCustomer = "$completedCustomerId"',
            expand: 'invoice,customer',
          );

      final transactions = records.items.map((record) {
        final modeOfPaymentStr = record.data['modeOfPayment']?.toString() ?? '';
        final modeOfPayment = ModeOfPayment.values.firstWhere(
          (mode) => mode.toString() == 'ModeOfPayment.$modeOfPaymentStr',
          orElse: () => ModeOfPayment.cashOnDelivery,
        );

        debugPrint('📝 Creating Transaction Model:');
        debugPrint(
            '   📅 Raw Transaction Date: ${record.data['transactionDate']}');
        debugPrint('   ⏰ Created Date: ${record.created}');

        // Handle the specific ISO 8601 format with timezone
        final transactionDateStr = record.data['transactionDate'].toString();
        final DateTime transactionDate = DateTime.parse(transactionDateStr);

        final transaction = TransactionModel(
          id: record.id,
          collectionId: record.collectionId,
          collectionName: record.collectionName,
          refNumber: record.data['refNumber'],
          totalAmount: record.data['totalAmount'],
          modeOfPayment: modeOfPayment,
          transactionDate: transactionDate,
          customerModel: record.data['customer'],
          customerName: record.data['customerName'],
          deliveryNumber: record.data['deliveryNumber'],
          customerImage: record.data['customerImage'],
          isCompleted: record.data['isCompleted'],
        );

        debugPrint('✅ Transaction Model Created:');
        debugPrint(
            '   📅 Model Transaction Date: ${transaction.transactionDate}');

        return transaction;
      }).toList();

      debugPrint('✅ Found ${transactions.length} transactions');
      return transactions;
    } catch (e) {
      debugPrint('❌ Error fetching transactions: ${e.toString()}');
      throw ServerException(
        message: 'Failed to get transactions: ${e.toString()}',
        statusCode: '500',
      );
    }
  }

  @override
  Future<File> downloadTransactionPdf(String transactionId) async {
    try {
      debugPrint('📥 Downloading transaction PDF: $transactionId');

      final record = await _pocketBase.collection('transactions').getOne(
            transactionId,
            expand: 'customer,invoice',
          );

      if (record.data['pdf'] == null) {
        throw const ServerException(
          message: 'PDF not found for transaction',
          statusCode: '404',
        );
      }

      final pdfUrl = _pocketBase.getFileUrl(record, record.data['pdf']);
      final response = await http.get(Uri.parse(pdfUrl.toString()));

      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/Transaction_$transactionId.pdf');
      await file.writeAsBytes(response.bodyBytes);

      debugPrint('✅ PDF downloaded successfully: ${file.path}');
      return file;
    } catch (e) {
      debugPrint('❌ Failed to download PDF: $e');
      throw ServerException(
        message: 'Failed to download transaction PDF: $e',
        statusCode: '500',
      );
    }
  }
  
  @override
Future<bool> deleteAllTransactions(List<String> ids) async {
  try {
    debugPrint('🔄 Deleting multiple transactions: ${ids.length} items');
    
    int successCount = 0;
    List<String> failedIds = [];
    
    // Process each deletion individually to handle partial failures
    for (final id in ids) {
      try {
        // First, get the transaction to find related entities
        final record = await _pocketBase.collection('transactions').getOne(
          id,
          expand: 'customer,trip',
        );
        
        final customerId = record.data['customer'];
        final tripId = record.data['trip'];
        
        // Delete the transaction
        await _pocketBase.collection('transactions').delete(id);
        
        // Update related records to remove references
        if (customerId != null) {
          try {
            final customerRecord = await _pocketBase.collection('customers').getOne(customerId);
            final transactionList = customerRecord.data['transactionList'] as List? ?? [];
            if (transactionList.contains(id)) {
              await _pocketBase.collection('customers').update(
                customerId,
                body: {
                  'transactionList-': id,
                },
              );
            }
          } catch (e) {
            debugPrint('⚠️ Error updating customer reference: $e');
            // Continue with deletion even if reference update fails
          }
        }
        
        if (tripId != null) {
          try {
            final tripRecord = await _pocketBase.collection('tripticket').getOne(tripId);
            final transactionList = tripRecord.data['transactionList'] as List? ?? [];
            if (transactionList.contains(id)) {
              await _pocketBase.collection('tripticket').update(
                tripId,
                body: {
                  'transactionList-': id,
                },
              );
            }
          } catch (e) {
            debugPrint('⚠️ Error updating trip reference: $e');
            // Continue with deletion even if reference update fails
          }
        }
        
        successCount++;
        debugPrint('✓ Successfully deleted transaction: $id');
      } catch (individualError) {
        failedIds.add(id);
        debugPrint('⚠️ Failed to delete transaction $id: $individualError');
        // Continue with other deletions even if one fails
      }
    }
    
    // Log summary of operation
    if (failedIds.isEmpty) {
      debugPrint('✅ All ${ids.length} transactions deleted successfully');
      return true;
    } else {
      debugPrint('⚠️ Partial success: $successCount/${ids.length} transactions deleted');
      debugPrint('❌ Failed to delete transactions: ${failedIds.join(', ')}');
      
      // If more than half were successful, consider it a success
      if (successCount > ids.length / 2) {
        return true;
      } else {
        throw ServerException(
          message: 'Failed to delete majority of transactions. Only $successCount/${ids.length} were successful.',
          statusCode: '500',
        );
      }
    }
  } catch (e) {
    debugPrint('❌ Bulk transaction deletion failed: ${e.toString()}');
    throw ServerException(
      message: 'Failed to delete transactions: ${e.toString()}',
      statusCode: '500',
    );
  }
}

  
 
  @override
  Future<List<TransactionModel>> getAllTransactions() async {
    try {
      debugPrint('🔄 Fetching all transactions');
      
      final records = await _pocketBase.collection('transactions').getFullList(
        expand: 'customer,invoice,trip,completedCustomer',
      );
      
      debugPrint('✅ Retrieved ${records.length} transactions from API');
      
      return records.map((record) {
        final modeOfPaymentStr = record.data['modeOfPayment']?.toString() ?? '';
        final modeOfPayment = ModeOfPayment.values.firstWhere(
          (mode) => mode.toString() == 'ModeOfPayment.$modeOfPaymentStr',
          orElse: () => ModeOfPayment.cashOnDelivery,
        );
        
        // Handle the specific ISO 8601 format with timezone
        final transactionDateStr = record.data['transactionDate'].toString();
        final DateTime transactionDate = DateTime.parse(transactionDateStr);
        
        return TransactionModel(
          id: record.id,
          collectionId: record.collectionId,
          collectionName: record.collectionName,
          refNumber: record.data['refNumber'],
          totalAmount: record.data['totalAmount'],
          modeOfPayment: modeOfPayment,
          transactionDate: transactionDate,
          customerModel: record.data['customer'],
          customerName: record.data['customerName'],
          deliveryNumber: record.data['deliveryNumber'],
          customerImage: record.data['customerImage'],
          isCompleted: record.data['isCompleted'],
        );
      }).toList();
    } catch (e) {
      debugPrint('❌ Error fetching all transactions: ${e.toString()}');
      throw ServerException(
        message: 'Failed to get all transactions: ${e.toString()}',
        statusCode: '500',
      );
    }
  }
  
  
  @override
  Future<TransactionModel> processCompleteTransaction({
    required String customerName,
    required String totalAmount,
    required String refNumber,
    required File? signature,
    required String? customerImage,
    required List<InvoiceModel> invoices,
    required String deliveryNumber,
    required DateTime transactionDate,
    required TransactionStatus transactionStatus,
    required ModeOfPayment modeOfPayment,
    required bool isCompleted,
    required File? pdf,
    required String? tripId,
    required String? customerId,
    required String? completedCustomerId,
  }) async {
    try {
      debugPrint('🔄 Processing complete transaction');
      
      final currentTime = DateTime.now().toUtc().toIso8601String();
      
      final body = {
        'customerName': customerName,
        'totalAmount': totalAmount,
        'refNumber': refNumber,
        'deliveryNumber': deliveryNumber,
        'transactionDate': transactionDate.toIso8601String(),
        'status': transactionStatus.toString().split('.').last,
        'modeOfPayment': modeOfPayment.toString().split('.').last,
        'isCompleted': isCompleted,
        'created': currentTime,
        'updated': currentTime,
      };
      
      if (customerId != null) body['customer'] = customerId;
      if (tripId != null) body['trip'] = tripId;
      if (completedCustomerId != null) body['completedCustomer'] = completedCustomerId;
      if (invoices.isNotEmpty) {
        body['invoice'] = invoices.map((inv) => inv.id).toList();
      }
      
      debugPrint('📝 Request body prepared: $body');
      
      final files = <String, MultipartFile>{};
      
      if (signature != null) {
        final signatureBytes = await signature.readAsBytes();
        files['signature'] = MultipartFile.fromBytes(
          'signature',
          signatureBytes,
          filename: 'signature.pdf',
          contentType: MediaType('application', 'pdf'),
        );
        debugPrint('📄 Signature file prepared: ${signatureBytes.length} bytes');
      }
      
      if (customerImage != null) {
        final imagePaths = customerImage.split(',');
        for (var i = 0; i < imagePaths.length; i++) {
          final imageBytes = await File(imagePaths[i]).readAsBytes();
          files['customerImage'] = MultipartFile.fromBytes(
            'customerImage',
            imageBytes,
            filename: 'customer_image_$i.jpg',
          );
          debugPrint('📸 Customer image prepared: ${imageBytes.length} bytes');
        }
      }
      
      if (pdf != null) {
        final pdfBytes = await pdf.readAsBytes();
        files['pdf'] = MultipartFile.fromBytes(
          'pdf',
          pdfBytes,
          filename: 'receipt.pdf',
          contentType: MediaType('application', 'pdf'),
        );
        debugPrint('📑 PDF file prepared: ${pdfBytes.length} bytes');
      }
      
      final record = await _pocketBase.collection('transactions').create(
        body: body,
        files: files.values.toList(),
      );
      
      // Update related records
      if (tripId != null) {
        await _pocketBase.collection('tripticket').update(
          tripId,
          body: {
            'transactionList+': record.id,
          },
        );
      }
      
      if (customerId != null) {
        await _pocketBase.collection('customers').update(
          customerId,
          body: {
            'transactionList+': record.id,
          },
        );
      }
      
      // Update all invoices status to completed
      for (var invoice in invoices) {
        await _pocketBase.collection('invoices').update(
          invoice.id ?? '',
          body: {
            'status': 'completed',
            'isCompleted': true,
          },
        );
      }
      
      final responseMap = {
        'id': record.id,
        'collectionId': record.collectionId,
        'collectionName': record.collectionName,
        'transactionDate': transactionDate.toIso8601String(),
        ...record.data,
      };
      
      debugPrint('✅ Transaction processed successfully');
      return TransactionModel.fromJson(responseMap);
    } catch (e) {
      debugPrint('❌ Transaction processing error: ${e.toString()}');
      throw ServerException(
        message: 'Failed to process transaction: ${e.toString()}',
        statusCode: '500',
      );
    }
  }
  
  

  @override
  Future<TransactionModel> updateTransactionDetails({
    required String id,
    String? customerName,
    String? totalAmount,
    String? refNumber,
    File? signature,
    String? customerImage,
    List<InvoiceModel>? invoices,
    String? deliveryNumber,
    DateTime? transactionDate,
    TransactionStatus? transactionStatus,
    ModeOfPayment? modeOfPayment,
    bool? isCompleted,
    File? pdf,
    String? tripId,
    String? customerId,
    String? completedCustomerId,
  }) async {
    try {
      debugPrint('🔄 Updating transaction details: $id');
      
      final body = <String, dynamic>{};
      
      if (customerName != null) body['customerName'] = customerName;
      if (totalAmount != null) body['totalAmount'] = totalAmount;
      if (refNumber != null) body['refNumber'] = refNumber;
      if (deliveryNumber != null) body['deliveryNumber'] = deliveryNumber;
      if (transactionDate != null) body['transactionDate'] = transactionDate.toIso8601String();
      if (transactionStatus != null) body['status'] = transactionStatus.toString().split('.').last;
      if (modeOfPayment != null) body['modeOfPayment'] = modeOfPayment.toString().split('.').last;
      if (isCompleted != null) body['isCompleted'] = isCompleted;
      if (customerId != null) body['customer'] = customerId;
      if (tripId != null) body['trip'] = tripId;
      if (completedCustomerId != null) body['completedCustomer'] = completedCustomerId;
      if (invoices != null && invoices.isNotEmpty) {
        body['invoice'] = invoices.map((inv) => inv.id).toList();
      }
      
      body['updated'] = DateTime.now().toUtc().toIso8601String();
      
      final files = <String, MultipartFile>{};
      
      if (signature != null) {
        final signatureBytes = await signature.readAsBytes();
        files['signature'] = MultipartFile.fromBytes(
          'signature',
          signatureBytes,
          filename: 'signature.pdf',
          contentType: MediaType('application', 'pdf'),
        );
      }
      
      if (customerImage != null) {
        final imagePaths = customerImage.split(',');
        for (var i = 0; i < imagePaths.length; i++) {
          final imageBytes = await File(imagePaths[i]).readAsBytes();
          files['customerImage'] = MultipartFile.fromBytes(
            'customerImage',
            imageBytes,
            filename: 'customer_image_$i.jpg',
          );
        }
      }
      
      if (pdf != null) {
        final pdfBytes = await pdf.readAsBytes();
        files['pdf'] = MultipartFile.fromBytes(
          'pdf',
          pdfBytes,
          filename: 'receipt.pdf',
          contentType: MediaType('application', 'pdf'),
        );
      }
      
      final record = await _pocketBase.collection('transactions').update(
        id,
        body: body,
      //  files: files.isEmpty ? null : files.values.toList(),
      );
      
      final responseMap = {
        'id': record.id,
        'collectionId': record.collectionId,
        'collectionName': record.collectionName,
        ...record.data,
      };
      
      debugPrint('✅ Transaction updated successfully');
      return TransactionModel.fromJson(responseMap);
    } catch (e) {
      debugPrint('❌ Transaction update error: ${e.toString()}');
      throw ServerException(
        message: 'Failed to update transaction: ${e.toString()}',
        statusCode: '500',
      );
    }
  }
  
}
