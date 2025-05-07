import 'package:flutter/material.dart';
import 'package:xpro_delivery_admin_app/core/common/widgets/create_screen_widgets/form_buttons.dart';

class UserFormButtons extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback onSave;
  final VoidCallback onSaveAndCreateAnother;
  final bool isLoading;

  const UserFormButtons({
    super.key,
    required this.onCancel,
    required this.onSave,
    required this.onSaveAndCreateAnother,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Cancel button
        FormCancelButton(
          onPressed: onCancel,
          label: 'Cancel',
        ),
        const SizedBox(width: 16),
        
        // Save and create another button
        OutlinedButton.icon(
          onPressed: isLoading ? null : onSaveAndCreateAnother,
          icon: const Icon(Icons.add),
          label: const Text('Save & Create Another'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            side: BorderSide(color: Theme.of(context).colorScheme.primary),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const SizedBox(width: 16),
        
        // Save button
        FormSubmitButton(
          label: 'Save User',
          onPressed: isLoading ? () {} : onSave,
          isLoading: isLoading,
          icon: Icons.save,
        ),
      ],
    );
  }
}
