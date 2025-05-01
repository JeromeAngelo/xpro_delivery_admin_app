import 'package:xpro_delivery_admin_app/core/common/widgets/create_screen_widgets/app_drop_down_fields.dart';
import 'package:xpro_delivery_admin_app/core/common/widgets/create_screen_widgets/app_textfield.dart';
import 'package:xpro_delivery_admin_app/core/common/widgets/create_screen_widgets/form_title.dart';
import 'package:flutter/material.dart';

import 'package:xpro_delivery_admin_app/core/common/app/features/Delivery_Team/personels/data/models/personel_models.dart';

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

  Widget _buildPersonnelDropdown(BuildContext context) {
    if (availablePersonnel.isEmpty) {
      return const AppTextField(
        label: 'Personnel',
        initialValue: 'No Personnel',
        readOnly: true,
        helperText: 'No personnel available to select',
      );
    }

    // Convert personnel to dropdown items
    final personnelItems =
        availablePersonnel.map((personnel) {
          return DropdownItem<PersonelModel>(
            value: personnel,
            label: personnel.name ?? 'Personnel ${personnel.id}',
            icon: const Icon(Icons.person, size: 16),
            uniqueId: personnel.id ?? 'personnel_${personnel.hashCode}',
          );
        }).toList();

    return AppDropdownField<PersonelModel>(
      label: 'Personnel',
      hintText: 'Select Personnel',
      items: personnelItems,
      onChanged: (value) {
        if (value != null && !selectedPersonnel.contains(value)) {
          final updatedList = List<PersonelModel>.from(selectedPersonnel);
          updatedList.add(value);
          onPersonnelChanged(updatedList);
        }
      },
      //   helperText: 'Select delivery personnel for this trip',
      selectedItems: selectedPersonnel,
      onSelectedItemsChanged: onPersonnelChanged,
    );
  }
}
