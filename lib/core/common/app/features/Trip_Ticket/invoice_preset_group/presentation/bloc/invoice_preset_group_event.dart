import 'package:equatable/equatable.dart';

abstract class InvoicePresetGroupEvent extends Equatable {
  const InvoicePresetGroupEvent();

  @override
  List<Object?> get props => [];
}

// Event for getting all invoice preset groups
class GetAllInvoicePresetGroupsEvent extends InvoicePresetGroupEvent {
  const GetAllInvoicePresetGroupsEvent();
}

class GetAllUnassignedInvoicePresetGroupsEvent extends InvoicePresetGroupEvent {
   const GetAllUnassignedInvoicePresetGroupsEvent();
}

// Event for adding all invoices from a preset group to a delivery
class AddAllInvoicesToDeliveryEvent extends InvoicePresetGroupEvent {
  final String presetGroupId;
  final String deliveryId;

  const AddAllInvoicesToDeliveryEvent({
    required this.presetGroupId,
    required this.deliveryId,
  });

  @override
  List<Object?> get props => [presetGroupId, deliveryId];
}

// Event for searching preset groups by reference ID
class SearchPresetGroupByRefIdEvent extends InvoicePresetGroupEvent {
  final String refId;

  const SearchPresetGroupByRefIdEvent(this.refId);

  @override
  List<Object?> get props => [refId];
}

