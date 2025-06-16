import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/delivery_data/presentation/bloc/delivery_data_bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/delivery_data/presentation/bloc/delivery_data_event.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/invoice_preset_group/presentation/bloc/invoice_preset_group_bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/invoice_preset_group/presentation/bloc/invoice_preset_group_event.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/invoice_preset_group/presentation/bloc/invoice_preset_group_state.dart';
import 'package:xpro_delivery_admin_app/src/master_data/tripticket_screen/presentation/widget/create_trip_ticket_forms/invoice_preset_group_table.dart';

class InvoicePresetGroupDialog extends StatefulWidget {
  final String? deliveryId;
  final VoidCallback? onPresetAdded;

  const InvoicePresetGroupDialog({
    super.key,
    this.deliveryId,
    this.onPresetAdded,
  });

  @override
  State<InvoicePresetGroupDialog> createState() =>
      _InvoicePresetGroupDialogState();
}

class _InvoicePresetGroupDialogState extends State<InvoicePresetGroupDialog> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load all preset groups when the dialog opens
    context.read<InvoicePresetGroupBloc>().add(
      const GetAllUnassignedInvoicePresetGroupsEvent(),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _searchPresetGroups() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      context.read<InvoicePresetGroupBloc>().add(
        SearchPresetGroupByRefIdEvent(query),
      );
    } else {
      context.read<InvoicePresetGroupBloc>().add(
        const GetAllUnassignedInvoicePresetGroupsEvent(),
      );
    }
  }

  void _closeDialog() {
    if (mounted) {
      // Use GoRouter to pop the dialog instead of Navigator
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<InvoicePresetGroupBloc, InvoicePresetGroupState>(
      listener: (context, state) {
        if (state is InvoicesAddedToDelivery) {
          // Refresh delivery data
          context.read<DeliveryDataBloc>().add(const GetAllDeliveryDataEvent());

          // Call the callback if provided
          if (widget.onPresetAdded != null) {
            widget.onPresetAdded!();
          }

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Invoices added to delivery successfully'),
              backgroundColor: Colors.green,
            ),
          );

          // Close the dialog using GoRouter
          _closeDialog();
        }
      },
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.8,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.playlist_add_check, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    'Invoice Preset Groups',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: _closeDialog,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search by Ref ID or Name',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      _searchPresetGroups();
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onSubmitted: (_) => _searchPresetGroups(),
                onChanged: (value) {
                  if (value.isEmpty) {
                    _searchPresetGroups();
                  }
                },
              ),
              const SizedBox(height: 16),
              Expanded(
                child: BlocBuilder<
                  InvoicePresetGroupBloc,
                  InvoicePresetGroupState
                >(
                  builder: (context, state) {
                    if (state is InvoicePresetGroupLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state is InvoicePresetGroupError) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: Colors.red,
                              size: 48,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Error: ${state.message}',
                              style: const TextStyle(color: Colors.red),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _searchPresetGroups,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      );
                    }

                    if (state is AllUnassignedInvoicePresetGroupsLoaded) {
                      final presetGroups = state.presetGroups;

                      if (presetGroups.isEmpty) {
                        return const Center(
                          child: Text('No preset groups found'),
                        );
                      }

                      // Add debug print to verify data
                      debugPrint(
                        '🔍 Displaying ${presetGroups.length} preset groups',
                      );
                      for (var group in presetGroups) {
                        debugPrint(
                          '  - Group: ${group.name} (${group.id}) with ${group.invoices.length} invoices',
                        );
                      }

                      return InvoicePresetGroupTable(
                        presetGroups: presetGroups,
                        deliveryId: widget.deliveryId,
                      );
                    }

                    return const Center(
                      child: Text('Select a preset group to add to delivery'),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
