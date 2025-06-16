import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/invoice_preset_group/domain/usecases/add_all_invoices_to_delivery.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/invoice_preset_group/domain/usecases/get_all_invoice_preset_groups.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/invoice_preset_group/domain/usecases/get_all_unassigned_invoices.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/invoice_preset_group/domain/usecases/search_preset_group_by_ref_id.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/invoice_preset_group/presentation/bloc/invoice_preset_group_event.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/invoice_preset_group/presentation/bloc/invoice_preset_group_state.dart';

class InvoicePresetGroupBloc
    extends Bloc<InvoicePresetGroupEvent, InvoicePresetGroupState> {
  final GetAllInvoicePresetGroups _getAllInvoicePresetGroups;
  final AddAllInvoicesToDelivery _addAllInvoicesToDelivery;
  final SearchPresetGroupByRefId _searchPresetGroupByRefId;
  final GetAllUnassignedInvoices _getAllUnassignedInvoices;

  InvoicePresetGroupState? _cachedState;

  InvoicePresetGroupBloc({
    required GetAllInvoicePresetGroups getAllInvoicePresetGroups,
    required AddAllInvoicesToDelivery addAllInvoicesToDelivery,
    required SearchPresetGroupByRefId searchPresetGroupByRefId,
    required GetAllUnassignedInvoices getAllUnassignedInvoices,
  }) : _getAllInvoicePresetGroups = getAllInvoicePresetGroups,
       _addAllInvoicesToDelivery = addAllInvoicesToDelivery,
       _searchPresetGroupByRefId = searchPresetGroupByRefId,
       _getAllUnassignedInvoices = getAllUnassignedInvoices,
       super(const InvoicePresetGroupInitial()) {
    on<GetAllInvoicePresetGroupsEvent>(_onGetAllInvoicePresetGroups);
    on<AddAllInvoicesToDeliveryEvent>(_onAddAllInvoicesToDelivery);
    on<SearchPresetGroupByRefIdEvent>(_onSearchPresetGroupByRefId);
    on<GetAllUnassignedInvoicePresetGroupsEvent>(
      _onGetAllUnassignedInvoicePresetGroups,
    );
  }

  Future<void> _onGetAllInvoicePresetGroups(
    GetAllInvoicePresetGroupsEvent event,
    Emitter<InvoicePresetGroupState> emit,
  ) async {
    emit(const InvoicePresetGroupLoading());
    debugPrint('🔄 BLOC: Getting all invoice preset groups');

    final result = await _getAllInvoicePresetGroups();
    result.fold(
      (failure) {
        debugPrint(
          '❌ BLOC: Failed to get invoice preset groups: ${failure.message}',
        );
        emit(
          InvoicePresetGroupError(
            message: failure.message,
            statusCode: failure.statusCode,
          ),
        );
      },
      (presetGroups) {
        debugPrint(
          '✅ BLOC: Successfully retrieved ${presetGroups.length} invoice preset groups',
        );
        final newState = AllInvoicePresetGroupsLoaded(presetGroups);
        _cachedState = newState;
        emit(newState);
      },
    );
  }

  Future<void> _onGetAllUnassignedInvoicePresetGroups(
    GetAllUnassignedInvoicePresetGroupsEvent event,
    Emitter<InvoicePresetGroupState> emit,
  ) async {
    emit(const InvoicePresetGroupLoading());
    final result = await _getAllUnassignedInvoices();
    result.fold(
      (failure) {
        debugPrint(
          'BLOC: Failed to get unassigned invoices: ${failure.message}',
        );
        emit(
          InvoicePresetGroupError(
            message: failure.errorMessage,
            statusCode: failure.statusCode,
          ),
        );
      },
      (unAssignedInvoices) {
        debugPrint(
          'BLOC: Successfully retrieved ${unAssignedInvoices.length} unassigned invoices',
        );
        final newState = AllUnassignedInvoicePresetGroupsLoaded(
          unAssignedInvoices,
        );
        _cachedState = newState;
        emit(newState);
      },
    );
  }

  Future<void> _onAddAllInvoicesToDelivery(
    AddAllInvoicesToDeliveryEvent event,
    Emitter<InvoicePresetGroupState> emit,
  ) async {
    emit(const InvoicePresetGroupLoading());
    debugPrint(
      '🔄 BLOC: Adding invoices from preset group ${event.presetGroupId} to delivery ${event.deliveryId}',
    );

    final params = AddAllInvoicesToDeliveryParams(
      presetGroupId: event.presetGroupId,
      deliveryId: event.deliveryId,
    );

    final result = await _addAllInvoicesToDelivery(params);
    result.fold(
      (failure) {
        debugPrint(
          '❌ BLOC: Failed to add invoices to delivery: ${failure.message}',
        );
        emit(
          InvoicePresetGroupError(
            message: failure.message,
            statusCode: failure.statusCode,
          ),
        );
      },
      (_) {
        debugPrint('✅ BLOC: Successfully added invoices to delivery');
        final newState = InvoicesAddedToDelivery(
          presetGroupId: event.presetGroupId,
          deliveryId: event.deliveryId,
        );
        emit(newState);

        // Refresh the preset groups list after adding invoices to delivery
        add(const GetAllInvoicePresetGroupsEvent());
      },
    );
  }

  Future<void> _onSearchPresetGroupByRefId(
    SearchPresetGroupByRefIdEvent event,
    Emitter<InvoicePresetGroupState> emit,
  ) async {
    emit(const InvoicePresetGroupLoading());
    debugPrint(
      '🔍 BLOC: Searching for preset groups with refId: ${event.refId}',
    );

    if (event.refId.isEmpty) {
      // If search query is empty, return all preset groups
      add(const GetAllInvoicePresetGroupsEvent());
      return;
    }

    final result = await _searchPresetGroupByRefId(event.refId);
    result.fold(
      (failure) {
        debugPrint('❌ BLOC: Search failed: ${failure.message}');
        emit(
          InvoicePresetGroupError(
            message: failure.message,
            statusCode: failure.statusCode,
          ),
        );
      },
      (presetGroups) {
        debugPrint(
          '✅ BLOC: Found ${presetGroups.length} matching preset groups',
        );
        final newState = PresetGroupsSearchResults(
          presetGroups: presetGroups,
          searchQuery: event.refId,
        );
        _cachedState = newState;
        emit(newState);
      },
    );
  }

  @override
  Future<void> close() {
    _cachedState = null;
    return super.close();
  }
}
