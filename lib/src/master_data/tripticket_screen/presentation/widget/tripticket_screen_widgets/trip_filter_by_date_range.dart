import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/trip/presentation/bloc/trip_bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/trip/presentation/bloc/trip_event.dart';
import 'package:intl/intl.dart';

class TripDateRangeFilter extends StatefulWidget {
  final Function(DateTime? startDate, DateTime? endDate)? onDateRangeChanged;
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;

  const TripDateRangeFilter({
    super.key,
    this.onDateRangeChanged,
    this.initialStartDate,
    this.initialEndDate,
  });

  @override
  State<TripDateRangeFilter> createState() => _TripDateRangeFilterState();
}

class _TripDateRangeFilterState extends State<TripDateRangeFilter> {
  DateTime? _startDate;
  DateTime? _endDate;
  final GlobalKey _filterKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _startDate = widget.initialStartDate;
    _endDate = widget.initialEndDate;
  }

  void _showDateRangeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        DateTime? tempStartDate = _startDate;
        DateTime? tempEndDate = _endDate;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.date_range, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 8),
                  const Text('Filter by Date Range'),
                ],
              ),
              content: SizedBox(
                width: 350,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Select date range to filter trips:',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    
                    // Start Date
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Start Date',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              InkWell(
                                onTap: () async {
                                  final date = await showDatePicker(
                                    context: context,
                                    initialDate: tempStartDate ?? DateTime.now(),
                                    firstDate: DateTime(2020),
                                    lastDate: DateTime.now().add(const Duration(days: 365)),
                                  );
                                  if (date != null) {
                                    setDialogState(() {
                                      tempStartDate = date;
                                      // If end date is before start date, clear it
                                      if (tempEndDate != null && tempEndDate!.isBefore(date)) {
                                        tempEndDate = null;
                                      }
                                    });
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey[300]!),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                                      const SizedBox(width: 8),
                                      Text(
                                        tempStartDate != null
                                            ? DateFormat('MMM dd, yyyy').format(tempStartDate!)
                                            : 'Select start date',
                                        style: TextStyle(
                                          color: tempStartDate != null ? Colors.black : Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'End Date',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              InkWell(
                                onTap: () async {
                                  final date = await showDatePicker(
                                    context: context,
                                    initialDate: tempEndDate ?? tempStartDate ?? DateTime.now(),
                                    firstDate: tempStartDate ?? DateTime(2020),
                                    lastDate: DateTime.now().add(const Duration(days: 365)),
                                  );
                                  if (date != null) {
                                    setDialogState(() {
                                      tempEndDate = date;
                                    });
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey[300]!),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                                      const SizedBox(width: 8),
                                      Text(
                                        tempEndDate != null
                                            ? DateFormat('MMM dd, yyyy').format(tempEndDate!)
                                            : 'Select end date',
                                        style: TextStyle(
                                          color: tempEndDate != null ? Colors.black : Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Quick date range buttons
                    const Text(
                      'Quick Select:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        _buildQuickDateButton(
                          'Today',
                          () {
                            final today = DateTime.now();
                            setDialogState(() {
                              tempStartDate = DateTime(today.year, today.month, today.day);
                              tempEndDate = DateTime(today.year, today.month, today.day, 23, 59, 59);
                            });
                          },
                        ),
                        _buildQuickDateButton(
                          'This Week',
                          () {
                            final now = DateTime.now();
                            final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
                            setDialogState(() {
                              tempStartDate = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
                              tempEndDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
                            });
                          },
                        ),
                        _buildQuickDateButton(
                          'This Month',
                          () {
                            final now = DateTime.now();
                            setDialogState(() {
                              tempStartDate = DateTime(now.year, now.month, 1);
                              tempEndDate = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
                            });
                          },
                        ),
                      ],
                    ),
                    
                    if (tempStartDate != null || tempEndDate != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.blue[700], size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'This will filter trips based on their accepted time and end time.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue[700],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text('Cancel'),
                ),
                if (tempStartDate != null || tempEndDate != null)
                  TextButton(
                    onPressed: () {
                      setDialogState(() {
                        tempStartDate = null;
                        tempEndDate = null;
                      });
                    },
                    child: const Text('Clear'),
                  ),
                FilledButton(
                  onPressed: () {
                    setState(() {
                      _startDate = tempStartDate;
                      _endDate = tempEndDate;
                    });
                    
                    // Notify parent widget
                    if (widget.onDateRangeChanged != null) {
                      widget.onDateRangeChanged!(_startDate, _endDate);
                    }
                    
                    // Trigger BLoC event if both dates are selected
                    if (_startDate != null && _endDate != null) {
                      context.read<TripBloc>().add(
                        FilterTripsByDateRangeEvent(
                          startDate: _startDate!,
                          endDate: _endDate!,
                        ),
                      );
                    }
                    
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text('Apply Filter'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildQuickDateButton(String label, VoidCallback onPressed) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasDateRange = _startDate != null || _endDate != null;
    
    return GestureDetector(
      key: _filterKey,
      onTap: _showDateRangeDialog,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: hasDateRange
              ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasDateRange
                ? Theme.of(context).colorScheme.primary
                : Colors.grey.withOpacity(0.5),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.date_range,
              size: 16,
              color: hasDateRange
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey[600],
            ),
            const SizedBox(width: 4),
            Text(
              hasDateRange ? 'Date Range' : 'Filter by Date',
              style: TextStyle(
                fontWeight: hasDateRange ? FontWeight.bold : FontWeight.normal,
                color: hasDateRange
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey[700],
                fontSize: 14,
              ),
            ),
            if (hasDateRange) ...[
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '1',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down,
              size: 16,
              color: hasDateRange
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey[600],
            ),
          ],
        ),
      ),
    );
  }
}
