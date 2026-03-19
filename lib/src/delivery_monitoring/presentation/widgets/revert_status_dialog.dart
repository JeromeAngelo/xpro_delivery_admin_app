import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/common/app/features/delivery_status_choices/presentation/bloc/delivery_status_choices_bloc.dart';
import '../../../../core/common/app/features/delivery_status_choices/presentation/bloc/delivery_status_choices_event.dart';
import '../../../../core/common/app/features/delivery_status_choices/presentation/bloc/delivery_status_choices_state.dart';
import '../../../../core/common/app/features/trip_ticket/delivery_data/domain/entity/delivery_data_entity.dart';
import '../../../../core/common/app/features/trip_ticket/delivery_update/domain/entity/delivery_update_entity.dart';

class RevertDeliveryStatusDialog extends StatefulWidget {
  final DeliveryDataEntity deliveryData;
  final VoidCallback? onConfirm;

  const RevertDeliveryStatusDialog({
    super.key,
    required this.deliveryData,
    this.onConfirm,
  });

  static Future<void> show(
    BuildContext context, {
    required DeliveryDataEntity deliveryData,
    VoidCallback? onConfirm,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => RevertDeliveryStatusDialog(
            deliveryData: deliveryData,
            onConfirm: onConfirm,
          ),
    );
  }

  @override
  State<RevertDeliveryStatusDialog> createState() =>
      _RevertDeliveryStatusDialogState();
}

class _RevertDeliveryStatusDialogState
    extends State<RevertDeliveryStatusDialog> {
  String? _selectedStatus;
  final TextEditingController _reasonController = TextEditingController();

  bool _hasRequestedStatuses = false;

  @override
  void initState() {
    super.initState();
    // Load assigned delivery status choices as soon as the dialog is shown.
    // Use a post-frame callback to ensure the BuildContext has access to
    // the required Bloc providers.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAssignedStatuses();
    });
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  String _getCurrentDeliveryStatus(DeliveryDataEntity deliveryData) {
    if (deliveryData.deliveryUpdates.isEmpty) return 'N/A';

    final sortedUpdates = List<DeliveryUpdateEntity>.from(
      deliveryData.deliveryUpdates,
    );

    sortedUpdates.sort((a, b) {
      final timeA =
          a.time ?? a.created ?? DateTime.fromMillisecondsSinceEpoch(0);
      final timeB =
          b.time ?? b.created ?? DateTime.fromMillisecondsSinceEpoch(0);

      return timeB.compareTo(timeA);
    });

    return sortedUpdates.first.title ?? 'N/A';
  }

  void _loadAssignedStatuses() {
    if (_hasRequestedStatuses) return;
    if (widget.deliveryData.id == null) return;

    _hasRequestedStatuses = true;

    context.read<DeliveryStatusChoicesBloc>().add(
      GetAllAssignedDeliveryStatusChoicesEvent(widget.deliveryData.id!),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tripName = widget.deliveryData.trip?.name ?? 'N/A';
    final customerName = widget.deliveryData.customer?.name ?? 'N/A';
    final currentStatus = _getCurrentDeliveryStatus(widget.deliveryData);
    final theme = Theme.of(context);

    return Dialog(
      backgroundColor: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        width: 560,
        padding: const EdgeInsets.fromLTRB(24, 22, 24, 20),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: theme.colorScheme.onSurface),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  Icons.keyboard_return_rounded,
                  color: theme.colorScheme.primary,
                  size: 26,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Change Delivery Status',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                children: [
                  _buildInfoRow(
                    context,
                    icon: Icons.tag_rounded,
                    label: 'Picklist ID',
                    value: tripName,
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    context,
                    icon: Icons.description_outlined,
                    label: 'Picklist Name',
                    value: customerName,
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    context,
                    icon: Icons.info_outline_rounded,
                    label: 'Current Status',
                    value: currentStatus,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Revert to status:',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 10),

            BlocBuilder<DeliveryStatusChoicesBloc, DeliveryStatusChoicesState>(
              builder: (context, state) {
                final bool isLoading = state is DeliveryStatusChoicesLoading;

                // Build a combined list of revert targets:
                // 1) historical statuses from deliveryData.deliveryUpdates (deduped, preserve order)
                // 2) assigned/allowed statuses returned by the bloc (append if missing)
                final List<String> historyRaw =
                    widget.deliveryData.deliveryUpdates
                        .map((u) => u.title ?? '')
                        .where((t) => t.trim().isNotEmpty)
                        .toList();

                final List<String> historyStatuses = [];
                final seen = <String>{};
                for (final t in historyRaw) {
                  final key = t.toLowerCase().trim();
                  if (!seen.contains(key)) {
                    seen.add(key);
                    historyStatuses.add(t);
                  }
                }

                List<String> availableStatuses = List.from(historyStatuses);
                if (state is AssignedDeliveryStatusChoicesLoaded) {
                  for (final e in state.updates) {
                    final title = (e.title ?? '').trim();
                    if (title.isEmpty) continue;
                    final key = title.toLowerCase();
                    if (!seen.contains(key)) {
                      seen.add(key);
                      availableStatuses.add(title);
                    }
                  }
                }

                return GestureDetector(
                  onTap: _loadAssignedStatuses,
                  child: AbsorbPointer(
                    absorbing: isLoading,
                    child: DropdownButtonFormField<String>(
                      value: _selectedStatus,
                      isExpanded: true,
                      decoration: InputDecoration(
                        hintText:
                            isLoading ? 'Loading statuses...' : currentStatus,
                        prefixIcon:
                            isLoading
                                ? const Padding(
                                  padding: EdgeInsets.all(14),
                                  child: SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                )
                                : const Icon(Icons.swap_vert_rounded),
                        filled: true,
                        fillColor: Colors.black.withOpacity(0.03),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 18,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: theme.colorScheme.primary,
                            width: 1.5,
                          ),
                        ),
                      ),
                      items:
                          availableStatuses
                              .map(
                                (status) => DropdownMenuItem<String>(
                                  value: status,
                                  child: Text(
                                    status,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedStatus = value;
                        });
                      },
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Reason for status change:',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: _reasonController,
              minLines: 4,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Enter reason for status change',
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(bottom: 64),
                  child: Icon(Icons.edit_note_rounded),
                ),
                filled: true,
                fillColor: Colors.black.withOpacity(0.03),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: theme.colorScheme.primary,
                    width: 1.5,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: theme.colorScheme.surface,
                    foregroundColor: theme.colorScheme.primary,
                    elevation: 0,
                    side: BorderSide(color: Colors.grey.shade300),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () {
                    widget.onConfirm?.call();
                  },
                  icon: const Icon(Icons.history_rounded),
                  label: const Text(
                    'Revert Status',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 22,
          color: theme.colorScheme.primary.withOpacity(0.85),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface,
                height: 1.4,
              ),
              children: [
                TextSpan(
                  text: '$label: ',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                TextSpan(
                  text: value,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
