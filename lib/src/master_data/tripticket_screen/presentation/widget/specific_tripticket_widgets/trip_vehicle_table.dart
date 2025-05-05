import 'package:xpro_delivery_admin_app/core/common/app/features/Delivery_Team/vehicle/domain/entity/vehicle_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/trip/presentation/bloc/trip_bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/trip/presentation/bloc/trip_event.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/trip/presentation/bloc/trip_state.dart';
import 'package:xpro_delivery_admin_app/core/common/widgets/app_structure/data_table_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TripVehicleTable extends StatefulWidget {
  final String tripId;
  final VoidCallback? onAddVehicle;

  const TripVehicleTable({super.key, required this.tripId, this.onAddVehicle});

  @override
  State<TripVehicleTable> createState() => _TripVehicleTableState();
}

class _TripVehicleTableState extends State<TripVehicleTable> {
  int _currentPage = 1;
  final int _itemsPerPage = 5;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TripBloc, TripState>(
      builder: (context, state) {
        if (state is TripError) {
          return SizedBox(
            height: 300,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading vehicles: ${state.message}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<TripBloc>().add(
                        GetTripTicketByIdEvent(widget.tripId),
                      );
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        List<VehicleEntity> vehicles = [];

        if (state is TripTicketLoaded) {
          vehicles = state.trip.vehicle;
          debugPrint('✅ Loaded ${vehicles.length} vehicles from trip data');
        }

        // Calculate total pages
        final int totalPages = (vehicles.length / _itemsPerPage).ceil();
        final int effectiveTotalPages = totalPages == 0 ? 1 : totalPages;

        // Paginate vehicles
        final startIndex = (_currentPage - 1) * _itemsPerPage;
        final endIndex =
            startIndex + _itemsPerPage > vehicles.length
                ? vehicles.length
                : startIndex + _itemsPerPage;

        final paginatedVehicles =
            startIndex < vehicles.length
                ? vehicles.sublist(startIndex, endIndex)
                : [];

        // Create data rows from vehicles
        final List<DataRow> rows =
            paginatedVehicles.map((vehicle) {
              return DataRow(
                cells: [
                  DataCell(Text(vehicle.id ?? 'N/A')),
                  DataCell(Text(vehicle.vehicleName ?? 'N/A')),
                  DataCell(Text(vehicle.vehiclePlateNumber ?? 'N/A')),
                  //   DataCell(_buildTypeChip(vehicle.vehicleType)),
                  DataCell(
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.orange),
                          tooltip: 'Edit',
                          onPressed: () {
                            // Edit vehicle
                            _showEditVehicleDialog(context, vehicle);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          tooltip: 'Delete',
                          onPressed: () {
                            // Delete vehicle
                            _showDeleteConfirmationDialog(context, vehicle);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }).toList();

        return DataTableLayout(
          title: 'Vehicle',
          onCreatePressed: widget.onAddVehicle,
          createButtonText: 'Add Vehicle',
          columns: const [
            DataColumn(label: Text('ID')),
            DataColumn(label: Text('Name')),
            DataColumn(label: Text('Plate Number')),
            //   DataColumn(label: Text('Type')),
            DataColumn(label: Text('Actions')),
          ],
          rows: rows,
          currentPage: _currentPage,
          totalPages: effectiveTotalPages,
          onPageChanged: (page) {
            setState(() {
              _currentPage = page;
            });
          },
          isLoading: state is TripLoading,
          errorMessage: state is TripError ? state.message : null,
          onRetry:
              state is TripError
                  ? () => context.read<TripBloc>().add(
                    GetTripTicketByIdEvent(widget.tripId),
                  )
                  : null,
          onFiltered: () {}, dataLength: '${vehicles.length}', onDeleted: () {  },
        );
      },
    );
  }

  // Widget _buildTypeChip(String? type) {
  //   if (type == null || type.isEmpty) return const Text('N/A');

  //   Color chipColor;

  //   switch (type.toLowerCase()) {
  //     case 'truck':
  //       chipColor = Colors.blue;
  //       break;
  //     case 'van':
  //       chipColor = Colors.green;
  //       break;
  //     case 'motorcycle':
  //       chipColor = Colors.orange;
  //       break;
  //     default:
  //       chipColor = Colors.grey;
  //   }

  //   return Chip(
  //     label: Text(
  //       type,
  //       style: const TextStyle(
  //         color: Color.fromARGB(255, 41, 40, 40),
  //         fontSize: 12,
  //       ),
  //     ),
  //     backgroundColor: chipColor,
  //     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
  //     visualDensity: VisualDensity.compact,
  //   );
  // }

  void _showEditVehicleDialog(BuildContext context, VehicleEntity vehicle) {
    // This would be implemented to show a dialog for editing vehicle
    // For now, just show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Edit vehicle: ${vehicle.vehicleName}'),
        action: SnackBarAction(label: 'OK', onPressed: () {}),
      ),
    );
  }

  void _showDeleteConfirmationDialog(
    BuildContext context,
    VehicleEntity vehicle,
  ) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to delete ${vehicle.vehicleName}?'),
                const SizedBox(height: 10),
                const Text('This action cannot be undone.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(dialogContext).pop();

                // Instead of directly deleting the vehicle,
                // we would need to update the trip by removing this vehicle
                // For now, just show a snackbar indicating the action
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Vehicle ${vehicle.vehicleName} would be removed from trip',
                    ),
                    action: SnackBarAction(label: 'OK', onPressed: () {}),
                  ),
                );

                // Refresh the trip data after deletion
                context.read<TripBloc>().add(
                  GetTripTicketByIdEvent(widget.tripId),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
