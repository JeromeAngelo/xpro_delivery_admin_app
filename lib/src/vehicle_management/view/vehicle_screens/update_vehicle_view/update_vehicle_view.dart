import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:xpro_delivery_admin_app/core/common/app/features/trip_ticket/delivery_vehicle_data/data/model/delivery_vehicle_model.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/trip_ticket/delivery_vehicle_data/presentation/bloc/delivery_vehicle_bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/trip_ticket/delivery_vehicle_data/presentation/bloc/delivery_vehicle_event.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/trip_ticket/delivery_vehicle_data/presentation/bloc/delivery_vehicle_state.dart';

import 'package:xpro_delivery_admin_app/core/common/app/features/vehicle/vehicle_tags/domain/entity/vehicle_tag_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/vehicle/vehicle_tags/presentation/bloc/vehicle_tag_bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/vehicle/vehicle_tags/presentation/bloc/vehicle_tag_event.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/vehicle/vehicle_tags/presentation/bloc/vehicle_tag_state.dart';

import 'package:xpro_delivery_admin_app/core/common/widgets/app_structure/desktop_layout.dart';
import 'package:xpro_delivery_admin_app/core/common/widgets/create_screen_widgets/form_buttons.dart';
import 'package:xpro_delivery_admin_app/core/common/widgets/create_screen_widgets/form_layout.dart';
import 'package:xpro_delivery_admin_app/core/common/widgets/reusable_widgets/app_navigation_items.dart';
import 'package:xpro_delivery_admin_app/core/enums/vehicle_status.dart';
import 'package:xpro_delivery_admin_app/core/services/core_utils.dart';

import '../../../../../core/common/app/features/trip_ticket/delivery_vehicle_data/domain/enitity/delivery_vehicle_entity.dart';
import '../../../widgets/vehicle_widgets/update_vehicle_widgets/update_vehicle_form.dart';

/// "Update Vehicle" form that updates a `DeliveryVehicleModel` via the
/// `UpdateDeliveryVehicle` usecase. The vehicle tag multi-select dropdown
/// lets the user associate existing vehicle tags with the vehicle.
class UpdateVehicleView extends StatefulWidget {
  /// The `DeliveryVehicleModel.id` we are editing.
  final String deliveryVehicleId;

  const UpdateVehicleView({super.key, required this.deliveryVehicleId});

  @override
  State<UpdateVehicleView> createState() => _UpdateVehicleViewState();
}

class _UpdateVehicleViewState extends State<UpdateVehicleView> {
  final _formKey = GlobalKey<FormState>();

  // ---------------- Vehicle Data controllers ----------------
  final _nameController = TextEditingController();
  final _plateNoController = TextEditingController();
  final _makeController = TextEditingController();
  final _typeController = TextEditingController();
  final _wheelsController = TextEditingController();
  double? _volumeCapacity;
  double? _weightCapacity;
  VehicleStatus? _status;

  // ---------------- Flow state ----------------
  bool _isLoading = false;
  bool _isInitializing = true;
  String? _errorMessage;
  bool _hasNavigated = false;

  /// True once the delivery vehicle has been loaded into the form.
  bool _ready = false;

  /// Holds the original delivery vehicle id (the one we were loaded
  /// with) for navigation after a successful update.
  late final String _initialDeliveryVehicleId = widget.deliveryVehicleId;

  // ---------------- Cached vehicle tag data ----------------
  List<VehicleTagEntity> _vehicleTags = const [];
  List<VehicleTagEntity> _selectedVehicleTags = const [];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _plateNoController.dispose();
    _makeController.dispose();
    _typeController.dispose();
    _wheelsController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Initial load
  // ---------------------------------------------------------------------------
  void _loadInitialData() {
    setState(() {
      _isInitializing = true;
    });

    // Fetch the delivery vehicle data.
    context.read<DeliveryVehicleBloc>().add(
      LoadDeliveryVehicleByIdEvent(widget.deliveryVehicleId),
    );

    // Load all vehicle tags for the tag multi-select dropdown.
    context.read<VehicleTagBloc>().add(const GetVehicleTagsEvent());
  }

  void _populateFromVehicle(DeliveryVehicleEntity vehicle) {
    _nameController.text = vehicle.name ?? '';
    _plateNoController.text = vehicle.plateNo ?? '';
    _wheelsController.text = vehicle.wheels ?? '';
    _volumeCapacity = vehicle.volumeCapacity;
    _weightCapacity = vehicle.weightCapacity;
    _status = vehicle.status;

    // `make` and `type` are stored in PocketBase as the all-caps enum
    // label (see VehicleDataForm). We restore them as-is into the
    // controllers; VehicleDataForm's case-insensitive lookup will
    // re-hydrate the dropdown.
    _makeController.text = vehicle.make ?? '';
    _typeController.text = vehicle.type ?? '';

    // Pre-populate the selected vehicle tags from the loaded relation.
    _selectedVehicleTags = vehicle.vehicleTags ?? const [];
  }

  void _onStatusChanged(VehicleStatus? status) {
    setState(() {
      _status = status;
    });
  }

  void _onSelectedVehicleTagsChanged(List<VehicleTagEntity> newSelection) {
    setState(() {
      _selectedVehicleTags = newSelection;
    });
  }

  /// Mark the form ready to submit once the vehicle loader has reported
  /// at least once (success or empty). Errors are surfaced via the
  /// banner; we still consider the form "ready" so the user can
  /// fix and retry.
  void _tryMarkReady() {
    if (_ready) return;
    setState(() {
      _isInitializing = false;
      _ready = true;
    });
  }

  // ---------------------------------------------------------------------------
  // Submit
  // ---------------------------------------------------------------------------
  void _submit() {
    if (_isLoading || !_ready) return;

    if (!_formKey.currentState!.validate()) {
      CoreUtils.showSnackBar(context, 'Please fill all required fields');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _hasNavigated = false;
    });

    final vehicle = DeliveryVehicleModel(
      name: _nameController.text.trim(),
      plateNo: _plateNoController.text.trim(),
      make: _makeController.text.trim(),
      type: _typeController.text.trim(),
      wheels: _wheelsController.text.trim(),
      volumeCapacity: _volumeCapacity,
      weightCapacity: _weightCapacity,
      status: _status,
      vehicleTags: _selectedVehicleTags,
    );

    debugPrint(
      '🚀 [UPDATE VEHICLE] Dispatching UpdateDeliveryVehicleEvent for '
      'id=${widget.deliveryVehicleId}',
    );
    context.read<DeliveryVehicleBloc>().add(
      UpdateDeliveryVehicleEvent(
        id: widget.deliveryVehicleId,
        vehicle: vehicle,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final navigationItems =
        AppNavigationItems.vehicleManagementNavigationItems();

    return MultiBlocListener(
      listeners: [
        // -----------------------------------------------------------------
        // Listen for the VehicleTagBloc result.
        // -----------------------------------------------------------------
        BlocListener<VehicleTagBloc, VehicleTagState>(
          listener: (context, state) {
            if (state is VehicleTagsLoaded) {
              debugPrint(
                '✅ [UPDATE VEHICLE] Loaded ${state.vehicleTags.length} vehicle tags',
              );
              setState(() {
                _vehicleTags = state.vehicleTags;
              });
            } else if (state is VehicleTagError) {
              debugPrint(
                '❌ [UPDATE VEHICLE] Vehicle tag load error: ${state.message}',
              );
            }
          },
        ),
        // -----------------------------------------------------------------
        // Listen for the DeliveryVehicleBloc result.
        // -----------------------------------------------------------------
        BlocListener<DeliveryVehicleBloc, DeliveryVehicleState>(
          listener: (context, state) {
            // Initial load: re-hydrate the controllers.
            if (_isInitializing) {
              if (state is DeliveryVehicleLoaded &&
                  state.vehicle.id == widget.deliveryVehicleId) {
                _populateFromVehicle(state.vehicle);
                _tryMarkReady();
              } else if (state is DeliveryVehicleError) {
                setState(() {
                  _isInitializing = false;
                  _errorMessage = state.message;
                });
              }
              return;
            }

            if (!_isLoading) return;

            if (state is DeliveryVehicleUpdated) {
              debugPrint(
                '✅ [UPDATE VEHICLE] DeliveryVehicle updated: '
                '${state.vehicle.id}',
              );
              if (mounted && !_hasNavigated) {
                setState(() {
                  _isLoading = false;
                  _errorMessage = null;
                  _hasNavigated = true;
                });

                final messenger = ScaffoldMessenger.of(context);
                final textColor = Theme.of(context).colorScheme.surface;
                final bgColor = Theme.of(context).colorScheme.primary;
                final router = GoRouter.of(context);
                final vehicleRoute = '/vehicle-id/$_initialDeliveryVehicleId';

                messenger.removeCurrentSnackBar();
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      'Vehicle updated successfully',
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    backgroundColor: bgColor,
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );

                Future.delayed(const Duration(milliseconds: 700), () {
                  if (!mounted) return;
                  router.go(vehicleRoute);
                });
              }
            } else if (state is DeliveryVehicleError) {
              debugPrint(
                '❌ [UPDATE VEHICLE] DeliveryVehicle error: ${state.message}',
              );
              setState(() {
                _isLoading = false;
                _errorMessage = state.message;
              });
              CoreUtils.showSnackBar(
                context,
                'Failed to update vehicle: ${state.message}',
              );
            }
          },
        ),
      ],
      child: DesktopLayout(
        navigationItems: navigationItems,
        currentRoute: '/vehicle-list',
        onNavigate: (route) {
          if (!_isLoading) context.go(route);
        },
        onThemeToggle: () {},
        onNotificationTap: () {},
        onProfileTap: () {},
        disableScrolling: true,
        child: Form(
          key: _formKey,
          child: FormLayout(
            title: 'Update Vehicle',
            isLoading: _isLoading || _isInitializing,
            actions: [
              FormCancelButton(
                label: 'Cancel',
                onPressed: () {
                  if (!_isLoading) {
                    context.go('/vehicle-id/$_initialDeliveryVehicleId');
                  }
                },
              ),
              const SizedBox(width: 16),
              FormSubmitButton(
                label:
                    _isLoading
                        ? 'Saving...'
                        : (_isInitializing ? 'Loading...' : 'Update Vehicle'),
                onPressed: (_isLoading || !_ready) ? null : _submit,
                icon: _isLoading ? Icons.hourglass_empty : Icons.save_outlined,
              ),
            ],
            children: [
              UpdateVehicleForm(
                nameController: _nameController,
                plateNoController: _plateNoController,
                makeController: _makeController,
                typeController: _typeController,
                wheelsController: _wheelsController,
                volumeCapacity: _volumeCapacity,
                weightCapacity: _weightCapacity,
                onVolumeCapacityChanged: (v) => _volumeCapacity = v?.toDouble(),
                onWeightCapacityChanged: (v) => _weightCapacity = v?.toDouble(),
                status: _status,
                onStatusChanged: _onStatusChanged,
                vehicleTags: _vehicleTags,
                selectedVehicleTags: _selectedVehicleTags,
                onSelectedVehicleTagsChanged: _onSelectedVehicleTagsChanged,
                errorMessage: _errorMessage,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
