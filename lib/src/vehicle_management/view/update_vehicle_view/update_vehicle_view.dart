import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:xpro_delivery_admin_app/core/common/app/features/place_lookups/province/domain/entity/province_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/place_lookups/province/presentation/bloc/province_bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/place_lookups/province/presentation/bloc/province_event.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/place_lookups/province/presentation/bloc/province_state.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/place_lookups/region/domain/entity/region_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/place_lookups/region/presentation/bloc/region_bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/place_lookups/region/presentation/bloc/region_event.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/place_lookups/region/presentation/bloc/region_state.dart';

import 'package:xpro_delivery_admin_app/core/common/app/features/trip_ticket/delivery_vehicle_data/data/model/delivery_vehicle_model.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/trip_ticket/delivery_vehicle_data/presentation/bloc/delivery_vehicle_bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/trip_ticket/delivery_vehicle_data/presentation/bloc/delivery_vehicle_event.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/trip_ticket/delivery_vehicle_data/presentation/bloc/delivery_vehicle_state.dart';

import 'package:xpro_delivery_admin_app/core/common/app/features/vehicle/vehicle_profile/data/model/vehicle_profile_model.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/vehicle/vehicle_profile/domain/entity/vehicle_profile_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/vehicle/vehicle_profile/presentation/bloc/vehicle_profile_event.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/vehicle/vehicle_profile/presentation/bloc/vehicle_profile_state.dart';

import 'package:xpro_delivery_admin_app/core/common/widgets/app_structure/desktop_layout.dart';
import 'package:xpro_delivery_admin_app/core/common/widgets/create_screen_widgets/form_buttons.dart';
import 'package:xpro_delivery_admin_app/core/common/widgets/create_screen_widgets/form_layout.dart';
import 'package:xpro_delivery_admin_app/core/common/widgets/reusable_widgets/app_navigation_items.dart';
import 'package:xpro_delivery_admin_app/core/enums/vehicle_status.dart';
import 'package:xpro_delivery_admin_app/core/services/core_utils.dart';

import '../../../../core/common/app/features/trip_ticket/delivery_vehicle_data/domain/enitity/delivery_vehicle_entity.dart';
import '../../../../core/common/app/features/vehicle/vehicle_profile/presentation/bloc/vehicle_profile_bloc.dart';
import '../../widgets/update_vehicle_widgets/update_vehicle_form.dart';

/// "Update Vehicle" form that updates BOTH records on submit:
///
///   1. A `DeliveryVehicleModel` (via the `UpdateDeliveryVehicle`
///      usecase).
///   2. A `VehicleProfileModel` (via the `UpdateVehicleProfile`
///      usecase).
///
/// The Region / Province dropdowns are backed by the live
/// `RegionBloc` / `ProvinceBloc`. Both dropdowns support
/// multi-select — the selected items appear as removable chips
/// beneath each dropdown, just like in the trip-ticket create
/// forms. The existing regions/provinces are pre-populated from
/// the loaded vehicle profile once both data sources (regions +
/// profile) are available.
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

  // ---------------- Vehicle Profile controllers ----------------
  final _yearModelController = TextEditingController();
  final _designatedMunicipalityController = TextEditingController();
  final _remarksController = TextEditingController();
  VehicleStatus _status = VehicleStatus.goodCondition;
  List<XFile> _attachments = const [];

  // ---------------- Flow state ----------------
  bool _isLoading = false;
  bool _isInitializing = true;
  String? _errorMessage;
  bool _hasNavigated = false;

  /// True once both the delivery vehicle and its profile have been
  /// loaded into the form. Used to disable the submit button until
  /// the initial fetch has completed.
  bool _ready = false;

  /// Holds the id of the loaded vehicle profile so the follow-up
  /// `UpdateVehicleProfileEvent` can target the correct record.
  String? _vehicleProfileId;

  /// Holds the original delivery vehicle id (the one we were loaded
  /// with) for navigation after a successful update.
  late final String _initialDeliveryVehicleId = widget.deliveryVehicleId;

  // ---------------- Cached region / province data ----------------
  List<RegionEntity> _regions = const [];
  List<ProvinceEntity> _provinces = const [];
  List<RegionEntity> _selectedRegions = const [];
  List<ProvinceEntity> _selectedProvinces = const [];

  /// Raw region labels we pulled from PocketBase. We defer
  /// matching against the loaded regions list until both the
  /// regions AND the profile have arrived, so we don't pre-populate
  /// with a stale match.
  List<String> _pendingRegionLabels = const [];

  /// Raw province labels we pulled from PocketBase.
  List<String> _pendingProvinceLabels = const [];

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
    _yearModelController.dispose();
    _designatedMunicipalityController.dispose();
    _remarksController.dispose();
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

    // Fetch the vehicle profile keyed on the delivery vehicle id.
    context.read<VehicleProfileBloc>().add(
      GetVehicleProfileByDeliveryVehicleIdEvent(widget.deliveryVehicleId),
    );

    // Kick off the regions load for the dropdowns.
    context.read<RegionBloc>().add(const GetAllRegionsEvent());
  }

  void _populateFromVehicle(DeliveryVehicleEntity vehicle) {
    _nameController.text = vehicle.name ?? '';
    _plateNoController.text = vehicle.plateNo ?? '';
    _wheelsController.text = vehicle.wheels ?? '';
    _volumeCapacity = vehicle.volumeCapacity;
    _weightCapacity = vehicle.weightCapacity;

    // `make` and `type` are stored in PocketBase as the all-caps enum
    // label (see VehicleDataForm). We restore them as-is into the
    // controllers; VehicleDataForm's case-insensitive lookup will
    // re-hydrate the dropdown.
    _makeController.text = vehicle.make ?? '';
    _typeController.text = vehicle.type ?? '';
  }

  void _populateFromProfile(VehicleProfileEntity profile) {
    _vehicleProfileId = profile.id;
    _yearModelController.text = profile.yearModel ?? '';

    // Defer matching region/province labels against the loaded
    // regions/provinces list until both data sources are present.
    _pendingRegionLabels = _splitLabels(profile.designatedRegion);
    _pendingProvinceLabels = _splitLabels(profile.designatedProvince);

    _designatedMunicipalityController.text =
        profile.designatedMunicipality ?? '';
    _remarksController.text = profile.remarks ?? '';
    _status = profile.status ?? VehicleStatus.goodCondition;

    // Attachments: the model stores file *names*; we don't have the
    // original XFile objects, so the picker will just show the
    // current names. The user can add/remove as needed.
    _attachments = const [];

    _tryResolvePendingSelections();
  }

  /// Split a comma-separated legacy label string into a list of
  /// trimmed, non-empty labels.
  List<String> _splitLabels(String? raw) {
    if (raw == null || raw.trim().isEmpty) return const [];
    return raw
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  /// Match the pending region/province labels against the loaded
  /// regions/provinces list and trigger a province load for the
  /// matched regions. Safe to call multiple times — only acts
  /// once both data sources have arrived.
  void _tryResolvePendingSelections() {
    if (_regions.isEmpty || _pendingRegionLabels.isEmpty) return;

    final matchedRegions = <RegionEntity>[];
    final remainingLabels = <String>[];

    for (final label in _pendingRegionLabels) {
      RegionEntity? match;
      for (final r in _regions) {
        final display = _formatRegion(r);
        if (display == label ||
            (r.name ?? '').trim() == label ||
            (r.alias ?? '').trim() == label) {
          match = r;
          break;
        }
      }
      if (match != null) {
        matchedRegions.add(match);
      } else {
        debugPrint(
          '⚠️ [UPDATE VEHICLE] Could not match stored region '
          '"$label" against any loaded region',
        );
        remainingLabels.add(label);
      }
    }

    _pendingRegionLabels = remainingLabels;

    if (matchedRegions.isNotEmpty) {
      setState(() {
        _selectedRegions = matchedRegions;
      });
      // Load provinces for each matched region.
      for (final r in matchedRegions) {
        final regionId = r.id;
        if (regionId != null && regionId.isNotEmpty) {
          context.read<ProvinceBloc>().add(
            GetAllProvincesByRegionIdEvent(regionId),
          );
        }
      }
    }
  }

  /// Called by the form when the user adds/removes a region. The
  /// parent loads provinces for any newly-added region and prunes
  /// the selected provinces that belonged to any removed region.
  void _onSelectedRegionsChanged(List<RegionEntity> newSelection) {
    final previousIds = _selectedRegions.map((r) => r.id ?? '').toSet();
    final newIds = newSelection.map((r) => r.id ?? '').toSet();

    final added =
        newSelection.where((r) => !previousIds.contains(r.id ?? '')).toList();
    final removedIds = previousIds.difference(newIds);

    setState(() {
      _selectedRegions = newSelection;

      // Drop selected provinces whose region was removed.
      if (removedIds.isNotEmpty) {
        _selectedProvinces =
            _selectedProvinces
                .where(
                  (p) => p.regionId == null || !removedIds.contains(p.regionId),
                )
                .toList();
      }
    });

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

  /// Apply the pending province labels once their provinces list
  /// has loaded. Called from the ProvinceBloc listener.
  void _applyPendingProvinces() {
    if (_pendingProvinceLabels.isEmpty) return;
    if (_provinces.isEmpty) return;

    final matched = <ProvinceEntity>[];
    final remaining = <String>[];

    for (final label in _pendingProvinceLabels) {
      ProvinceEntity? match;
      for (final p in _provinces) {
        if ((p.name ?? '').trim() == label.trim()) {
          match = p;
          break;
        }
      }
      if (match != null) {
        matched.add(match);
      } else {
        remaining.add(label);
      }
    }

    _pendingProvinceLabels = remaining;

    if (matched.isNotEmpty) {
      setState(() {
        // Merge with whatever the user has already selected so we
        // don't clobber any in-progress edits.
        final existingIds = _selectedProvinces.map((p) => p.id ?? '').toSet();
        for (final p in matched) {
          if (p.id != null && !existingIds.contains(p.id)) {
            _selectedProvinces = [..._selectedProvinces, p];
          }
        }
      });
    }
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

  void _submitVehicleProfile() {
    final profileId = _vehicleProfileId;

    // The model carries every field the user filled in; we just
    // need to make sure the deliveryVehicleData relation is set
    // so the create fallback in the datasource (used when no
    // profile exists yet) links the new record to this vehicle.
    final deliveryVehicleId =
        profileId == null || profileId.isEmpty
            ? widget.deliveryVehicleId
            : profileId;

    if (profileId == null || profileId.isEmpty) {
      debugPrint(
        '⚠️ [UPDATE VEHICLE] No profile is linked to this vehicle yet — '
        'the datasource will CREATE a fresh one.',
      );
    }

    final regionDisplay = _selectedRegions
        .map(_formatRegion)
        .where((s) => s.isNotEmpty)
        .join(', ');
    final provinceDisplay = _selectedProvinces
        .map((p) => (p.name ?? '').trim())
        .where((s) => s.isNotEmpty)
        .join(', ');

    final profile = VehicleProfileModel(
      // `id` is null when the profile doesn't exist yet – the
      // datasource will use it as a "create" signal.
      id: profileId,
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
      attachmentFiles:
          _attachments.isEmpty
              ? null
              : _attachments.map((f) => f.name).toList(),

      // Re-sync the relation ids so PocketBase stays consistent
      // with the dropdown choices.
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
      '🚀 [UPDATE VEHICLE] Dispatching UpdateVehicleProfileEvent '
      'for deliveryVehicleId=$deliveryVehicleId '
      'profileId=$profileId with ${_attachments.length} attachment(s) '
      'regions=${profile.assignedRegionIds} '
      'provinces=${profile.assignedProvinceIds}',
    );
    context.read<VehicleProfileBloc>().add(
      UpdateVehicleProfileEvent(
        id: deliveryVehicleId,
        updatedVehicleProfile: profile,
      ),
    );
  }

  /// Render a region as "name - alias" (e.g.
  /// "Region III - Central Luzon"). Falls back to just the name
  /// when no alias is available.
  static String _formatRegion(RegionEntity? region) {
    if (region == null) return '';
    final name = (region.name ?? '').trim();
    final alias = (region.alias ?? '').trim();
    if (alias.isEmpty) return name;
    return '$name - $alias';
  }

  /// Mark the form ready to submit once both loaders have reported
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
                '✅ [UPDATE VEHICLE] Loaded ${state.regions.length} regions',
              );
              setState(() {
                _regions = state.regions;
              });
              _tryResolvePendingSelections();
            } else if (state is RegionError) {
              debugPrint(
                '❌ [UPDATE VEHICLE] Region load error: ${state.message}',
              );
            }
          },
        ),
        // -----------------------------------------------------------------
        // Listen for the ProvinceBloc result — accumulate provinces for
        // each region into one shared list.
        // -----------------------------------------------------------------
        BlocListener<ProvinceBloc, ProvinceState>(
          listener: (context, state) {
            if (state is ProvincesByRegionLoaded) {
              debugPrint(
                '✅ [UPDATE VEHICLE] Loaded '
                '${state.provinces.length} provinces for region ${state.regionId}',
              );
              setState(() {
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
              _applyPendingProvinces();
            } else if (state is ProvinceError) {
              debugPrint(
                '❌ [UPDATE VEHICLE] Province load error: ${state.message}',
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
              // Proceed to step 2 (update the profile).
              _submitVehicleProfile();
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
        // -----------------------------------------------------------------
        // Listen for the VehicleProfileBloc result.
        // -----------------------------------------------------------------
        BlocListener<VehicleProfileBloc, VehicleProfileState>(
          listener: (context, state) {
            // Initial load: re-hydrate the profile controllers.
            if (_isInitializing) {
              final candidate =
                  state is VehicleProfileByDeliveryVehicleIdLoaded
                      ? state.vehicleProfile
                      : state is VehicleProfileByIdLoaded
                      ? state.vehicleProfile
                      : null;
              if (candidate != null) {
                _populateFromProfile(candidate);
                _tryMarkReady();
              }
              return;
            }

            if (!_isLoading) return;

            if (state is VehicleProfileUpdated) {
              debugPrint(
                '✅ [UPDATE VEHICLE] VehicleProfile updated: '
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
                final vehicleRoute = '/vehicle-id/$_initialDeliveryVehicleId';

                messenger.removeCurrentSnackBar();
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      'Vehicle and profile updated successfully',
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
                // never sees the "updated" confirmation.
                Future.delayed(const Duration(milliseconds: 700), () {
                  if (!mounted) return;
                  router.go(vehicleRoute);
                });
              }
            } else if (state is VehicleProfileError) {
              debugPrint(
                '❌ [UPDATE VEHICLE] VehicleProfile error: ${state.message}',
              );
              setState(() {
                _isLoading = false;
                _errorMessage = state.message;
              });
              CoreUtils.showSnackBar(
                context,
                'Vehicle was updated, but the profile failed: ${state.message}',
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
                // Vehicle Data
                nameController: _nameController,
                plateNoController: _plateNoController,
                makeController: _makeController,
                typeController: _typeController,
                wheelsController: _wheelsController,
                volumeCapacity: _volumeCapacity,
                weightCapacity: _weightCapacity,
                onVolumeCapacityChanged: (v) => _volumeCapacity = v?.toDouble(),
                onWeightCapacityChanged: (v) => _weightCapacity = v?.toDouble(),

                // Vehicle Profile
                yearModelController: _yearModelController,
                designatedMunicipalityController:
                    _designatedMunicipalityController,
                remarksController: _remarksController,
                status: _status,
                onStatusChanged: (v) => setState(() => _status = v),
                attachments: _attachments,
                onAttachmentsChanged:
                    (files) => setState(() => _attachments = files),

                // Multi-select region / province dropdowns
                regions: _regions,
                selectedRegions: _selectedRegions,
                onSelectedRegionsChanged: _onSelectedRegionsChanged,
                provinces: _provinces,
                selectedProvinces: _selectedProvinces,
                onSelectedProvincesChanged: _onSelectedProvincesChanged,

                // Error banner
                errorMessage: _errorMessage,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
