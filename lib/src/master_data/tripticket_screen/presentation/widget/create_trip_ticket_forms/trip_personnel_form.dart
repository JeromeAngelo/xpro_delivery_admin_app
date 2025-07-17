import 'package:xpro_delivery_admin_app/core/common/widgets/create_screen_widgets/app_textfield.dart';
import 'package:xpro_delivery_admin_app/core/common/widgets/create_screen_widgets/form_title.dart';
import 'package:flutter/material.dart';

import 'package:xpro_delivery_admin_app/core/common/app/features/Delivery_Team/personels/data/models/personel_models.dart';
import 'personnel_selection_dialog.dart';

class PersonnelForm extends StatelessWidget {
  final List<PersonelModel> availablePersonnel;
  final List<PersonelModel> selectedPersonnel;
  final Function(List<PersonelModel>) onPersonnelChanged;

  const PersonnelForm({
    super.key,
    required this.availablePersonnel,
    required this.selectedPersonnel,
    required this.onPersonnelChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FormSectionTitle(title: 'Assign Personnel'),

        // Personnel dropdown
        _buildPersonnelDropdown(context),
      ],
    );
  }

  void _showPersonnelSelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => PersonnelSelectionDialog(
        availablePersonnel: availablePersonnel,
        selectedPersonnel: selectedPersonnel,
        onPersonnelChanged: onPersonnelChanged,
      ),
    );
  }

  Widget _buildPersonnelDropdown(BuildContext context) {
    if (availablePersonnel.isEmpty) {
      return const AppTextField(
        label: 'Personnel',
        initialValue: 'No Personnel',
        readOnly: true,
        helperText: 'No personnel available to select',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Personnel selection button
        SizedBox(
          width: 755,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Personnel label
              SizedBox(
                width: 200,
                child: Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: RichText(
                    text: TextSpan(
                      text: 'Personnel',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
              ),

              // Custom dropdown button that shows dialog
              Expanded(
                child: InkWell(
                  onTap: () => _showPersonnelSelectionDialog(context),
                  child: Container(
                    height: 56,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          selectedPersonnel.isEmpty
                              ? 'Select Personnel'
                              : '${selectedPersonnel.length} personnel selected',
                          style: TextStyle(
                            color: selectedPersonnel.isEmpty
                                ? Colors.grey
                                : Colors.black,
                          ),
                        ),
                        Icon(
                          Icons.arrow_drop_down,
                          color: Colors.grey.shade600,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Display selected personnel
        if (selectedPersonnel.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Selected Personnel:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: selectedPersonnel.map((personnel) {
                    final assignmentStatus =
                        (personnel.isAssigned ?? false) ? 'Trip Assigned' : 'Available';
                    final statusColor =
                        (personnel.isAssigned ?? false) ? Colors.orange : Colors.green;

                    return Chip(
                      avatar: Icon(
                        (personnel.isAssigned ?? false)
                            ? Icons.assignment_turned_in
                            : Icons.person_outline,
                        size: 16,
                        color: statusColor,
                      ),
                      label: Text(
                        '${personnel.name} (${personnel.role?.name ?? 'Unknown'}) - $assignmentStatus',
                        style: const TextStyle(fontSize: 12),
                      ),
                      deleteIcon: const Icon(Icons.close, size: 16),
                      onDeleted: () {
                        final updatedList = List<PersonelModel>.from(selectedPersonnel);
                        updatedList.remove(personnel);
                        onPersonnelChanged(updatedList);
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

        // Helper text
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            'Select delivery personnel for this trip. 🟢 Available | 🟠 Trip Assigned',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ),
      ],
    );
  }
}
