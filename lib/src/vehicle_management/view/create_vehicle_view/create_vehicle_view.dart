import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:xpro_delivery_admin_app/core/common/app/features/place_lookups/province/domain/entity/province_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/place_lookups/region/domain/entity/region_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/place_lookups/province/presentation/bloc/province_bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/place_lookups/province/presentation/bloc/province_event.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/place_lookups/province/presentation/bloc/province_state.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/place_lookups/region/presentation/bloc/region_bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/place_lookups/region/presentation/bloc/region_event.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/place_lookups/region/presentation/bloc/region_state.dart';

import 'package:xpro_delivery_admin_app/core/common/app/features/trip_ticket/delivery_vehicle_data/data/model/delivery_vehicle_model.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/trip_ticket/delivery_vehicle_data/presentation/bloc/delivery_vehicle_bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/trip_ticket/delivery_vehicle_data/presentation/bloc/delivery_vehicle_event.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/trip_ticket/delivery_vehicle_data/presentation/bloc/delivery_vehicle_state.dart';

import 'package:xpro_delivery_admin_app/core/common/app/features/vehicle/vehicle_profile/data/model/vehicle_profile_model.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/vehicle/vehicle_profile/presentation/bloc/vehicle_profile_bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/vehicle/vehicle_profile/presentation/bloc/vehicle_profile_event.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/vehicle/vehicle_profile/presentation/bloc/vehicle_profile_state.dart';

import 'package:xpro_delivery_admin_app/core/common/widgets/app_structure/desktop_layout.dart';
import 'package:xpro_delivery_admin_app/core/common/widgets/create_screen_widgets/form_buttons.dart';
import 'package:xpro_delivery_admin_app/core/common/widgets/create_screen_widgets/form_layout.dart';
import 'package:xpro_delivery_admin_app/core/common/widgets/reusable_widgets/app_navigation_items.dart';
import 'package:xpro_delivery_admin_app/core/enums/vehicle_status.dart';
import 'package:xpro_delivery_admin_app/core/services/core_utils.dart';

import '../../widgets/create_vehicle_widgets/vehicle_data_form.dart';
import '../../widgets/create_vehicle_widgets/vehicle_profile_form.dart';

/// "Create Vehicle" form that creates BOTH records on submit:
///
///   1. A `DeliveryVehicleModel` (via the `CreateDeliveryVehicle`
///      usecase).
///   2. A `VehicleProfileModel` (via the `CreateVehicleProfile`
///      usecase), linked to the freshly created delivery vehicle
///      and including the selected region(s) + province(s) and
///      the attachments the user picked.
///
/// The Region / Province dropdowns in the Vehicle Profile section
/// are backed by the live `RegionBloc` / `ProvinceBloc`: regions
/// are loaded on `initState`, and provinces are re-fetched for any
/// newly added region. Both dropdowns support multi-select; the
/// selected items appear as removable chips beneath each
/// dropdown.
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

  // ---------------- Vehicle Profile controllers ----------------
  final _yearModelController = TextEditingController();
  final _designatedMunicipalityController = TextEditingController();
  final _remarksController = TextEditingController();
  VehicleStatus _status = VehicleStatus.goodCondition;
  List<XFile> _attachments = const [];

  // ---------------- Flow state ----------------
  bool _isLoading = false;
  String? _errorMessage;
  bool _hasNavigated = false;

  // ---------------- Cached region / province data ----------------
  List<RegionEntity> _regions = const [];
  List<ProvinceEntity> _provinces = const [];
  List<RegionEntity> _selectedRegions = const [];
  List<ProvinceEntity> _selectedProvinces = const [];

  @override
  void initState() {
    super.initState();
    // Kick off the regions load as soon as the view is mounted so
    // the dropdown has data by the time the user reaches it.
    context.read<RegionBloc>().add(const GetAllRegionsEvent());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _plateNoController.dispose();
    _makeController.dispose();
    _typeController.dispose();
    _wheelsController.dispose();
    _yearModelController.dispose();
    _designatedMunicipalityController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  /// Called by the form when the user adds/removes a region. The
  /// parent is responsible for loading provinces for any newly
  /// added region and pruning the selected provinces that belonged
  /// to any removed region.
  void _onSelectedRegionsChanged(List<RegionEntity> newSelection) {
    final previousIds = _selectedRegions.map((r) => r.id ?? '').toSet();
    final newIds = newSelection.map((r) => r.id ?? '').toSet();

    final added =
        newSelection.where((r) => !previousIds.contains(r.id ?? '')).toList();
    final removedIds = previousIds.difference(newIds);

    setState(() {
      _selectedRegions = newSelection;

      // Drop any selected province whose region was removed so we
      // don't leave orphaned chips on the form.
      if (removedIds.isNotEmpty) {
        _selectedProvinces =
            _selectedProvinces
                .where(
                  (p) => p.regionId == null || !removedIds.contains(p.regionId),
                )
                .toList();
      }
    });

    // Kick off a province load for each newly added region.
    for (final region in added) {
      final regionId = region.id;
      if (regionId != null && regionId.isNotEmpty) {
        context.read<ProvinceBloc>().add(
          GetAllProvincesByRegionIdEvent(regionId),
        );
      }
    }
  }

  void _onSelectedProvincesChanged(List<ProvinceEntity> newSelection) {
    setState(() {
      _selectedProvinces = newSelection;
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
    );

    debugPrint('🚀 [CREATE VEHICLE] Dispatching CreateDeliveryVehicleEvent');
    context.read<DeliveryVehicleBloc>().add(
      CreateDeliveryVehicleEvent(vehicle),
    );
  }

  void _submitVehicleProfile(String deliveryVehicleId) {
    // Derive the legacy "designatedRegion" / "designatedProvince"
    // strings from the multi-select chip state so the existing
    // string fields stay populated (keeps backward compatibility
    // with any reads that use them).
    final regionDisplay = _selectedRegions
        .map((r) {
          final name = (r.name ?? '').trim();
          final alias = (r.alias ?? '').trim();
          return alias.isEmpty ? name : '$name - $alias';
        })
        .where((s) => s.isNotEmpty)
        .join(', ');
    final provinceDisplay = _selectedProvinces
        .map((p) => (p.name ?? '').trim())
        .where((s) => s.isNotEmpty)
        .join(', ');

    final profile = VehicleProfileModel(
      deliveryVehicleId: deliveryVehicleId,
      yearModel:
          _yearModelController.text.trim().isEmpty
              ? null
              : _yearModelController.text.trim(),
      designatedRegion: regionDisplay.isEmpty ? null : regionDisplay,
      designatedProvince: provinceDisplay.isEmpty ? null : provinceDisplay,
      designatedMunicipality:
          _designatedMunicipalityController.text.trim().isEmpty
              ? null
              : _designatedMunicipalityController.text.trim(),
      remarks:
          _remarksController.text.trim().isEmpty
              ? null
              : _remarksController.text.trim(),
      status: _status,
      // Attachments stored as `List<String>` in the model (the file
      // names – PocketBase receives the actual files separately).
      attachmentFiles:
          _attachments.isEmpty
              ? null
              : _attachments.map((f) => f.name).toList(),

      // Populate the assignedRegion / assignedProvince relation
      // fields on the vehicleProfile collection with the resolved
      // ids.
      assignedRegionIds:
          _selectedRegions
              .map((r) => r.id ?? '')
              .where((id) => id.isNotEmpty)
              .toList(),
      assignedProvinceIds:
          _selectedProvinces
              .map((p) => p.id ?? '')
              .where((id) => id.isNotEmpty)
              .toList(),
    );

    debugPrint(
      '🚀 [CREATE VEHICLE] Dispatching CreateVehicleProfileEvent '
      'for deliveryVehicleId=$deliveryVehicleId '
      'with ${_attachments.length} attachment(s) '
      'regions=${profile.assignedRegionIds} '
      'provinces=${profile.assignedProvinceIds}',
    );
    context.read<VehicleProfileBloc>().add(CreateVehicleProfileEvent(profile));
  }

  @override
  Widget build(BuildContext context) {
    final navigationItems =
        AppNavigationItems.vehicleManagementNavigationItems();

    return MultiBlocListener(
      listeners: [
        // -----------------------------------------------------------------
        // Listen for the RegionBloc result.
        // -----------------------------------------------------------------
        BlocListener<RegionBloc, RegionState>(
          listener: (context, state) {
            if (state is RegionsLoaded) {
              debugPrint(
                '✅ [CREATE VEHICLE] Loaded ${state.regions.length} regions',
              );
              setState(() {
                _regions = state.regions;
              });
            } else if (state is RegionError) {
              debugPrint(
                '❌ [CREATE VEHICLE] Region load error: ${state.message}',
              );
            }
          },
        ),
        // -----------------------------------------------------------------
        // Listen for the ProvinceBloc result – append to the existing
        // list so multi-region selections accumulate.
        // -----------------------------------------------------------------
        BlocListener<ProvinceBloc, ProvinceState>(
          listener: (context, state) {
            if (state is ProvincesByRegionLoaded) {
              debugPrint(
                '✅ [CREATE VEHICLE] Loaded '
                '${state.provinces.length} provinces for region ${state.regionId}',
              );
              setState(() {
                // Merge the freshly-loaded provinces with the
                // existing ones (avoid duplicates by id).
                final merged = <String, ProvinceEntity>{
                  for (final p in _provinces)
                    if (p.id != null) p.id!: p,
                  for (final p in state.provinces)
                    if (p.id != null) p.id!: p,
                };
                _provinces =
                    merged.values.toList()..sort(
                      (a, b) => (a.name ?? '').toLowerCase().compareTo(
                        (b.name ?? '').toLowerCase(),
                      ),
                    );
              });
            } else if (state is ProvinceError) {
              debugPrint(
                '❌ [CREATE VEHICLE] Province load error: ${state.message}',
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
              final id = state.vehicle.id;
              if (id == null || id.isEmpty) {
                setState(() {
                  _isLoading = false;
                  _errorMessage = 'Created vehicle has no id';
                });
                CoreUtils.showSnackBar(
                  context,
                  'Vehicle was created but came back without an id',
                );
                return;
              }
              // Proceed to step 2 (create the profile) with the new id.
              _submitVehicleProfile(id);
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
        // -----------------------------------------------------------------
        // Listen for the VehicleProfileBloc result.
        // -----------------------------------------------------------------
        BlocListener<VehicleProfileBloc, VehicleProfileState>(
          listener: (context, state) {
            if (!_isLoading) return;

            if (state is VehicleProfileCreated) {
              debugPrint(
                '✅ [CREATE VEHICLE] VehicleProfile created: '
                '${state.vehicleProfile.id}',
              );
              if (mounted && !_hasNavigated) {
                setState(() {
                  _isLoading = false;
                  _errorMessage = null;
                  _hasNavigated = true;
                });

                // Capture the messenger + theme + GoRouter BEFORE
                // the delay so the delayed callback doesn't use
                // `context` across an async gap (which would race
                // the widget being disposed during navigation).
                final messenger = ScaffoldMessenger.of(context);
                final textColor = Theme.of(context).colorScheme.surface;
                final bgColor = Theme.of(context).colorScheme.primary;
                final router = GoRouter.of(context);

                messenger.removeCurrentSnackBar();
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      'Vehicle and profile created successfully',
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

                // Give the snackbar a moment to render before we
                // navigate away — otherwise the user sometimes
                // never sees the "created" confirmation.
                Future.delayed(const Duration(milliseconds: 700), () {
                  if (!mounted) return;
                  router.go('/vehicle-list');
                });
              }
            } else if (state is VehicleProfileError) {
              debugPrint(
                '❌ [CREATE VEHICLE] VehicleProfile error: ${state.message}',
              );
              setState(() {
                _isLoading = false;
                _errorMessage = state.message;
              });
              CoreUtils.showSnackBar(
                context,
                'Vehicle was created, but the profile failed: ${state.message}',
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
              ),

              // -----------------------------------------------------------------
              // Section 2 – Vehicle Profile (always editable)
              // -----------------------------------------------------------------
              VehicleProfileForm(
                yearModelController: _yearModelController,
                designatedMunicipalityController:
                    _designatedMunicipalityController,
                remarksController: _remarksController,
                status: _status,
                onStatusChanged: (v) => setState(() => _status = v),
                attachments: _attachments,
                onAttachmentsChanged:
                    (files) => setState(() => _attachments = files),
                regions: _regions,
                selectedRegions: _selectedRegions,
                onSelectedRegionsChanged: _onSelectedRegionsChanged,
                provinces: _provinces,
                selectedProvinces: _selectedProvinces,
                onSelectedProvincesChanged: _onSelectedProvincesChanged,
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
