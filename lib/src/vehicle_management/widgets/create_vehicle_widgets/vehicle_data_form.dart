import 'package:flutter/material.dart';

import 'package:xpro_delivery_admin_app/core/common/widgets/create_screen_widgets/app_drop_down_fields.dart';
import 'package:xpro_delivery_admin_app/core/common/widgets/create_screen_widgets/app_number_field.dart';
import 'package:xpro_delivery_admin_app/core/common/widgets/create_screen_widgets/app_textfield.dart';
import 'package:xpro_delivery_admin_app/core/common/widgets/create_screen_widgets/form_title.dart';
import 'package:xpro_delivery_admin_app/core/enums/vehicle_status.dart';


class VehicleDataForm extends StatefulWidget {
  // Text controllers (parent-owned).
  final TextEditingController nameController;
  final TextEditingController makeController;
  final TextEditingController typeController;
  final TextEditingController wheelsController;

  // Numeric values (parent-owned, nullable).
  final double? volumeCapacity;
  final double? weightCapacity;

  // Change callbacks. Mirrors the `AppNumberField.onChanged` contract
  // (`num?`) so callers can either pass `(v) => _x = v?.toDouble()` or
  // `(v) => _x = v` (int or double).
  final ValueChanged<num?>? onVolumeCapacityChanged;
  final ValueChanged<num?>? onWeightCapacityChanged;

  const VehicleDataForm({
    super.key,
    required this.nameController,
    required this.makeController,
    required this.typeController,
    required this.wheelsController,
    required this.volumeCapacity,
    required this.weightCapacity,
    this.onVolumeCapacityChanged,
    this.onWeightCapacityChanged,
  });

  @override
  State<VehicleDataForm> createState() => _VehicleDataFormState();
}

class _VehicleDataFormState extends State<VehicleDataForm> {
  /// Case-insensitive match for the `Make` enum against the value
  /// currently in the controller. Used so the dropdown can re-hydrate
  /// its selection from any pre-populated value (e.g. a value
  /// previously read back from PocketBase).
  Make? get _selectedMake {
    final raw = widget.makeController.text.trim();
    if (raw.isEmpty) return null;
    for (final m in Make.values) {
      if (m.name.toLowerCase() == raw.toLowerCase() ||
          m.label.toLowerCase() == raw.toLowerCase()) {
        return m;
      }
    }
    return null;
  }

  VehicleType? get _selectedType {
    final raw = widget.typeController.text.trim();
    if (raw.isEmpty) return null;
    for (final t in VehicleType.values) {
      if (t.name.toLowerCase() == raw.toLowerCase() ||
          t.label.toLowerCase() == raw.toLowerCase()) {
        return t;
      }
    }
    return null;
  }

  /// Persist the chosen enum value to the parent controller in
  /// ALL CAPS so what the user sees in the dropdown is the source
  /// of truth for what's stored in PocketBase.
  void _writeAllCaps(TextEditingController controller, String label) {
    controller.text = label.toUpperCase();
  }

  void _onMakeChanged(Make? make) {
    _writeAllCaps(widget.makeController, make?.label ?? '');
    setState(() {});
  }

  void _onTypeChanged(VehicleType? type) {
    _writeAllCaps(widget.typeController, type?.label ?? '');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FormSectionTitle(title: 'Vehicle Data'),
        AppTextField(
          label: 'Plate Number',
          controller: widget.nameController,
          required: true,
          hintText: 'e.g. Delivery Truck 1',
          validator: (v) {
            if (v == null || v.trim().isEmpty) {
              return 'Plate Number is required';
            }
            return null;
          },
        ),
        
        AppDropdownField<Make>(
          label: 'Make',
          value: _selectedMake,
          items:
              Make.values
                  .map(
                    (m) => DropdownItem<Make>(
                      value: m,
                      label: m.label,
                      uniqueId: m.name,
                    ),
                  )
                  .toList(),
          onChanged: _onMakeChanged,
          hintText: 'Select make',
        ),
        AppDropdownField<VehicleType>(
          label: 'Type',
          value: _selectedType,
          items:
              VehicleType.values
                  .map(
                    (t) => DropdownItem<VehicleType>(
                      value: t,
                      label: t.label,
                      uniqueId: t.name,
                    ),
                  )
                  .toList(),
          onChanged: _onTypeChanged,
          hintText: 'Select type',
        ),
        AppTextField(
          label: 'Wheels',
          controller: widget.wheelsController,
          hintText: 'e.g. 4',
        ),
        AppNumberField(
          label: 'Volume Capacity (m³)',
          allowDecimal: true,
          min: 0,
          initialValue: widget.volumeCapacity,
          onChanged: widget.onVolumeCapacityChanged ?? (_) {},
          hintText: 'e.g. 12.5',
        ),
        AppNumberField(
          label: 'Weight Capacity (kg)',
          allowDecimal: true,
          min: 0,
          initialValue: widget.weightCapacity,
          onChanged: widget.onWeightCapacityChanged ?? (_) {},
          hintText: 'e.g. 1500',
        ),
      ],
    );
  }
}
