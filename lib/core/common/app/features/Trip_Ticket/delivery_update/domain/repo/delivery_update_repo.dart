import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/delivery_update/data/models/delivery_update_model.dart' show DeliveryUpdateModel;
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/delivery_update/domain/entity/delivery_update_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/invoice/data/models/invoice_models.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/return_product/data/model/return_model.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/transaction/data/model/transaction_model.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';

abstract class DeliveryUpdateRepo {
  const DeliveryUpdateRepo();

  // Core delivery status operations
  ResultFuture<List<DeliveryUpdateEntity>> getDeliveryStatusChoices(String customerId);
  ResultFuture<void> updateDeliveryStatus(String customerId, String statusId);
  
  // Completion and initialization
  ResultFuture<void> completeDelivery(String customerId, {
    required List<InvoiceModel> invoices,
    required List<TransactionModel> transactions,
    required List<ReturnModel> returns,
    required List<DeliveryUpdateModel> deliveryStatus,
  });
  
  // Enhanced status check function
  ResultFuture<DataMap> checkEndDeliverStatus(String tripId);
  ResultFuture<void> initializePendingStatus(List<String> customerIds);
  
  // Status creation
  ResultFuture<void> createDeliveryStatus(
    String customerId, {
    required String title,
    required String subtitle,
    required DateTime time,
    required bool isAssigned,
    required String image,
  });

  // Queue remarks update
  ResultFuture<void> updateQueueRemarks(
    String customerId, 
    String queueCount,
  );
  
  // New functions
  ResultFuture<List<DeliveryUpdateEntity>> getAllDeliveryUpdates();
  
  ResultFuture<DeliveryUpdateEntity> createDeliveryUpdate({
    required String title,
    required String subtitle,
    required DateTime time,
    required String customerId,
    required bool isAssigned,
    String? assignedTo,
    String? image,
    String? remarks,
  });
  
  ResultFuture<DeliveryUpdateEntity> updateDeliveryUpdate({
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
  
  ResultFuture<bool> deleteDeliveryUpdate(String id);
  
  ResultFuture<bool> deleteAllDeliveryUpdates(List<String> ids);
}
