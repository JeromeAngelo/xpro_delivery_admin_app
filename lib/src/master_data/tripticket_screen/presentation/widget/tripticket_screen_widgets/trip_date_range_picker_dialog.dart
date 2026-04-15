import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// A simple date range picker dialog for filtering trips by date
class TripDateRangePickerDialog extends StatefulWidget {
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;
  final Function(DateTime? startDate, DateTime? endDate) onApply;

  const TripDateRangePickerDialog({
    super.key,
    this.initialStartDate,
    this.initialEndDate,
    required this.onApply,
  });

  @override
  State<TripDateRangePickerDialog> createState() =>
      _TripDateRangePickerDialogState();
}

class _TripDateRangePickerDialogState extends State<TripDateRangePickerDialog> {
  late DateTime? _startDate;
  late DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _startDate = widget.initialStartDate;
    _endDate = widget.initialEndDate;
  }

  /// Shows the date picker for start date
  Future<void> _pickStartDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() {
        _startDate = date;
        // If end date is before start date, clear it
        if (_endDate != null && _endDate!.isBefore(date)) {
          _endDate = null;
        }
      });
    }
  }

  /// Shows the date picker for end date
  Future<void> _pickEndDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() {
        _endDate = date;
      });
    }
  }

  /// Clear start date
  void _clearStartDate() {
    setState(() {
      _startDate = null;
    });
  }

  /// Clear end date
  void _clearEndDate() {
    setState(() {
      _endDate = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Filter by Date'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Start Delivery Date Tile
            _buildDateTile(
              label: 'Start Delivery Date',
              date: _startDate,
              onTap: _pickStartDate,
              onClear: _clearStartDate,
            ),
            const SizedBox(height: 20),

            // End Delivery Date Tile
            _buildDateTile(
              label: 'End Delivery Date',
              date: _endDate,
              onTap: _pickEndDate,
              onClear: _clearEndDate,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            widget.onApply(_startDate, _endDate);
            Navigator.pop(context);
          },
          child: const Text('Apply'),
        ),
      ],
    );
  }

  /// Build a date picker tile (similar to TripDeliveryDateForm style)
  Widget _buildDateTile({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
    required VoidCallback onClear,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: onTap,
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Center(
                    child: Text(
                      date != null
                          ? DateFormat('MM/dd/yyyy').format(date)
                          : 'Select $label',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            IconButton(
              onPressed: onClear,
              icon: Icon(
                Icons.clear,
                color: Theme.of(context).colorScheme.error,
              ),
              tooltip: 'Clear $label',
            ),
          ],
        ),
      ],
    );
  }
}

/// Helper function to show the date range picker dialog
Future<void> showTripDateRangePickerDialog({
  required BuildContext context,
  DateTime? initialStartDate,
  DateTime? initialEndDate,
  required Function(DateTime? startDate, DateTime? endDate) onApply,
}) {
  return showDialog(
    context: context,
    builder:
        (context) => TripDateRangePickerDialog(
          initialStartDate: initialStartDate,
          initialEndDate: initialEndDate,
          onApply: onApply,
        ),
  );
}
