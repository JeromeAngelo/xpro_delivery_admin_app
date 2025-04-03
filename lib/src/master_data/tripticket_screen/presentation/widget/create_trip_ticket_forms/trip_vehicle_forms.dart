import 'package:desktop_app/core/common/widgets/create_screen_widgets/app_drop_down_fields.dart';
import 'package:desktop_app/core/common/widgets/create_screen_widgets/app_textfield.dart';
import 'package:desktop_app/core/common/widgets/create_screen_widgets/form_title.dart';
import 'package:flutter/material.dart';

import 'package:desktop_app/core/common/app/features/Delivery_Team/vehicle/data/model/vehicle_model.dart';

class VehicleForm extends StatelessWidget {
  final List<VehicleModel> availableVehicles;
  final List<VehicleModel> selectedVehicles;
  final Function(List<VehicleModel>) onVehiclesChanged;

  const VehicleForm({
    super.key,
    required this.availableVehicles,
    required this.selectedVehicles,
    required this.onVehiclesChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FormSectionTitle(title: 'Assign Vehicle'),

        // Vehicles dropdown
        _buildVehiclesDropdown(context),
      ],
    );
  }

  Widget _buildVehiclesDropdown(BuildContext context) {
    if (availableVehicles.isEmpty) {
      return const AppTextField(
        label: 'Vehicles',
        initialValue: 'No Vehicles',
        readOnly: true,
   //     helperText: 'No vehicles available to select',
      );
    }

    // Display selected vehicles with remove option
    Widget selectedVehiclesWidget = const SizedBox.shrink();
    if (selectedVehicles.isNotEmpty) {
      selectedVehiclesWidget = Padding(
        padding: const EdgeInsets.only(left: 200.0, bottom: 8.0), // Align with dropdown
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: selectedVehicles.map((vehicle) {
            return Chip(
              label: Text(
                vehicle.vehiclePlateNumber ?? 'Vehicle ${vehicle.id}',
              ),
              deleteIcon: const Icon(Icons.close, size: 16),
              onDeleted: () {
                final updatedList = List<VehicleModel>.from(selectedVehicles);
                updatedList.remove(vehicle);
                onVehiclesChanged(updatedList);
              },
            );
          }).toList(),
        ),
      );
    }

   // Convert available vehicles to dropdown items
final vehicleItems = availableVehicles
    .where((vehicle) => !selectedVehicles.contains(vehicle))
    .map((vehicle) {
  return DropdownItem<VehicleModel>(
    value: vehicle,
    label: vehicle.vehiclePlateNumber ?? 'Vehicle ${vehicle.id}',
    icon: const Icon(Icons.local_shipping, size: 16),
uniqueId: vehicle.id ?? 'vehicle_${vehicle.hashCode}',
  );
}).toList();


    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Show selected vehicles chips
        selectedVehiclesWidget,
        
        // Dropdown to add more vehicles
        AppDropdownField<VehicleModel>(
          label: 'Vehicles',
          hintText: 'Select Vehicle',
          items: vehicleItems,
          onChanged: (value) {
            if (value != null && !selectedVehicles.contains(value)) {
              final updatedList = List<VehicleModel>.from(selectedVehicles);
              updatedList.add(value);
              onVehiclesChanged(updatedList);
            }
          },
       //   helperText: 'Select vehicles for this trip',
        ),
      ],
    );
  }
}
