import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TripDeliveryDateForm extends StatelessWidget {
  const TripDeliveryDateForm({
    super.key,
    required this.deliveryDate,
    required this.expectedReturnDate,
    required this.onDeliveryDateChanged,
    required this.onDeliveryDateCleared,
    required this.onExpectedReturnDateChanged,
    required this.onExpectedReturnDateCleared,
  });

  final DateTime? deliveryDate;
  final DateTime? expectedReturnDate;
  final ValueChanged<DateTime> onDeliveryDateChanged;
  final VoidCallback onDeliveryDateCleared;
  final ValueChanged<DateTime> onExpectedReturnDateChanged;
  final VoidCallback onExpectedReturnDateCleared;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _DatePickerField(
              label: 'Delivery Date',
              date: deliveryDate,
              onPickDate: onDeliveryDateChanged,
              onClear: onDeliveryDateCleared,
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: _DatePickerField(
              label: 'Expected Return Date',
              date: expectedReturnDate,
              onPickDate: onExpectedReturnDateChanged,
              onClear: onExpectedReturnDateCleared,
            ),
          ),
        ],
      ),
    );
  }
}

class _DatePickerField extends StatelessWidget {
  const _DatePickerField({
    required this.label,
    required this.date,
    required this.onPickDate,
    required this.onClear,
  });

  final String label;
  final DateTime? date;
  final ValueChanged<DateTime> onPickDate;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
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
                onTap: () async {
                  final DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: date ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2050),
                  );
                  if (pickedDate != null) {
                    onPickDate(pickedDate);
                  }
                },
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
                          ? DateFormat('MM/dd/yyyy').format(date!)
                          : 'Select $label',
                      style: TextStyle(
                        fontSize: 16,
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
