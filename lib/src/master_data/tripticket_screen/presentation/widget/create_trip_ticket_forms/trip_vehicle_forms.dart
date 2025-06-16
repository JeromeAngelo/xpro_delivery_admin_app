import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/delivery_data/presentation/bloc/delivery_data_bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/delivery_vehicle_data/data/model/delivery_vehicle_model.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/delivery_vehicle_data/presentation/bloc/delivery_vehicle_bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/widgets/create_screen_widgets/app_drop_down_fields.dart';
import 'package:xpro_delivery_admin_app/core/common/widgets/create_screen_widgets/app_textfield.dart';
import 'package:xpro_delivery_admin_app/core/common/widgets/create_screen_widgets/form_title.dart';
import 'package:xpro_delivery_admin_app/src/master_data/tripticket_screen/presentation/widget/create_trip_ticket_forms/vehicle_capacity_info.dart';

class VehicleForm extends StatefulWidget {
  final List<DeliveryVehicleModel> availableVehicles;
  final List<DeliveryVehicleModel> selectedVehicles;
  final Function(List<DeliveryVehicleModel>) onVehiclesChanged;

  const VehicleForm({
    super.key,
    required this.availableVehicles,
    required this.selectedVehicles,
    required this.onVehiclesChanged,
  });

  @override
  State<VehicleForm> createState() => _VehicleFormState();
}

class _VehicleFormState extends State<VehicleForm> {
  DeliveryVehicleModel? _selectedVehicleForCapacityCheck;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FormSectionTitle(title: 'Assign Vehicle'),

        // Main content row - dropdown on left, capacity info on right
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left side - Vehicle dropdown
            Expanded(flex: 1, child: _buildVehiclesDropdown(context)),

            // Right side - Capacity info (always shown, with or without selected vehicle)
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: MultiBlocProvider(
                  providers: [
                    BlocProvider.value(
                      value: BlocProvider.of<DeliveryVehicleBloc>(context),
                    ),
                    BlocProvider.value(
                      value: BlocProvider.of<DeliveryDataBloc>(context),
                    ),
                  ],
                  child: VehicleCapacityInfo(
                    vehicle: _selectedVehicleForCapacityCheck,
                    onConfirm: (confirmedVehicle) {
                      final updatedList = List<DeliveryVehicleModel>.from(
                        widget.selectedVehicles,
                      );
                      updatedList.add(confirmedVehicle as DeliveryVehicleModel);
                      widget.onVehiclesChanged(updatedList);

                      // Clear the selected vehicle after adding
                      setState(() {
                        _selectedVehicleForCapacityCheck = null;
                      });
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildVehiclesDropdown(BuildContext context) {
    if (widget.availableVehicles.isEmpty) {
      return const AppTextField(
        label: 'Vehicles',
        initialValue: 'No Vehicles',
        readOnly: true,
      );
    }

    // Convert available vehicles to dropdown items
    // Only exclude vehicles that are already in the selectedVehicles list
    // Do NOT exclude the currently selected vehicle for capacity check
    final vehicleItems =
        widget.availableVehicles
            .where((vehicle) => !widget.selectedVehicles.contains(vehicle))
            .map((vehicle) {
              return DropdownItem<DeliveryVehicleModel>(
                value: vehicle,
                label: vehicle.plateNo ?? '${vehicle.make} ${vehicle.name}',
                icon: const Icon(Icons.local_shipping, size: 16),
                uniqueId: vehicle.id ?? 'vehicle_${vehicle.hashCode}',
              );
            })
            .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Dropdown to add more vehicles
        AppDropdownField<DeliveryVehicleModel>(
          label: 'Vehicles',
          hintText: 'Select Vehicle',
          items: vehicleItems,
          value: _selectedVehicleForCapacityCheck,
          onChanged: (value) {
            if (value != null) {
              // Update the selected vehicle to show capacity info
              setState(() {
                _selectedVehicleForCapacityCheck = value;
              });
            }
          },
        ),

        // Add a button to clear the capacity check
        if (_selectedVehicleForCapacityCheck != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: TextButton.icon(
              onPressed: () {
                setState(() {
                  _selectedVehicleForCapacityCheck = null;
                });
              },
              icon: const Icon(Icons.close, size: 16),
              label: const Text('Clear capacity check'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),

        // Display selected vehicles with remove option BELOW the dropdown
        if (widget.selectedVehicles.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Selected Vehicles:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      widget.selectedVehicles.map((vehicle) {
                        return Chip(
                          label: Text(
                            vehicle.plateNo ??
                                '${vehicle.make} ${vehicle.name}',
                          ),
                          deleteIcon: const Icon(Icons.close, size: 16),
                          onDeleted: () {
                            final updatedList = List<DeliveryVehicleModel>.from(
                              widget.selectedVehicles,
                            );
                            updatedList.remove(vehicle);
                            widget.onVehiclesChanged(updatedList);
                          },
                        );
                      }).toList(),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
