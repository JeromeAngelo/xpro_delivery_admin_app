import 'package:desktop_app/core/common/widgets/create_screen_widgets/app_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppNumberField extends StatelessWidget {
  final String label;
  final String? hintText;
  final num? initialValue;
  final void Function(num?) onChanged;
  final String? Function(num?)? validator;
  final bool required;
  final String? helperText;
  final bool enabled;
  final bool allowDecimal;
  final num? min;
  final num? max;

  const AppNumberField({
    super.key,
    required this.label,
    this.hintText,
    this.initialValue,
    required this.onChanged,
    this.validator,
    this.required = false,
    this.helperText,
    this.enabled = true,
    this.allowDecimal = false,
    this.min,
    this.max,
  });

  @override
  Widget build(BuildContext context) {
    final TextEditingController controller = TextEditingController(
      text: initialValue?.toString() ?? '',
    );

    return AppTextField(
      label: label,
      hintText: hintText,
      controller: controller,
      keyboardType: TextInputType.numberWithOptions(
        decimal: allowDecimal,
        signed: min == null || min! < 0,
      ),
      required: required,
      helperText: helperText,
      enabled: enabled,
      inputFormatters: [
        if (!allowDecimal) FilteringTextInputFormatter.digitsOnly,
        if (allowDecimal)
          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
      ],
      onChanged: (value) {
        if (value.isEmpty) {
          onChanged(null);
          return;
        }
        
        num? parsedValue;
        if (allowDecimal) {
          parsedValue = double.tryParse(value);
        } else {
          parsedValue = int.tryParse(value);
        }
        
        if (parsedValue != null) {
          if (min != null && parsedValue < min!) {
            parsedValue = min;
            controller.text = min.toString();
          }
          if (max != null && parsedValue! > max!) {
            parsedValue = max;
            controller.text = max.toString();
          }
        }
        
        onChanged(parsedValue);
      },
      validator: (value) {
        if (validator != null) {
          num? parsedValue;
          if (value != null && value.isNotEmpty) {
            parsedValue = allowDecimal
                ? double.tryParse(value)
                : int.tryParse(value);
          }
          return validator!(parsedValue);
        }
        
        if (required && (value == null || value.isEmpty)) {
          return 'This field is required';
        }
        
        if (value != null && value.isNotEmpty) {
          final num? parsedValue = allowDecimal
              ? double.tryParse(value)
              : int.tryParse(value);
          
          if (parsedValue == null) {
            return 'Please enter a valid number';
          }
          
          if (min != null && parsedValue < min!) {
            return 'Value must be at least $min';
          }
          
          if (max != null && parsedValue > max!) {
            return 'Value must be at most $max';
          }
        }
        
        return null;
      },
    );
  }
}
