import 'package:desktop_app/core/common/app/features/Delivery_Team/vehicle/domain/entity/vehicle_entity.dart';
import 'package:desktop_app/core/common/app/features/Delivery_Team/vehicle/presentation/bloc/vehicle_bloc.dart';
import 'package:desktop_app/core/common/app/features/Delivery_Team/vehicle/presentation/bloc/vehicle_event.dart';
import 'package:desktop_app/core/common/app/features/Delivery_Team/vehicle/presentation/bloc/vehicle_state.dart';
import 'package:desktop_app/core/common/widgets/app_structure/data_table_layout.dart';
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
  // String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load vehicle for this trip
    context.read<VehicleBloc>().add(LoadVehicleByTripIdEvent(widget.tripId));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VehicleBloc, VehicleState>(
      builder: (context, state) {
        // Prepare variables for different states
        bool isLoading = state is VehicleLoading;
        String? errorMessage;
        List<VehicleEntity> vehicles = [];

        // Handle different states
        if (state is VehicleError) {
          errorMessage = state.message;
        } else if (state is VehicleByTripLoaded) {
          // This state returns a single vehicle, so we create a list with that vehicle
          vehicles = [state.vehicle];
                } else if (state is VehiclesLoaded) {
          // If we have a list of vehicles, filter for this trip
          vehicles =
              state.vehicles.where((v) => v.trip?.id == widget.tripId).toList();
        }

        // Filter vehicles based on search query
        // if (_searchQuery.isNotEmpty) {
        //   vehicles = vehicles.where((vehicle) {
        //     final query = _searchQuery.toLowerCase();
        //     return (vehicle.id?.toLowerCase().contains(query) ?? false) ||
        //            (vehicle.vehicleName?.toLowerCase().contains(query) ?? false) ||
        //            (vehicle.vehiclePlateNumber?.toLowerCase().contains(query) ?? false) ||
        //            (vehicle.vehicleType?.toLowerCase().contains(query) ?? false);
        //   }).toList();
        // }

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
                  DataCell(_buildTypeChip(vehicle.vehicleType)),
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
          // searchBar: TextField(
          //   controller: _searchController,
          //   decoration: InputDecoration(
          //     hintText: 'Search vehicle...',
          //     prefixIcon: const Icon(Icons.search),
          //     suffixIcon: _searchQuery.isNotEmpty
          //         ? IconButton(
          //             icon: const Icon(Icons.clear),
          //             onPressed: () {
          //               setState(() {
          //                 _searchController.clear();
          //                 _searchQuery = '';
          //               });
          //             },
          //           )
          //         : null,
          //     border: OutlineInputBorder(
          //       borderRadius: BorderRadius.circular(8),
          //     ),
          //   ),
          //   onChanged: (value) {
          //     setState(() {
          //       _searchQuery = value;
          //     });
          //   },
          // ),
          onCreatePressed: widget.onAddVehicle,
          createButtonText: 'Add Vehicle',
          columns: const [
            DataColumn(label: Text('ID')),
            DataColumn(label: Text('Name')),
            DataColumn(label: Text('Plate Number')),
            DataColumn(label: Text('Type')),
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
          isLoading: isLoading,
          errorMessage: errorMessage,
          onRetry:
              errorMessage != null
                  ? () => context.read<VehicleBloc>().add(
                    LoadVehicleByTripIdEvent(widget.tripId),
                  )
                  : null, onFiltered: () {  },
        );
      },
    );
  }

  Widget _buildTypeChip(String? type) {
    if (type == null || type.isEmpty) return const Text('N/A');

    Color chipColor;

    switch (type.toLowerCase()) {
      case 'truck':
        chipColor = Colors.blue;
        break;
      case 'van':
        chipColor = Colors.green;
        break;
      case 'motorcycle':
        chipColor = Colors.orange;
        break;
      default:
        chipColor = Colors.grey;
    }

    return Chip(
      label: Text(
        type,
        style: const TextStyle(
          color: Color.fromARGB(255, 41, 40, 40),
          fontSize: 12,
        ),
      ),
      backgroundColor: chipColor,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      visualDensity: VisualDensity.compact,
    );
  }

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
                if (vehicle.id != null) {
                  context.read<VehicleBloc>().add(
                    DeleteVehicleEvent(vehicle.id!),
                  );
                  // Refresh the list after deletion
                  context.read<VehicleBloc>().add(
                    LoadVehicleByTripIdEvent(widget.tripId),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
}
