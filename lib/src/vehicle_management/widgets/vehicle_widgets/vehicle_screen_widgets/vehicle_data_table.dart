import 'package:xpro_delivery_admin_app/core/common/app/features/trip_ticket/delivery_vehicle_data/domain/enitity/delivery_vehicle_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/widgets/app_structure/data_table_layout.dart';
import 'package:xpro_delivery_admin_app/src/vehicle_management/widgets/vehicle_widgets/vehicle_screen_widgets/vehicle_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../../core/common/app/features/trip_ticket/delivery_vehicle_data/presentation/bloc/delivery_vehicle_bloc.dart';
import '../../../../../core/common/app/features/trip_ticket/delivery_vehicle_data/presentation/bloc/delivery_vehicle_event.dart';

class VehicleDataTable extends StatelessWidget {
  final List<DeliveryVehicleEntity> vehicles;
  final bool isLoading;
  final int currentPage;
  final int totalPages;
  final Function(int) onPageChanged;
  final TextEditingController searchController;
  final String searchQuery;
  final Function(String) onSearchChanged;

  const VehicleDataTable({
    super.key,
    required this.vehicles,
    required this.isLoading,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
    required this.searchController,
    required this.searchQuery,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DataTableLayout(
      title: 'Vehicles',
      searchBar: VehicleSearchBar(
        controller: searchController,
        searchQuery: searchQuery,
        onSearchChanged: onSearchChanged,
      ),
      onCreatePressed: () {
        context.go('/create-vehicle');
      },
      createButtonText: 'Add Vehicle',
      columns: const [
        DataColumn(label: Text('ID')),
        DataColumn(label: Text('Name')),
        DataColumn(label: Text('Plate Number')),
        DataColumn(label: Text('Type')),
        DataColumn(label: Text('Volume Capacity')),
        DataColumn(label: Text('Weight Capacity')),

        DataColumn(label: Text('Created')),
        DataColumn(label: Text('Actions')),
      ],
      rows:
          vehicles.map((vehicle) {
            return DataRow(
              cells: [
                DataCell(
                  Text(vehicle.id ?? 'N/A'),
                  onTap: () => _navigateToVehicleDetails(context, vehicle),
                ),
                DataCell(
                  Text(vehicle.make ?? 'N/A'),
                  onTap: () => _navigateToVehicleDetails(context, vehicle),
                ),
                DataCell(
                  Text(vehicle.name ?? 'N/A'),
                  onTap: () => _navigateToVehicleDetails(context, vehicle),
                ),
                DataCell(
                  Text(vehicle.type ?? 'N/A'),
                  onTap: () => _navigateToVehicleDetails(context, vehicle),
                ),
                DataCell(
                  Text('${vehicle.volumeCapacity ?? 'N/A'} cm3'),
                  onTap: () => _navigateToVehicleDetails(context, vehicle),
                ),
                DataCell(
                  Text('${vehicle.weightCapacity ?? 'N/A'} cm3'),
                  onTap: () => _navigateToVehicleDetails(context, vehicle),
                ),

                DataCell(Text(_formatDate(vehicle.created))),
                DataCell(
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.visibility, color: Colors.blue),
                        tooltip: 'View Details',
                        onPressed: () {
                          // View vehicle details
                          if (vehicle.id != null) {
                            // Navigate to vehicle details screen
                            _navigateToVehicleDetails(context, vehicle);
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.orange),
                        tooltip: 'Edit',
                        onPressed: () {
                          // Edit vehicle
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        tooltip: 'Delete',
                        onPressed: () {
                          // Show confirmation dialog before deleting
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
      currentPage: currentPage,
      totalPages: totalPages,
      onPageChanged: onPageChanged,
      isLoading: isLoading,
    
      dataLength: '${vehicles.length}',
      onDeleted: () {},
    );
  }

  void _navigateToVehicleDetails(
    BuildContext context,
    DeliveryVehicleEntity vehicle,
  ) {
    if (vehicle.id != null) {
      // First load the trip data
      context.read<DeliveryVehicleBloc>().add(
        LoadDeliveryVehicleByIdEvent(vehicle.id!),
      );

      // Then navigate to the specific trip view
      context.go('/vehicle-id/${vehicle.id}');
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('MMM dd, yyyy').format(date);
  }

 
}
