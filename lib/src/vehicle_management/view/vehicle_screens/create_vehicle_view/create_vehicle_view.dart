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
import 'package:xpro_delivery_admin_app/core/services/core_utils.dart';

import '../../../widgets/vehicle_widgets/create_vehicle_widgets/vehicle_data_form.dart';

/// "Create Vehicle" form that creates a `DeliveryVehicleModel` via the
/// `CreateDeliveryVehicle` usecase. The vehicle tag multi-select dropdown
/// lets the user associate existing vehicle tags with the new vehicle.
class CreateVehicleView extends StatefulWidget {
  const CreateVehicleView({super.key});

  @override
  State<CreateVehicleView> createState() => _CreateVehicleViewState();
}

class _CreateVehicleViewState extends State<CreateVehicleView> {
  final _formKey = GlobalKey<FormState>();

  // ---------------- Vehicle Data controllers ----------------
  final _nameController = TextEditingController();
  final _plateNoController = TextEditingController();
  final _makeController = TextEditingController();
  final _typeController = TextEditingController();
  final _wheelsController = TextEditingController();
  double? _volumeCapacity;
  double? _weightCapacity;

  // ---------------- Flow state ----------------
  bool _isLoading = false;
  String? _errorMessage;
  bool _hasNavigated = false;

  // ---------------- Cached vehicle tag data ----------------
  List<VehicleTagEntity> _vehicleTags = const [];
  List<VehicleTagEntity> _selectedVehicleTags = const [];

  @override
  void initState() {
    super.initState();
    // Load all vehicle tags for the tag multi-select dropdown.
    context.read<VehicleTagBloc>().add(const GetVehicleTagsEvent());
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

  void _onSelectedVehicleTagsChanged(List<VehicleTagEntity> newSelection) {
    setState(() {
      _selectedVehicleTags = newSelection;
    });
  }

  void _submit() {
    if (_isLoading) return;

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
      vehicleTags: _selectedVehicleTags,
    );

    debugPrint('🚀 [CREATE VEHICLE] Dispatching CreateDeliveryVehicleEvent');
    context.read<DeliveryVehicleBloc>().add(
      CreateDeliveryVehicleEvent(vehicle),
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
                '✅ [CREATE VEHICLE] Loaded ${state.vehicleTags.length} vehicle tags',
              );
              setState(() {
                _vehicleTags = state.vehicleTags;
              });
            } else if (state is VehicleTagError) {
              debugPrint(
                '❌ [CREATE VEHICLE] Vehicle tag load error: ${state.message}',
              );
            }
          },
        ),
        // -----------------------------------------------------------------
        // Listen for the DeliveryVehicleBloc result.
        // -----------------------------------------------------------------
        BlocListener<DeliveryVehicleBloc, DeliveryVehicleState>(
          listener: (context, state) {
            if (!_isLoading) return;

            if (state is DeliveryVehicleCreated) {
              debugPrint(
                '✅ [CREATE VEHICLE] DeliveryVehicle created: '
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

                messenger.removeCurrentSnackBar();
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      'Vehicle created successfully',
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
                  router.go('/vehicle-list');
                });
              }
            } else if (state is DeliveryVehicleError) {
              debugPrint(
                '❌ [CREATE VEHICLE] DeliveryVehicle error: ${state.message}',
              );
              setState(() {
                _isLoading = false;
                _errorMessage = state.message;
              });
              CoreUtils.showSnackBar(
                context,
                'Failed to create vehicle: ${state.message}',
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
            title: 'Create Vehicle',
            isLoading: _isLoading,
            actions: [
              FormCancelButton(
                label: 'Cancel',
                onPressed: () {
                  if (!_isLoading) context.go('/vehicle-list');
                },
              ),
              const SizedBox(width: 16),
              FormSubmitButton(
                label: _isLoading ? 'Saving...' : 'Create Vehicle',
                onPressed: _isLoading ? null : _submit,
                icon: _isLoading ? Icons.hourglass_empty : Icons.add,
              ),
            ],
            children: [
              // -----------------------------------------------------------------
              // Section 1 – Vehicle Data
              // -----------------------------------------------------------------
              VehicleDataForm(
                nameController: _nameController,
                makeController: _makeController,
                typeController: _typeController,
                wheelsController: _wheelsController,
                volumeCapacity: _volumeCapacity,
                weightCapacity: _weightCapacity,
                onVolumeCapacityChanged: (v) => _volumeCapacity = v?.toDouble(),
                onWeightCapacityChanged: (v) => _weightCapacity = v?.toDouble(),
                vehicleTags: _vehicleTags,
                selectedVehicleTags: _selectedVehicleTags,
                onSelectedVehicleTagsChanged: _onSelectedVehicleTagsChanged,
              ),

              // -----------------------------------------------------------------
              // Error banner.
              // -----------------------------------------------------------------
              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red.shade700),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red.shade900),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
