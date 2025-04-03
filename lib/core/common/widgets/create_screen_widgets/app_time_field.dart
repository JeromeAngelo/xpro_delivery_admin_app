import 'package:desktop_app/core/common/widgets/create_screen_widgets/app_textfield.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppTimeField extends StatelessWidget {
  final String label;
  final TimeOfDay? initialValue;
  final void Function(TimeOfDay?) onChanged;
  final String? Function(TimeOfDay?)? validator;
  final bool required;
  final String? helperText;
  final bool enabled;

  const AppTimeField({
    super.key,
    required this.label,
    this.initialValue,
    required this.onChanged,
    this.validator,
    this.required = false,
    this.helperText,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final TextEditingController controller = TextEditingController(
      text: initialValue != null
          ? _formatTimeOfDay(initialValue!)
          : '',
    );

    return AppTextField(
      label: label,
      controller: controller,
      readOnly: true,
      required: required,
      helperText: helperText,
      enabled: enabled,
      suffix: const Icon(Icons.access_time),
      onTap: enabled
          ? () async {
              final TimeOfDay? picked = await showTimePicker(
                context: context,
                initialTime: initialValue ?? TimeOfDay.now(),
              );
              if (picked != null) {
                controller.text = _formatTimeOfDay(picked);
                onChanged(picked);
              }
            }
          : null,
      validator: (value) {
        if (validator != null) {
          return validator!(initialValue);
        }
        if (required && (value == null || value.isEmpty)) {
          return 'This field is required';
        }
        return null;
      },
    );
  }

  String _formatTimeOfDay(TimeOfDay timeOfDay) {
    final now = DateTime.now();
    final dt = DateTime(
      now.year,
      now.month,
      now.day,
      timeOfDay.hour,
      timeOfDay.minute,
    );
    return DateFormat('h:mm a').format(dt);
  }
}
