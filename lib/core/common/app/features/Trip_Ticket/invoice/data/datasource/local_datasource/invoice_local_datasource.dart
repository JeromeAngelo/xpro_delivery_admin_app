// import 'package:desktop_app/core/common/app/features/Trip_Ticket/invoice/data/models/invoice_models.dart';
// import 'package:desktop_app/core/errors/exceptions.dart';
// import 'package:desktop_app/objectbox.g.dart';
// import 'package:flutter/foundation.dart';
// import 'package:objectbox/objectbox.dart';

// abstract class InvoiceLocalDatasource {
//   Future<List<InvoiceModel>> getInvoices();
//   Future<List<InvoiceModel>> getInvoicesByTripId(String tripId);
//   Future<List<InvoiceModel>> getInvoicesByCustomerId(String customerId);
//   Future<void> updateInvoice(InvoiceModel invoice);
//   Future<void> cleanupInvalidEntries();
// }

// class InvoiceLocalDatasourceImpl implements InvoiceLocalDatasource {
//   final Box<InvoiceModel> _invoiceBox;

//   InvoiceLocalDatasourceImpl(this._invoiceBox);

//   @override
//   Future<List<InvoiceModel>> getInvoices() async {
//     try {
//       await cleanupInvalidEntries();
//       final invoices = _invoiceBox.getAll().where((i) => i.pocketbaseId.isNotEmpty).toList();

//       debugPrint('📊 Local Invoice Stats:');
//       debugPrint('   📦 Total Valid Invoices: ${invoices.length}');

//       return invoices;
//     } catch (e) {
//       throw CacheException(message: e.toString());
//     }
//   }

//   @override
//   Future<List<InvoiceModel>> getInvoicesByTripId(String tripId) async {
//     try {
//       debugPrint('🔍 Fetching local invoices for trip: $tripId');
      
//       final invoices = _invoiceBox
//           .query(InvoiceModel_.tripId.equals(tripId))
//           .build()
//           .find()
//           .where((invoice) => invoice.pocketbaseId.isNotEmpty)
//           .toList();

//       debugPrint('📦 Found ${invoices.length} invoices for trip $tripId');
//       return invoices;
//     } catch (e) {
//       debugPrint('❌ Error fetching trip invoices: $e');
//       throw CacheException(message: e.toString());
//     }
//   }

//   @override
//   Future<List<InvoiceModel>> getInvoicesByCustomerId(String customerId) async {
//     try {
//       debugPrint('🔍 Fetching local invoices for customer: $customerId');
      
//       final invoices = _invoiceBox
//           .query(InvoiceModel_.customerId.equals(customerId))
//           .build()
//           .find()
//           .where((invoice) => invoice.pocketbaseId.isNotEmpty)
//           .toList();

//       debugPrint('📦 Found ${invoices.length} invoices for customer $customerId');
//       return invoices;
//     } catch (e) {
//       debugPrint('❌ Error fetching customer invoices: $e');
//       throw CacheException(message: e.toString());
//     }
//   }

//   @override
//   Future<void> updateInvoice(InvoiceModel invoice) async {
//     try {
//       debugPrint('💾 Processing Invoice: ${invoice.invoiceNumber}');
//       debugPrint('   📝 Products: ${invoice.productList.length}');
//       await _autoSave(invoice);
//     } catch (e) {
//       throw CacheException(message: e.toString());
//     }
//   }

//   Future<void> _autoSave(InvoiceModel invoice) async {
//     try {
//       if (invoice.pocketbaseId.isEmpty) {
//         debugPrint('⚠️ Skipping invalid invoice data');
//         return;
//       }

//       debugPrint('🔍 Processing invoice: ${invoice.invoiceNumber} (ID: ${invoice.pocketbaseId})');

//       final existingInvoice = _invoiceBox
//           .query(InvoiceModel_.pocketbaseId.equals(invoice.pocketbaseId))
//           .build()
//           .findFirst();

//       if (existingInvoice != null) {
//         debugPrint('🔄 Updating existing invoice: ${invoice.invoiceNumber}');
//         invoice.objectBoxId = existingInvoice.objectBoxId;
//       } else {
//         debugPrint('➕ Adding new invoice: ${invoice.invoiceNumber}');
//       }

//       _invoiceBox.put(invoice);
//       final totalInvoices = _invoiceBox.count();
//       debugPrint('📊 Current total valid invoices: $totalInvoices');
//     } catch (e) {
//       debugPrint('❌ Save operation failed: ${e.toString()}');
//       throw CacheException(message: e.toString());
//     }
//   }

//   @override
//   Future<void> cleanupInvalidEntries() async {
//     final invalidInvoices = _invoiceBox.getAll().where((i) => i.pocketbaseId.isEmpty).toList();

//     if (invalidInvoices.isNotEmpty) {
//       debugPrint('🧹 Removing ${invalidInvoices.length} invalid invoices');
//       final validIds = invalidInvoices
//           .where((i) => i.objectBoxId > 0)
//           .map((i) => i.objectBoxId)
//           .toList();

//       if (validIds.isNotEmpty) {
//         _invoiceBox.removeMany(validIds);
//         debugPrint('✅ Removed ${validIds.length} invalid entries');
//       }
//     }
//   }
// }
