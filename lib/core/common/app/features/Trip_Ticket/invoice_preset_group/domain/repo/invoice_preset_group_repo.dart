import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/invoice_preset_group/domain/entity/invoice_preset_group_entity.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';

abstract class InvoicePresetGroupRepo {
  const InvoicePresetGroupRepo();

  /// Load all invoice preset groups
  ResultFuture<List<InvoicePresetGroupEntity>> getAllInvoicePresetGroups();

    ResultFuture<List<InvoicePresetGroupEntity>> getAllUnassignedInvoicePresetGroups();

  
  /// Add all invoices from a preset group to a delivery
  /// 
  /// Takes a preset group ID and a delivery ID, and associates all invoices
  /// in the preset group with the specified delivery.
  ResultFuture<void> addAllInvoicesToDelivery({
    required String presetGroupId,
    required String deliveryId,
  });
  
  /// Search for preset groups by reference ID
  /// 
  /// Takes a reference ID string and returns matching preset groups.
  ResultFuture<List<InvoicePresetGroupEntity>> searchPresetGroupByRefId(String refId);
}
