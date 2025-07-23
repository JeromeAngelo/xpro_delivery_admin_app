import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/trip/domain/entity/trip_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/delivery_vehicle_data/data/model/delivery_vehicle_model.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/delivery_vehicle_data/presentation/bloc/delivery_vehicle_bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/delivery_vehicle_data/presentation/bloc/delivery_vehicle_event.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/delivery_vehicle_data/presentation/bloc/delivery_vehicle_state.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/trip/presentation/bloc/trip_bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/trip/presentation/bloc/trip_event.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/trip/presentation/bloc/trip_state.dart';
import 'package:xpro_delivery_admin_app/src/master_data/tripticket_screen/presentation/widget/create_trip_ticket_forms/vehicle_selection_dialog.dart';

class EditTripVehicleForm extends StatefulWidget {
  final TripEntity? currentTrip;
  final String? tripId;
  final DeliveryVehicleModel? selectedVehicle;
  final ValueChanged<DeliveryVehicleModel?> onVehicleChanged;

  const EditTripVehicleForm({
    super.key,
    required this.currentTrip,
    this.tripId,
    required this.selectedVehicle,
    required this.onVehicleChanged,
  });

  @override
  State<EditTripVehicleForm> createState() => _EditTripVehicleFormState();
}

class _EditTripVehicleFormState extends State<EditTripVehicleForm> {
  List<DeliveryVehicleModel> _availableVehicles = [];
  DeliveryVehicleModel? _currentSelectedVehicle;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadTripData();
    _loadVehicleData();
  }

  void _loadTripData() {
    // Load trip data to get vehicle information
    final tripIdToUse = widget.tripId ?? widget.currentTrip?.id;
    if (tripIdToUse != null) {
      context.read<TripBloc>().add(GetTripTicketByIdEvent(tripIdToUse));
      debugPrint('🔄 Loading trip data for vehicle, trip ID: $tripIdToUse');
    } else {
      // Fallback to existing data if no trip ID available
      _initializeWithExistingData();
    }
  }

  void _initializeWithExistingData() {
    // Fallback initialization with existing trip vehicle data
    if (widget.currentTrip?.vehicle != null) {
      _currentSelectedVehicle = DeliveryVehicleModel(
        id: widget.currentTrip!.vehicle!.id,
        name: widget.currentTrip!.vehicle!.name,
        plateNo: widget.currentTrip!.vehicle!.plateNo,
        type: widget.currentTrip!.vehicle!.type,
        volumeCapacity: widget.currentTrip!.vehicle!.volumeCapacity,
        weightCapacity: widget.currentTrip!.vehicle!.weightCapacity,
        created: widget.currentTrip!.vehicle!.created,
        updated: widget.currentTrip!.vehicle!.updated,
      );

      // Notify parent immediately
      widget.onVehicleChanged(_currentSelectedVehicle);

      debugPrint(
        '🚗 Initialized edit form with vehicle: ${_currentSelectedVehicle!.name}',
      );
    } else {
      debugPrint('⚠️ No vehicle data found in current trip');
    }
  }

  void _loadVehicleData() {
    context.read<DeliveryVehicleBloc>().add(
      const LoadAllDeliveryVehiclesEvent(),
    );
  }

  void _selectVehicle(DeliveryVehicleModel vehicle) {
    setState(() {
      _currentSelectedVehicle = vehicle;
    });
    widget.onVehicleChanged(_currentSelectedVehicle);
  }

  void _clearVehicle() {
    setState(() {
      _currentSelectedVehicle = null;
    });
    widget.onVehicleChanged(null);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<TripBloc, TripState>(
          listener: (context, state) {
            if (state is TripTicketLoaded) {
              // Handle trip data loaded - extract vehicle information
              final trip = state.trip;
              if (trip.vehicle != null) {
                _currentSelectedVehicle = DeliveryVehicleModel(
                  id: trip.vehicle!.id,
                  collectionId: trip.vehicle!.collectionId,
                  collectionName: trip.vehicle!.collectionName,
                  name: trip.vehicle!.name,
                  plateNo: trip.vehicle!.plateNo,
                  make: trip.vehicle!.make,
                  type: trip.vehicle!.type,
                  wheels: trip.vehicle!.wheels,
                  volumeCapacity: trip.vehicle!.volumeCapacity,
                  weightCapacity: trip.vehicle!.weightCapacity,
                  created: trip.vehicle!.created,
                  updated: trip.vehicle!.updated,
                );

                setState(() {
                  _isLoading = false;
                });

                // Notify parent about the vehicle
                widget.onVehicleChanged(_currentSelectedVehicle);

                debugPrint(
                  '🚗 Loaded vehicle from trip: ${_currentSelectedVehicle!.name}',
                );
              } else {
                setState(() {
                  _isLoading = false;
                });
                debugPrint('⚠️ No vehicle found in loaded trip');
              }
            } else if (state is TripError) {
              setState(() {
                _isLoading = false;
              });
              debugPrint('❌ Error loading trip: ${state.message}');
            }
          },
        ),
        BlocListener<DeliveryVehicleBloc, DeliveryVehicleState>(
          listener: (context, state) {
            if (state is DeliveryVehicleLoaded) {
              setState(() {
                _availableVehicles = [DeliveryVehicleModel(
                  id: state.vehicle.id,
                  collectionId: state.vehicle.collectionId,
                  collectionName: state.vehicle.collectionName,
                  name: state.vehicle.name,
                  plateNo: state.vehicle.plateNo,
                  make: state.vehicle.make,
                  type: state.vehicle.type,
                  wheels: state.vehicle.wheels,
                  volumeCapacity: state.vehicle.volumeCapacity,
                  weightCapacity: state.vehicle.weightCapacity,
                  created: state.vehicle.created,
                  updated: state.vehicle.updated,
                )];
              });
              debugPrint('🚛 Available vehicles loaded: ${_availableVehicles.length}');
            } else if (state is DeliveryVehiclesLoaded) {
              setState(() {
                _availableVehicles = state.vehicles.map((vehicle) => DeliveryVehicleModel(
                  id: vehicle.id,
                  collectionId: vehicle.collectionId,
                  collectionName: vehicle.collectionName,
                  name: vehicle.name,
                  plateNo: vehicle.plateNo,
                  make: vehicle.make,
                  type: vehicle.type,
                  wheels: vehicle.wheels,
                  volumeCapacity: vehicle.volumeCapacity,
                  weightCapacity: vehicle.weightCapacity,
                  created: vehicle.created,
                  updated: vehicle.updated,
                )).toList();
              });
              debugPrint('🚛 Available vehicles loaded: ${_availableVehicles.length}');
            } else if (state is DeliveryVehicleError) {
              setState(() {
                _availableVehicles = [];
              });
              debugPrint('❌ Error loading vehicles: ${state.message}');
            }
          },
        ),
      ],
      child: BlocBuilder<TripBloc, TripState>(
        builder: (context, tripState) {
          // Handle loading state
          bool isLoading = _isLoading;
          if (tripState is TripLoading) {
            isLoading = true;
          }

          return _buildContent(isLoading);
        },
      ),
    );
  }

  Widget _buildContent(bool isLoading) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.local_shipping, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'Delivery Vehicle',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                if (_currentSelectedVehicle != null && !isLoading)
                  TextButton.icon(
                    onPressed: _clearVehicle,
                    icon: const Icon(Icons.clear, color: Colors.red),
                    label: const Text(
                      'Clear Selection',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: isLoading ? null : _showVehicleSelectionDialog,
                  icon:
                      isLoading
                          ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const Icon(Icons.directions_car),
                  label: Text(
                    isLoading
                        ? 'Loading...'
                        : (_currentSelectedVehicle == null
                            ? 'Select Vehicle'
                            : 'Change Vehicle'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Selected Vehicle Display
            if (_currentSelectedVehicle == null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Column(
                  children: [
                    Icon(
                      Icons.local_shipping_outlined,
                      size: 48,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No vehicle selected',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'A vehicle is required for this trip',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.orange),
                    ),
                  ],
                ),
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.green.shade300),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.green.shade50,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.green.shade100,
                          child: Icon(
                            Icons.local_shipping,
                            color: Colors.green.shade800,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _currentSelectedVehicle!.name ??
                                    'Unknown Vehicle',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Plate: ${_currentSelectedVehicle!.plateNo ?? 'N/A'}',
                                style: TextStyle(color: Colors.grey.shade700),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoChip(
                            'Type',
                            _currentSelectedVehicle!.type ?? 'N/A',
                            Icons.category,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (_currentSelectedVehicle!.volumeCapacity != null)
                          Expanded(
                            child: _buildInfoChip(
                              'Volume',
                              '${_currentSelectedVehicle!.volumeCapacity} m³',
                              Icons.aspect_ratio,
                            ),
                          ),
                        if (_currentSelectedVehicle!.weightCapacity != null)
                          const SizedBox(width: 8),
                        if (_currentSelectedVehicle!.weightCapacity != null)
                          Expanded(
                            child: _buildInfoChip(
                              'Weight',
                              '${_currentSelectedVehicle!.weightCapacity} kg',
                              Icons.scale,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 16),

            // Status
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color:
                    _currentSelectedVehicle != null
                        ? Colors.green.shade50
                        : Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color:
                      _currentSelectedVehicle != null
                          ? Colors.green.shade200
                          : Colors.orange.shade200,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _currentSelectedVehicle != null
                        ? Icons.check_circle_outline
                        : Icons.warning_outlined,
                    color:
                        _currentSelectedVehicle != null
                            ? Colors.green.shade700
                            : Colors.orange.shade700,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _currentSelectedVehicle != null
                        ? 'Vehicle selected successfully'
                        : 'Vehicle selection is required',
                    style: TextStyle(
                      color:
                          _currentSelectedVehicle != null
                              ? Colors.green.shade700
                              : Colors.orange.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.blue.shade700),
          const SizedBox(width: 4),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.blue.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue.shade800,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showVehicleSelectionDialog() {
    // Check if we have available vehicles loaded
    if (_availableVehicles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Loading vehicle data, please wait...'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => VehicleSelectionDialog(
        availableVehicles: _availableVehicles,
        selectedVehicles: _currentSelectedVehicle != null 
            ? [_currentSelectedVehicle!] 
            : [],
        onVehiclesChanged: (vehicles) {
          // For single vehicle selection, take the first (and only) vehicle
          if (vehicles.isNotEmpty) {
            _selectVehicle(vehicles.first);
          } else {
            _clearVehicle();
          }
        },
        onVehicleSelectedForCapacityCheck: (vehicle) {
          // This callback is used by the capacity checker
          // For the edit form, we can just log it or use it for additional analytics
          if (vehicle != null) {
            debugPrint('🚗 Vehicle selected for capacity check: ${vehicle.name}');
          }
        },
      ),
    );
  }
}
