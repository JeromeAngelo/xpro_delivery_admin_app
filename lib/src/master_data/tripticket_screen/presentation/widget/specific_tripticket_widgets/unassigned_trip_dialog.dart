import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/trip_ticket/trip/domain/entity/trip_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/trip_ticket/trip/presentation/bloc/trip_bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/trip_ticket/trip/presentation/bloc/trip_event.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/trip_ticket/trip/presentation/bloc/trip_state.dart';

/// Shows a modernized confirmation dialog for unassigning a trip.
/// Includes trip info summary and a required remarks field.
void showUnassignedTripDialog(
  BuildContext context, {
  required TripEntity trip,
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext dialogContext) {
      return BlocProvider.value(
        value: context.read<TripBloc>(),
        child: _UnassignedTripDialog(trip: trip),
      );
    },
  );
}

class _UnassignedTripDialog extends StatefulWidget {
  final TripEntity trip;

  const _UnassignedTripDialog({required this.trip});

  @override
  State<_UnassignedTripDialog> createState() => _UnassignedTripDialogState();
}

class _UnassignedTripDialogState extends State<_UnassignedTripDialog> {
  final _formKey = GlobalKey<FormState>();
  final _remarksController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _remarksController.dispose();
    super.dispose();
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'N/A';
    final phDateTime = dateTime.add(const Duration(hours: 8));
    final hour24 = phDateTime.hour;
    final hour12 =
        hour24 == 0
            ? 12
            : hour24 > 12
            ? hour24 - 12
            : hour24;
    final amPm = hour24 >= 12 ? 'PM' : 'AM';
    final month = phDateTime.month.toString().padLeft(2, '0');
    final day = phDateTime.day.toString().padLeft(2, '0');
    final year = phDateTime.year;
    return '$month/$day/$year ${hour12.toString().padLeft(2, '0')}:${phDateTime.minute.toString().padLeft(2, '0')} $amPm';
  }

  String _dateFormat(DateTime? date) {
    if (date == null) return 'Not set';
    return DateFormat('MM/dd/yyyy').format(date);
  }

  void _handleUnassign() {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    context.read<TripBloc>().add(
      UnassignTripEvent(
        tripId: widget.trip.id!,
        remarks: _remarksController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocConsumer<TripBloc, TripState>(
      listener: (context, state) {
        if (state is TripUnassigned) {
          // Success - close dialog and show success message
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 12),
                  Text(
                    'Trip ${widget.trip.tripNumberId ?? ''} has been unassigned successfully',
                  ),
                ],
              ),
              backgroundColor: Colors.green.shade700,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              margin: const EdgeInsets.all(16),
            ),
          );
        } else if (state is TripError && _isSubmitting) {
          // Error - show error message
          setState(() {
            _isSubmitting = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text('Failed to unassign trip: ${state.message}'),
                  ),
                ],
              ),
              backgroundColor: Colors.red.shade700,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              margin: const EdgeInsets.all(16),
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is TripLoading || _isSubmitting;

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 8,
          child: Container(
            width: 480,
            constraints: const BoxConstraints(maxHeight: 600),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: colorScheme.surface,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with warning icon
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 20,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.orange.shade100,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.person_remove_rounded,
                          color: Colors.orange.shade700,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Unassign Trip',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'This action will remove the assigned team and vehicle',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed:
                            isLoading
                                ? null
                                : () => Navigator.of(context).pop(),
                        tooltip: 'Close',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),

                // Content
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Trip Info Card
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest
                                  .withOpacity(0.5),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: colorScheme.outlineVariant.withOpacity(
                                  0.5,
                                ),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.local_shipping,
                                      color: colorScheme.primary,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Trip Information',
                                      style: theme.textTheme.titleSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                _buildInfoRow(
                                  context,
                                  'Trip Number',
                                  widget.trip.tripNumberId ?? 'N/A',
                                ),
                                const SizedBox(height: 8),
                                _buildInfoRow(
                                  context,
                                  'Route Name',
                                  widget.trip.name ?? 'N/A',
                                ),
                                const SizedBox(height: 8),
                                _buildInfoRow(
                                  context,
                                  'Delivery Date',
                                  _dateFormat(widget.trip.deliveryDate),
                                ),
                                const SizedBox(height: 8),
                                _buildInfoRow(
                                  context,
                                  'Deliveries',
                                  '${widget.trip.deliveryData.length}',
                                ),
                                const SizedBox(height: 8),
                                _buildInfoRow(
                                  context,
                                  'Dispatched By',
                                  widget.trip.dispatcher ?? 'N/A',
                                ),
                                const SizedBox(height: 8),
                                _buildInfoRow(
                                  context,
                                  'Created',
                                  _formatDateTime(widget.trip.created),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Warning message
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.warning_amber_rounded,
                                  color: Colors.red.shade700,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'This action cannot be undone. The delivery team and vehicle will be removed from this trip.',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: Colors.red.shade700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Remarks field
                          Text(
                            'Remarks *',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _remarksController,
                            enabled: !isLoading,
                            maxLines: 3,
                            minLines: 2,
                            decoration: InputDecoration(
                              hintText:
                                  'Enter a reason for unassigning this trip...',
                              hintStyle: TextStyle(
                                color: colorScheme.onSurfaceVariant.withOpacity(
                                  0.6,
                                ),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              prefixIcon: const Padding(
                                padding: EdgeInsets.only(bottom: 48),
                                child: Icon(Icons.note_alt_outlined, size: 20),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Remarks is required';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Action buttons
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: colorScheme.outlineVariant.withOpacity(0.5),
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Cancel button
                      OutlinedButton(
                        onPressed:
                            isLoading
                                ? null
                                : () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          side: BorderSide(color: colorScheme.outline),
                        ),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 12),
                      // Unassign button
                      ElevatedButton.icon(
                        onPressed: isLoading ? null : _handleUnassign,
                        icon:
                            isLoading
                                ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                                : const Icon(
                                  Icons.person_remove_rounded,
                                  size: 18,
                                ),
                        label: Text(isLoading ? 'Unassigning...' : 'Unassign'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange.shade700,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          disabledBackgroundColor: Colors.orange.shade300,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}
