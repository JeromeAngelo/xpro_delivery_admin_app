import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

import 'package:xpro_delivery_admin_app/core/common/app/features/place_lookups/province/domain/entity/province_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/place_lookups/region/domain/entity/region_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/widgets/create_screen_widgets/app_drop_down_fields.dart';
import 'package:xpro_delivery_admin_app/core/common/widgets/create_screen_widgets/app_textfield.dart';
import 'package:xpro_delivery_admin_app/core/common/widgets/create_screen_widgets/form_title.dart';
import 'package:xpro_delivery_admin_app/core/enums/vehicle_status.dart';

import 'attachments_picker.dart';

class VehicleProfileForm extends StatefulWidget {
  // Text controllers (parent-owned).
  final TextEditingController yearModelController;
  final TextEditingController designatedMunicipalityController;
  final TextEditingController remarksController;

  // Value + change callbacks.
  final VehicleStatus status;
  final ValueChanged<VehicleStatus> onStatusChanged;
  final List<XFile> attachments;
  final ValueChanged<List<XFile>> onAttachmentsChanged;

  // ---------------- Multi-select Region / Province data ----------------
  /// All regions available to the user. The dropdown is rendered
  /// from this list.
  final List<RegionEntity> regions;

  /// Regions currently selected by the user. `AppDropdownField`
  /// renders these as removable chips beneath the dropdown.
  final List<RegionEntity> selectedRegions;

  /// Called whenever the user adds or removes a region from the
  /// selection. The parent receives the new (complete) list.
  final ValueChanged<List<RegionEntity>>? onSelectedRegionsChanged;

  /// All provinces available to the user across the selected
  /// region(s). The parent is responsible for loading these in
  /// response to region selections.
  final List<ProvinceEntity> provinces;

  /// Provinces currently selected by the user. `AppDropdownField`
  /// renders these as removable chips beneath the dropdown.
  final List<ProvinceEntity> selectedProvinces;

  /// Called whenever the user adds or removes a province.
  final ValueChanged<List<ProvinceEntity>>? onSelectedProvincesChanged;

  /// When false, the region / province dropdowns are non-interactive.
  final bool enabled;

  const VehicleProfileForm({
    super.key,
    required this.yearModelController,
    required this.designatedMunicipalityController,
    required this.remarksController,
    required this.status,
    required this.onStatusChanged,
    required this.attachments,
    required this.onAttachmentsChanged,
    this.regions = const [],
    this.selectedRegions = const [],
    this.onSelectedRegionsChanged,
    this.provinces = const [],
    this.selectedProvinces = const [],
    this.onSelectedProvincesChanged,
    this.enabled = true,
  });

  @override
  State<VehicleProfileForm> createState() => _VehicleProfileFormState();
}

class _VehicleProfileFormState extends State<VehicleProfileForm> {
  /// The dropdown's `value` field must not be null while the user
  /// has a selection, so we surface the first selected region /
  /// province as the displayed value.
  RegionEntity? get _displayedRegion =>
      widget.selectedRegions.isNotEmpty ? widget.selectedRegions.first : null;

  ProvinceEntity? get _displayedProvince =>
      widget.selectedProvinces.isNotEmpty
          ? widget.selectedProvinces.first
          : null;

  /// Render a region as "name - alias" (e.g.
  /// "Region III - Central Luzon"). Falls back to just the name
  /// when no alias is available.
  static String _formatRegion(RegionEntity? region) {
    if (region == null) return '';
    final name = (region.name ?? '').trim();
    final alias = (region.alias ?? '').trim();
    if (alias.isEmpty) return name;
    return '$name - $alias';
  }

  /// Called by the dropdown's `onChanged` whenever the user picks
  /// a region from the list. We toggle the region in the selection
  /// and notify the parent via `onSelectedRegionsChanged`.
  void _onRegionToggled(RegionEntity? region) {
    if (region == null) return;
    final current = List<RegionEntity>.from(widget.selectedRegions);
    final existingIndex = current.indexWhere(
      (r) => (r.id ?? '') == (region.id ?? ''),
    );
    if (existingIndex >= 0) {
      current.removeAt(existingIndex);
    } else {
      current.add(region);
    }
    widget.onSelectedRegionsChanged?.call(current);
  }

  /// Called by the dropdown's `onChanged` whenever the user picks
  /// a province from the list.
  void _onProvinceToggled(ProvinceEntity? province) {
    if (province == null) return;
    final current = List<ProvinceEntity>.from(widget.selectedProvinces);
    final existingIndex = current.indexWhere(
      (p) => (p.id ?? '') == (province.id ?? ''),
    );
    if (existingIndex >= 0) {
      current.removeAt(existingIndex);
    } else {
      current.add(province);
    }
    widget.onSelectedProvincesChanged?.call(current);
  }

  /// Called by the dropdown's chip delete button. The dropdown
  /// already builds the updated list (with the deleted item
  /// removed) — we just forward it to the parent.
  void _onSelectedRegionsRemovedFromChip(List<RegionEntity> updated) {
    widget.onSelectedRegionsChanged?.call(updated);
  }

  void _onSelectedProvincesRemovedFromChip(List<ProvinceEntity> updated) {
    widget.onSelectedProvincesChanged?.call(updated);
  }

  @override
  Widget build(BuildContext context) {
    final hasRegions = widget.selectedRegions.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FormSectionTitle(title: 'Vehicle Profile'),
        AppTextField(
          label: 'Year Model',
          controller: widget.yearModelController,
          hintText: 'e.g. 2024',
          enabled: widget.enabled,
        ),

        // ---------------- Region dropdown (multi-select) ----------------
        // `AppDropdownField` already renders the selected items as
        // removable chips beneath the dropdown when both
        // `selectedItems` and `onSelectedItemsChanged` are passed
        // in. The dropdown uses two callbacks:
        //   * `onChanged` — fires when the user PICKS an item from
        //     the dropdown list. We use this to toggle the item in
        //     the parent's selection.
        //   * `onSelectedItemsChanged` — fires when the user clicks
        //     the X on one of the chips beneath the dropdown. The
        //     dropdown already builds the updated list for us; we
        //     forward it to the parent.
        AppDropdownField<RegionEntity>(
          label: 'Designated Region(s)',
          value: _displayedRegion,
          items:
              widget.regions
                  .map(
                    (r) => DropdownItem<RegionEntity>(
                      value: r,
                      label: _formatRegion(r),
                      uniqueId: r.id ?? r.name ?? '',
                    ),
                  )
                  .toList(),
          onChanged: widget.enabled ? _onRegionToggled : (_) {},
          hintText:
              widget.regions.isEmpty ? 'Loading regions…' : 'Select region(s)',
          enabled: widget.enabled,
          selectedItems: widget.selectedRegions,
          onSelectedItemsChanged:
              widget.enabled ? _onSelectedRegionsRemovedFromChip : null,
        ),

        const SizedBox(height: 16),

        // ---------------- Province dropdown (multi-select) ----------------
        AppDropdownField<ProvinceEntity>(
          label: 'Designated Province(s)',
          value: _displayedProvince,
          items:
              widget.provinces
                  .map(
                    (p) => DropdownItem<ProvinceEntity>(
                      value: p,
                      label: p.name ?? '',
                      uniqueId: p.id ?? p.name ?? '',
                    ),
                  )
                  .toList(),
          onChanged:
              (widget.enabled && hasRegions) ? _onProvinceToggled : (_) {},
          hintText:
              !hasRegions
                  ? 'Select a region first'
                  : (widget.provinces.isEmpty
                      ? 'Loading provinces…'
                      : 'Select province(s)'),
          enabled: widget.enabled && hasRegions,
          selectedItems: widget.selectedProvinces,
          onSelectedItemsChanged:
              (widget.enabled && hasRegions)
                  ? _onSelectedProvincesRemovedFromChip
                  : null,
        ),

        const SizedBox(height: 16),

        AppTextField(
          label: 'Designated Municipality',
          controller: widget.designatedMunicipalityController,
          hintText: 'e.g. San Fernando',
          enabled: widget.enabled,
        ),
        AppDropdownField<VehicleStatus>(
          label: 'Status',
          value: widget.status,
          items:
              VehicleStatus.values
                  .map(
                    (s) => DropdownItem<VehicleStatus>(
                      value: s,
                      label: _statusLabel(s),
                      uniqueId: s.name,
                    ),
                  )
                  .toList(),
          onChanged:
              widget.enabled
                  ? (v) {
                    if (v != null) widget.onStatusChanged(v);
                  }
                  : (_) {},
          enabled: widget.enabled,
        ),
        AppTextField(
          label: 'Remarks',
          controller: widget.remarksController,
          hintText: 'Optional notes about this vehicle',
          maxLines: 3,
          minLines: 2,
          enabled: widget.enabled,
        ),
        AttachmentsPicker(
          attachments: widget.attachments,
          onAttachmentsChanged: widget.onAttachmentsChanged,
          helperText:
              'Supported: images, PDF, Word, Excel. Files are uploaded with the profile.',
        ),
      ],
    );
  }

  String _statusLabel(VehicleStatus status) {
    switch (status) {
      case VehicleStatus.goodCondition:
        return 'Good Condition';
      case VehicleStatus.underMaintenance:
        return 'Under Maintenance';
      case VehicleStatus.inspectionRequired:
        return 'Inspection Required';
      case VehicleStatus.outOfService:
        return 'Out of Service';
      case VehicleStatus.retired:
        return 'Retired';
    }
  }
}
