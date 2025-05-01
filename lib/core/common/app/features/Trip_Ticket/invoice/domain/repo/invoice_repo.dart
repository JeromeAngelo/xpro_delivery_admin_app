import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/invoice/domain/entity/invoice_entity.dart';
import 'package:xpro_delivery_admin_app/core/enums/invoice_status.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';

abstract class InvoiceRepo {
  const InvoiceRepo();

  // Existing functions to keep
  ResultFuture<List<InvoiceEntity>> getInvoices();
  ResultFuture<List<InvoiceEntity>> getInvoicesByTripId(String tripId);
  ResultFuture<List<InvoiceEntity>> getInvoicesByCustomerId(String customerId);
  // New function to get invoices by completed customer ID
  ResultFuture<List<InvoiceEntity>> getInvoicesByCompletedCustomerId(String completedCustomerId);
  
  // Remove local functions
  // ResultFuture<List<InvoiceEntity>> loadLocalInvoices();
  // ResultFuture<List<InvoiceEntity>> loadLocalInvoicesByTripId(String tripId);
  // ResultFuture<List<InvoiceEntity>> loadLocalInvoicesByCustomerId(String customerId);

  // Add the getInvoiceById function
  ResultFuture<InvoiceEntity> getInvoiceById(String id);
  
  // New functions
  ResultFuture<InvoiceEntity> createInvoice({
    required String invoiceNumber,
    required String customerId,
    required String tripId,
    required List<String> productIds,
    InvoiceStatus? status,
    double? totalAmount,
    double? confirmTotalAmount,
    String? customerDeliveryStatus,
  });
  
  ResultFuture<InvoiceEntity> updateInvoice({
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
  
  ResultFuture<bool> deleteInvoice(String id);
  
  ResultFuture<bool> deleteAllInvoices(List<String> ids);
}
