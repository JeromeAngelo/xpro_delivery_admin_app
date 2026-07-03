import 'package:flutter/material.dart';

import 'package:xpro_delivery_admin_app/core/common/app/features/vehicle/vehicle_tags/domain/entity/vehicle_tag_entity.dart';
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

  // Status value (parent-owned, nullable).
  final VehicleStatus? status;

  // Change callbacks. Mirrors the `AppNumberField.onChanged` contract
  // (`num?`) so callers can either pass `(v) => _x = v?.toDouble()` or
  // `(v) => _x = v` (int or double).
  final ValueChanged<num?>? onVolumeCapacityChanged;
  final ValueChanged<num?>? onWeightCapacityChanged;
  final ValueChanged<VehicleStatus?>? onStatusChanged;

  // Vehicle tag multi-select data.
  final List<VehicleTagEntity> vehicleTags;
  final List<VehicleTagEntity> selectedVehicleTags;
  final ValueChanged<List<VehicleTagEntity>>? onSelectedVehicleTagsChanged;

  const VehicleDataForm({
    super.key,
    required this.nameController,
    required this.makeController,
    required this.typeController,
    required this.wheelsController,
    required this.volumeCapacity,
    required this.weightCapacity,
    this.status,
    this.onVolumeCapacityChanged,
    this.onWeightCapacityChanged,
    this.onStatusChanged,
    this.vehicleTags = const [],
    this.selectedVehicleTags = const [],
    this.onSelectedVehicleTagsChanged,
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

  VehicleStatus? get _selectedStatus => widget.status;

  VehicleTagEntity? get _displayedVehicleTag =>
      widget.selectedVehicleTags.isNotEmpty
          ? widget.selectedVehicleTags.first
          : null;

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

  void _onStatusChanged(VehicleStatus? status) {
    widget.onStatusChanged?.call(status);
    setState(() {});
  }

  void _onVehicleTagToggled(VehicleTagEntity? tag) {
    if (tag == null) return;
    final current = List<VehicleTagEntity>.from(widget.selectedVehicleTags);
    final existingIndex = current.indexWhere(
      (t) => (t.id ?? '') == (tag.id ?? ''),
    );
    if (existingIndex >= 0) {
      current.removeAt(existingIndex);
    } else {
      current.add(tag);
    }
    widget.onSelectedVehicleTagsChanged?.call(current);
  }

  void _onSelectedVehicleTagsRemovedFromChip(List<VehicleTagEntity> updated) {
    widget.onSelectedVehicleTagsChanged?.call(updated);
  }

  static String _formatStatusLabel(String name) {
    return name
        .replaceAllMapped(RegExp(r'([a-z])([A-Z])'), (m) => '${m[1]} ${m[2]}')
        .split(' ')
        .map(
          (word) =>
              word.isEmpty
                  ? word
                  : word[0].toUpperCase() + word.substring(1).toLowerCase(),
        )
        .join(' ');
  }

  static String _formatVehicleTag(VehicleTagEntity? tag) {
    if (tag == null) return '';
    final label = (tag.label ?? '').trim();
    final types = tag.types?.map((t) => t.name).join(', ') ?? '';
    if (label.isEmpty) return types;
    if (types.isEmpty) return label;
    return '$label ($types)';
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
        AppDropdownField<VehicleStatus>(
          label: 'Condition / Status',
          value: _selectedStatus,
          items:
              VehicleStatus.values
                  .map(
                    (s) => DropdownItem<VehicleStatus>(
                      value: s,
                      label: _formatStatusLabel(s.name),
                      uniqueId: s.name,
                    ),
                  )
                  .toList(),
          onChanged: _onStatusChanged,
          hintText: 'Select condition',
        ),
        AppDropdownField<VehicleTagEntity>(
          label: 'Vehicle Tag(s)',
          value: _displayedVehicleTag,
          items:
              widget.vehicleTags
                  .map(
                    (tag) => DropdownItem<VehicleTagEntity>(
                      value: tag,
                      label: _formatVehicleTag(tag),
                      uniqueId: tag.id ?? tag.label ?? '',
                    ),
                  )
                  .toList(),
          onChanged: _onVehicleTagToggled,
          hintText:
              widget.vehicleTags.isEmpty ? 'Loading tags…' : 'Select tag(s)',
          enabled: widget.onSelectedVehicleTagsChanged != null,
          selectedItems: widget.selectedVehicleTags,
          onSelectedItemsChanged:
              widget.onSelectedVehicleTagsChanged != null
                  ? _onSelectedVehicleTagsRemovedFromChip
                  : null,
        ),
      ],
    );
  }
}
