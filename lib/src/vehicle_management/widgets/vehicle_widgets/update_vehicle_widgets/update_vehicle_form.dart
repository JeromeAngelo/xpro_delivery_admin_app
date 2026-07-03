import 'package:flutter/material.dart';

import 'package:xpro_delivery_admin_app/core/common/app/features/vehicle/vehicle_tags/domain/entity/vehicle_tag_entity.dart';
import 'package:xpro_delivery_admin_app/core/enums/vehicle_status.dart';

import '../create_vehicle_widgets/vehicle_data_form.dart';
import 'update_vehicle_error_banner.dart';

/// The "Update Vehicle" form body.
///
/// Renders the [VehicleDataForm] sub-form and an optional
/// [UpdateVehicleErrorBanner] beneath it. The widget is fully
/// controlled — the parent (`UpdateVehicleView`) owns all
/// controllers and the selected vehicle tags.
class UpdateVehicleForm extends StatelessWidget {
  // ---------------- Vehicle Data controllers + values ----------------
  final TextEditingController nameController;
  final TextEditingController plateNoController;
  final TextEditingController makeController;
  final TextEditingController typeController;
  final TextEditingController wheelsController;
  final double? volumeCapacity;
  final double? weightCapacity;
  final VehicleStatus? status;
  final ValueChanged<num?>? onVolumeCapacityChanged;
  final ValueChanged<num?>? onWeightCapacityChanged;
  final ValueChanged<VehicleStatus?>? onStatusChanged;

  // ---------------- Vehicle tag multi-select data ----------------
  final List<VehicleTagEntity> vehicleTags;
  final List<VehicleTagEntity> selectedVehicleTags;
  final ValueChanged<List<VehicleTagEntity>>? onSelectedVehicleTagsChanged;

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
    this.status,
    this.onStatusChanged,
    this.vehicleTags = const [],
    this.selectedVehicleTags = const [],
    this.onSelectedVehicleTagsChanged,
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
          status: status,
          onStatusChanged: onStatusChanged,
          vehicleTags: vehicleTags,
          selectedVehicleTags: selectedVehicleTags,
          onSelectedVehicleTagsChanged: onSelectedVehicleTagsChanged,
        ),
        if (errorMessage != null) ...[
          const SizedBox(height: 12),
          UpdateVehicleErrorBanner(message: errorMessage!),
        ],
      ],
    );
  }
}
