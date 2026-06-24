import 'package:flutter/material.dart';
import 'package:xpro_delivery_admin_app/core/common/widgets/create_screen_widgets/app_drop_down_fields.dart';
import 'package:xpro_delivery_admin_app/core/common/widgets/create_screen_widgets/app_textfield.dart';
import 'package:xpro_delivery_admin_app/core/common/widgets/create_screen_widgets/form_title.dart';
import 'package:xpro_delivery_admin_app/core/enums/vehicle_tags_enums.dart';

class VehicleTagDataForm extends StatefulWidget {
  final TextEditingController labelController;
  final TextEditingController descriptionController;
  final TextEditingController stickerNumberController;
  final DateTime? expiration;
  final ValueChanged<DateTime?> onExpirationChanged;
  final List<VehicleTagType> selectedTypes;
  final ValueChanged<List<VehicleTagType>> onSelectedTypesChanged;

  const VehicleTagDataForm({
    super.key,
    required this.labelController,
    required this.descriptionController,
    required this.stickerNumberController,
    required this.expiration,
    required this.onExpirationChanged,
    required this.selectedTypes,
    required this.onSelectedTypesChanged,
  });

  @override
  State<VehicleTagDataForm> createState() => _VehicleTagDataFormState();
}

class _VehicleTagDataFormState extends State<VehicleTagDataForm> {
  VehicleTagType? get _displayedType =>
      widget.selectedTypes.isNotEmpty ? widget.selectedTypes.first : null;

  void _onTypeToggled(VehicleTagType? type) {
    if (type == null) return;
    final current = List<VehicleTagType>.from(widget.selectedTypes);
    if (current.contains(type)) {
      current.remove(type);
    } else {
      current.add(type);
    }
    widget.onSelectedTypesChanged(current);
  }

  void _onSelectedTypesRemovedFromChip(List<VehicleTagType> updated) {
    widget.onSelectedTypesChanged(updated);
  }

  Future<void> _pickExpiration() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: widget.expiration ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      widget.onExpirationChanged(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FormSectionTitle(title: 'Vehicle Tag Data'),
        AppTextField(
          label: 'Label',
          controller: widget.labelController,
          required: true,
          hintText: 'e.g. Franchise Sticker',
          validator: (v) {
            if (v == null || v.trim().isEmpty) {
              return 'Label is required';
            }
            return null;
          },
        ),
        AppTextField(
          label: 'Description',
          controller: widget.descriptionController,
          hintText: 'e.g. Annual franchise permit sticker',
          maxLines: 3,
        ),
        AppDropdownField<VehicleTagType>(
          label: 'Tag Type(s)',
          value: _displayedType,
          items:
              VehicleTagType.values
                  .map(
                    (type) => DropdownItem<VehicleTagType>(
                      value: type,
                      label: _labelForType(type),
                      uniqueId: type.name,
                    ),
                  )
                  .toList(),
          onChanged: _onTypeToggled,
          hintText: 'Select tag type(s)',
          selectedItems: widget.selectedTypes,
          onSelectedItemsChanged: _onSelectedTypesRemovedFromChip,
        ),
        AppTextField(
          label: 'Sticker Number',
          controller: widget.stickerNumberController,
          hintText: 'e.g. STK-2026-001',
        ),
        AppTextField(
          label: 'Expiration Date',
          controller: TextEditingController(
            text:
                widget.expiration != null
                    ? _formatDate(widget.expiration!)
                    : '',
          ),
          readOnly: true,
          onTap: _pickExpiration,
          suffix: IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _pickExpiration,
          ),
          hintText: 'Tap to select expiration date',
        ),
      ],
    );
  }

  String _labelForType(VehicleTagType type) {
    switch (type) {
      case VehicleTagType.sticker:
        return 'Sticker';
      case VehicleTagType.restriction:
        return 'Restriction';
      case VehicleTagType.permit:
        return 'Permit';
      case VehicleTagType.other:
        return 'Other';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
