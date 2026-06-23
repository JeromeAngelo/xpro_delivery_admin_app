import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

import 'package:xpro_delivery_admin_app/core/common/app/features/place_lookups/province/domain/entity/province_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/place_lookups/region/domain/entity/region_entity.dart';
import 'package:xpro_delivery_admin_app/core/enums/vehicle_status.dart';

import '../create_vehicle_widgets/vehicle_data_form.dart';
import '../create_vehicle_widgets/vehicle_profile_form.dart';
import 'update_vehicle_error_banner.dart';

/// The "Update Vehicle" form body.
///
/// Renders the two `create_vehicle_widgets` sub-forms
/// (`VehicleDataForm` + `VehicleProfileForm`) and an optional
/// [UpdateVehicleErrorBanner] beneath them. The widget is fully
/// controlled — the parent (`UpdateVehicleView`) owns all
/// controllers, the status, the attachments list, the error
/// message string, and the lists of selected regions/provinces.
///
/// Region / Province data is sourced dynamically from the
/// Region / Province blocs (see the [regions], [selectedRegions],
/// [provinces] and [selectedProvinces] parameters). Both dropdowns
/// support multi-select; chips of selected items are rendered
/// beneath each dropdown by the inner [VehicleProfileForm].
class UpdateVehicleForm extends StatelessWidget {
  // ---------------- Vehicle Data controllers + values ----------------
  final TextEditingController nameController;
  final TextEditingController plateNoController;
  final TextEditingController makeController;
  final TextEditingController typeController;
  final TextEditingController wheelsController;
  final double? volumeCapacity;
  final double? weightCapacity;
  final ValueChanged<num?>? onVolumeCapacityChanged;
  final ValueChanged<num?>? onWeightCapacityChanged;

  // ---------------- Vehicle Profile controllers + values ----------------
  final TextEditingController yearModelController;
  final TextEditingController designatedMunicipalityController;
  final TextEditingController remarksController;
  final VehicleStatus status;
  final ValueChanged<VehicleStatus> onStatusChanged;
  final List<XFile> attachments;
  final ValueChanged<List<XFile>> onAttachmentsChanged;

  // ---------------- Multi-select Region / Province data ----------------
  final List<RegionEntity> regions;
  final List<RegionEntity> selectedRegions;
  final ValueChanged<List<RegionEntity>>? onSelectedRegionsChanged;

  final List<ProvinceEntity> provinces;
  final List<ProvinceEntity> selectedProvinces;
  final ValueChanged<List<ProvinceEntity>>? onSelectedProvincesChanged;

  final bool enabled;

  // ---------------- Optional error banner ----------------
  /// When non-null, an [UpdateVehicleErrorBanner] is rendered at
  /// the bottom of the column.
  final String? errorMessage;

  const UpdateVehicleForm({
    super.key,
    required this.nameController,
    required this.plateNoController,
    required this.makeController,
    required this.typeController,
    required this.wheelsController,
    required this.volumeCapacity,
    required this.weightCapacity,
    required this.onVolumeCapacityChanged,
    required this.onWeightCapacityChanged,
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
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        VehicleDataForm(
          nameController: nameController,
          makeController: makeController,
          typeController: typeController,
          wheelsController: wheelsController,
          volumeCapacity: volumeCapacity,
          weightCapacity: weightCapacity,
          onVolumeCapacityChanged: onVolumeCapacityChanged,
          onWeightCapacityChanged: onWeightCapacityChanged,
        ),
        const SizedBox(height: 16),
        VehicleProfileForm(
          yearModelController: yearModelController,
          designatedMunicipalityController: designatedMunicipalityController,
          remarksController: remarksController,
          status: status,
          onStatusChanged: onStatusChanged,
          attachments: attachments,
          onAttachmentsChanged: onAttachmentsChanged,
          regions: regions,
          selectedRegions: selectedRegions,
          onSelectedRegionsChanged: onSelectedRegionsChanged,
          provinces: provinces,
          selectedProvinces: selectedProvinces,
          onSelectedProvincesChanged: onSelectedProvincesChanged,
          enabled: enabled,
        ),
        if (errorMessage != null) ...[
          const SizedBox(height: 12),
          UpdateVehicleErrorBanner(message: errorMessage!),
        ],
      ],
    );
  }
}
