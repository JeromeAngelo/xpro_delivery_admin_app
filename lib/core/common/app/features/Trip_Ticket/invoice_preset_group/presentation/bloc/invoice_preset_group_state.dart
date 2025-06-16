import 'package:equatable/equatable.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/invoice_preset_group/domain/entity/invoice_preset_group_entity.dart';

abstract class InvoicePresetGroupState extends Equatable {
  const InvoicePresetGroupState();

  @override
  List<Object?> get props => [];
}

class InvoicePresetGroupInitial extends InvoicePresetGroupState {
  const InvoicePresetGroupInitial();
}

class InvoicePresetGroupLoading extends InvoicePresetGroupState {
  const InvoicePresetGroupLoading();
}

class InvoicePresetGroupError extends InvoicePresetGroupState {
  final String message;
  final String? statusCode;

  const InvoicePresetGroupError({required this.message, this.statusCode});

  @override
  List<Object?> get props => [message, statusCode];
}

// State for getting all invoice preset groups
class AllInvoicePresetGroupsLoaded extends InvoicePresetGroupState {
  final List<InvoicePresetGroupEntity> presetGroups;

  const AllInvoicePresetGroupsLoaded(this.presetGroups);

  @override
  List<Object?> get props => [presetGroups];
}

class AllUnassignedInvoicePresetGroupsLoaded extends InvoicePresetGroupState {
  final List<InvoicePresetGroupEntity> presetGroups;

  const AllUnassignedInvoicePresetGroupsLoaded(this.presetGroups);
}

// State for adding all invoices from a preset group to a delivery
class InvoicesAddedToDelivery extends InvoicePresetGroupState {
  final String presetGroupId;
  final String deliveryId;

  const InvoicesAddedToDelivery({
    required this.presetGroupId,
    required this.deliveryId,
  });

  @override
  List<Object?> get props => [presetGroupId, deliveryId];
}

// State for searching preset groups by reference ID
class PresetGroupsSearchResults extends InvoicePresetGroupState {
  final List<InvoicePresetGroupEntity> presetGroups;
  final String searchQuery;

  const PresetGroupsSearchResults({
    required this.presetGroups,
    required this.searchQuery,
  });

  @override
  List<Object?> get props => [presetGroups, searchQuery];
}
