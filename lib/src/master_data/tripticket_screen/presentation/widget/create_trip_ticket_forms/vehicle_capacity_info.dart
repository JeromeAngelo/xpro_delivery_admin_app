import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/trip_ticket/delivery_data/domain/entity/delivery_data_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/trip_ticket/delivery_data/presentation/bloc/delivery_data_bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/trip_ticket/delivery_data/presentation/bloc/delivery_data_event.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/trip_ticket/delivery_data/presentation/bloc/delivery_data_state.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/trip_ticket/delivery_vehicle_data/domain/enitity/delivery_vehicle_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/trip_ticket/delivery_vehicle_data/presentation/bloc/delivery_vehicle_bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/trip_ticket/delivery_vehicle_data/presentation/bloc/delivery_vehicle_event.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/trip_ticket/delivery_vehicle_data/presentation/bloc/delivery_vehicle_state.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/vehicle/vehicle_profile/presentation/bloc/vehicle_profile_bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/vehicle/vehicle_profile/presentation/bloc/vehicle_profile_state.dart';
import 'package:xpro_delivery_admin_app/core/enums/vehicle_status.dart';

class VehicleCapacityInfo extends StatelessWidget {
  final DeliveryVehicleEntity? vehicle;

  const VehicleCapacityInfo({super.key, this.vehicle});

  @override
  Widget build(BuildContext context) {
    // If no vehicle is selected, show instruction message
    if (vehicle == null) {
      return _buildNoVehicleSelectedMessage(context);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // -----------------------------------------------------------------
        // Card 1 – Vehicle Profile
        //   Renders the profile fields fetched through the
        //   GetVehicleProfileByDeliveryVehicleIdEvent:
        //     - designated municipality
        //     - designated province
        //     - status (colored chip)
        //   When no profile is associated with the selected vehicle we
        //   show a friendly placeholder ("No vehicle profile yet").
        // -----------------------------------------------------------------
        _buildProfileCard(context),

        const SizedBox(height: 16),

        // -----------------------------------------------------------------
        // Card 2 –
        //   Renders the weight / volume circular indicators plus the
        //   overload warning.
        // -----------------------------------------------------------------
        _buildCapacityCard(context),
      ],
    );
  }

  /// Builds the standalone "Vehicle Profile" card.
  Widget _buildProfileCard(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: BlocBuilder<DeliveryVehicleBloc, DeliveryVehicleState>(
        builder: (context, vehicleState) {
          if (vehicleState is DeliveryVehicleLoading) {
            return _buildCardLoading(context, 'Loading vehicle details...');
          }

          if (vehicleState is DeliveryVehicleError) {
            return _buildCardError(
              context,
              icon: Icons.error_outline,
              message: vehicleState.message,
              onRetry: () {
                context.read<DeliveryVehicleBloc>().add(
                  LoadDeliveryVehicleByIdEvent(vehicle!.id ?? ''),
                );
              },
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildCardHeader(
                  context,
                  icon: Icons.assignment_ind_outlined,
                  title: 'Vehicle Profile',
                  trailing:
                      BlocBuilder<VehicleProfileBloc, VehicleProfileState>(
                        builder: (context, state) {
                          final profile = _extractProfile(state);
                          if (profile == null) return const SizedBox.shrink();
                          return _buildVehicleStatusChip(profile.status);
                        },
                      ),
                ),
                const SizedBox(height: 12),
                _buildProfileSection(context),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Builds the standalone "Vehicle Capacity" card.
  Widget _buildCapacityCard(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: BlocBuilder<DeliveryVehicleBloc, DeliveryVehicleState>(
          builder: (context, vehicleState) {
            if (vehicleState is DeliveryVehicleLoading) {
              return _buildCardLoading(context, 'Loading vehicle details...');
            }

            if (vehicleState is DeliveryVehicleError) {
              return _buildCardError(
                context,
                icon: Icons.error_outline,
                message: vehicleState.message,
                onRetry: () {
                  context.read<DeliveryVehicleBloc>().add(
                    LoadDeliveryVehicleByIdEvent(vehicle!.id ?? ''),
                  );
                },
              );
            }

            // Get the detailed vehicle data
            final vehicleData =
                vehicleState is DeliveryVehicleLoaded
                    ? vehicleState.vehicle
                    : vehicle;

            return BlocBuilder<DeliveryDataBloc, DeliveryDataState>(
              builder: (context, deliveryState) {
                if (deliveryState is DeliveryDataLoading) {
                  return _buildCardLoading(context, 'Loading delivery data...');
                }

                if (deliveryState is DeliveryDataError) {
                  return _buildCardError(
                    context,
                    icon: Icons.error_outline,
                    message: deliveryState.message,
                    onRetry: () {
                      context.read<DeliveryDataBloc>().add(
                        const GetAllDeliveryDataEvent(),
                      );
                    },
                  );
                }

                // Get the unassigned deliveries
                final List<DeliveryDataEntity> unassignedDeliveries =
                    deliveryState is AllDeliveryDataLoaded
                        ? deliveryState.deliveryData
                        : [];

                // Calculate capacity metrics
                final capacityData = _calculateCapacity(
                  vehicleData!,
                  unassignedDeliveries,
                );

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCardHeader(
                      context,
                      icon: Icons.local_shipping_outlined,
                      title: 'Vehicle Capacity',
                      subtitle:
                          '${vehicleData.name ?? ''} ${vehicleData.plateNo ?? ''}'
                              .trim(),
                    ),
                    const SizedBox(height: 16),

                    // Capacity indicators using circular progress
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Weight capacity circular indicator
                        _buildCircularCapacityIndicator(
                          context: context,
                          title: 'Weight',
                          current: capacityData['totalWeight'],
                          max: vehicleData.weightCapacity ?? 0,
                          unit: 'tn',
                          percentage: capacityData['weightPercentage'],
                          isOverloaded: capacityData['isWeightOverloaded'],
                          icon: Icons.scale_sharp,
                        ),

                        // Volume capacity circular indicator
                        _buildCircularCapacityIndicator(
                          context: context,
                          title: 'Volume',
                          current: capacityData['totalVolume'],
                          max: vehicleData.volumeCapacity ?? 0,
                          unit: 'm³',
                          percentage: capacityData['volumePercentage'],
                          isOverloaded: capacityData['isVolumeOverloaded'],
                          icon: Icons.category,
                        ),
                      ],
                    ),

                    // Warning message if overloaded
                    if (capacityData['isOverloaded']) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.warning_amber_rounded,
                              color: Colors.red.shade700,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Warning: This vehicle will be overloaded with the selected deliveries.',
                                style: TextStyle(
                                  color: Colors.red.shade700,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Shared building blocks
  // ---------------------------------------------------------------------

  /// Header used by both cards (icon + title + optional subtitle/trailing).
  Widget _buildCardHeader(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 20, color: Theme.of(context).primaryColor),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              if (subtitle != null && subtitle.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) trailing,
      ],
    );
  }

  Widget _buildCardLoading(BuildContext context, String message) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(message),
          ],
        ),
      ),
    );
  }

  Widget _buildCardError(
    BuildContext context, {
    required IconData icon,
    required String message,
    required VoidCallback onRetry,
  }) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.red, size: 32),
            const SizedBox(height: 8),
            Text(
              'Error: $message',
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Vehicle Profile section
  //
  // Renders the profile fields fetched through the new
  // GetVehicleProfileByDeliveryVehicleIdEvent:
  //   - designated municipality
  //   - designated province
  //   - status (rendered as a colored chip)
  //
  // When no profile is associated with the selected vehicle we show a
  // friendly placeholder ("No vehicle profile yet").
  // ---------------------------------------------------------------------
  // ---------------------------------------------------------------------
  // Vehicle Profile body
  //
  // Renders the profile fields fetched through the
  // GetVehicleProfileByDeliveryVehicleIdEvent:
  //   - designated municipality
  //   - designated province
  //
  // (The status chip is now rendered as the card header's `trailing`
  //  widget so it sits at the top of the card.)
  // ---------------------------------------------------------------------
  Widget _buildProfileSection(BuildContext context) {
    return BlocBuilder<VehicleProfileBloc, VehicleProfileState>(
      builder: (context, profileState) {
        // Initial state – the user has not yet picked a vehicle, or the
        // BLoC has not yet been triggered.
        if (profileState is VehicleProfileInitial) {
          return _buildProfilePlaceholder(
            context,
            'Select a vehicle to view its profile',
          );
        }

        if (profileState is VehicleProfileLoading) {
          return Row(
            children: const [
              SizedBox(
                height: 16,
                width: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 8),
              Text('Loading vehicle profile...'),
            ],
          );
        }

        if (profileState is VehicleProfileError) {
          return _buildProfilePlaceholder(context, 'No vehicle profile yet');
        }

        final profile = _extractProfile(profileState);

        // Profile fetched but the server returned no record – show the
        // placeholder.
        if (profile == null) {
          return _buildProfilePlaceholder(context, 'No vehicle profile yet');
        }

        final municipality = _capitalizeFirst(
          _cleanRelationLabel(profile.designatedMunicipality),
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Assigned Region(s) – sourced from the new
            // `assignedRegions` relation list.
            _buildProfileRow(
              context,
              icon: Icons.map,
              label: 'Assigned Region(s)',
              value: _formatRegionsList(profile.assignedRegions),
            ),
            const SizedBox(height: 6),

            // Assigned Province(s) – sourced from the new
            // `assignedProvinces` relation list.
            _buildProfileRow(
              context,
              icon: Icons.location_on,
              label: 'Assigned Province(s)',
              value: _formatProvincesList(profile.assignedProvinces),
            ),
            const SizedBox(height: 6),

            _buildProfileRow(
              context,
              icon: Icons.location_city,
              label: 'Designated Municipality',
              value:
                  (municipality == null || municipality.isEmpty)
                      ? 'Not specified'
                      : municipality,
            ),
          ],
        );
      },
    );
  }

  /// Formats a list of [RegionEntity]-like objects as a comma-
  /// separated string of "`name` - `alias`" entries (e.g.
  /// `"Region I - Ilocos Region, Region III - Central Luzon"`).
  ///
  /// Returns the placeholder `'Not specified'` when the list is
  /// null or empty. Accepts `dynamic` so the helper works without
  /// having to import the `RegionEntity` class here.
  String _formatRegionsList(dynamic regions) {
    if (regions is! List || regions.isEmpty) return 'Not specified';
    final names = <String>[];
    for (final r in regions) {
      final name = (r.name ?? '').toString().trim();
      final alias = (r.alias ?? '').toString().trim();
      if (name.isEmpty && alias.isEmpty) continue;
      if (alias.isEmpty) {
        names.add(name);
      } else {
        names.add('$name - $alias');
      }
    }
    return names.isEmpty ? 'Not specified' : names.join(', ');
  }

  /// Formats a list of [ProvinceEntity]-like objects as a comma-
  /// separated string of province `name`s (e.g.
  /// `"Pampanga, Bulacan, Tarlac"`).
  ///
  /// Returns the placeholder `'Not specified'` when the list is
  /// null or empty.
  String _formatProvincesList(dynamic provinces) {
    if (provinces is! List || provinces.isEmpty) return 'Not specified';
    final names = <String>[];
    for (final p in provinces) {
      final name = (p.name ?? '').toString().trim();
      if (name.isNotEmpty) names.add(name);
    }
    return names.isEmpty ? 'Not specified' : names.join(', ');
  }

  /// Extracts the [VehicleProfileEntity] from any of the loaded states
  /// (either the "by id" or "by delivery vehicle data id" flavour).
  /// Returns `null` for all other states.
  dynamic _extractProfile(VehicleProfileState state) {
    if (state is VehicleProfileByDeliveryVehicleIdLoaded) {
      return state.vehicleProfile;
    }
    if (state is VehicleProfileByIdLoaded) {
      return state.vehicleProfile;
    }
    return null;
  }

  /// Strips the surrounding square brackets that PocketBase sometimes wraps
  /// relation-field values in (e.g. `[Pampanga]` → `Pampanga`). Also trims
  /// whitespace and returns `null` for empty / nullish input.
  String? _cleanRelationLabel(String? raw) {
    if (raw == null) return null;
    var value = raw.trim();
    if (value.isEmpty) return null;
    if (value.length >= 2 && value.startsWith('[') && value.endsWith(']')) {
      value = value.substring(1, value.length - 1).trim();
    }
    if (value.isEmpty) return null;
    return value;
  }

  /// Capitalises the very first character of [raw] while leaving the
  /// remaining characters untouched. Returns `null` for nullish input.
  String? _capitalizeFirst(String? raw) {
    if (raw == null || raw.isEmpty) return raw;
    return raw[0].toUpperCase() + raw.substring(1);
  }

  Widget _buildProfileRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade700),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: DefaultTextStyle.of(context).style.copyWith(fontSize: 13),
              children: [
                TextSpan(
                  text: '$label: ',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: value),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfilePlaceholder(BuildContext context, String message) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.grey.shade600, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a coloured status chip that reflects the [VehicleStatus] enum.
  Widget _buildVehicleStatusChip(VehicleStatus? status) {
    Color color;
    String label;
    IconData icon;

    switch (status) {
      case VehicleStatus.goodCondition:
        color = Colors.green;
        label = 'Good Condition';
        icon = Icons.verified;
        break;
      case VehicleStatus.underMaintenance:
        color = Colors.orange;
        label = 'Under Maintenance';
        icon = Icons.build;
        break;
      case VehicleStatus.inspectionRequired:
        color = Colors.amber.shade700;
        label = 'Inspection Required';
        icon = Icons.fact_check_outlined;
        break;
      case VehicleStatus.outOfService:
        color = Colors.red;
        label = 'Out of Service';
        icon = Icons.block;
        break;
      case VehicleStatus.retired:
        color = Colors.grey;
        label = 'Retired';
        icon = Icons.archive_outlined;
        break;
      default:
        color = Colors.blueGrey;
        label = 'Unknown';
        icon = Icons.help_outline;
    }

    return Chip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      backgroundColor: color,
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
      side: BorderSide.none,
    );
  }

  // Widget to show when no vehicle is selected
  Widget _buildNoVehicleSelectedMessage(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.local_shipping_outlined,
                size: 64,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                'Select a Vehicle',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Choose a vehicle from the dropdown to see capacity analysis',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade700),
              ),
              const SizedBox(height: 16),
              Text(
                'The capacity analysis will show if the vehicle can handle all unassigned deliveries',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCircularCapacityIndicator({
    required BuildContext context,
    required String title,
    required double current,
    required double max,
    required String unit,
    required double percentage,
    required bool isOverloaded,
    required IconData icon,
  }) {
    final color =
        isOverloaded
            ? Colors.red
            : percentage > 90
            ? Colors.orange
            : Theme.of(context).primaryColor;

    return Column(
      children: [
        // Title
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),

        // Circular progress with icon
        Stack(
          alignment: Alignment.center,
          children: [
            // Circular progress indicator
            SizedBox(
              height: 100,
              width: 100,
              child: CircularProgressIndicator(
                value: percentage / 100 > 1 ? 1 : percentage / 100,
                strokeWidth: 10,
                backgroundColor: Colors.grey.shade200,
                color: color,
              ),
            ),

            // Icon in the center
            Icon(icon, size: 32, color: color),

            // Percentage text below the icon
            Positioned(
              bottom: 20,
              child: Text(
                '${percentage.toStringAsFixed(0)}%',
                style: TextStyle(fontWeight: FontWeight.bold, color: color),
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // Current/Max text
        Text(
          '${current.toStringAsFixed(1)} / ${max.toStringAsFixed(1)} $unit',
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  Map<String, dynamic> _calculateCapacity(
    DeliveryVehicleEntity vehicle,
    List<DeliveryDataEntity> deliveries,
  ) {
    double totalWeight = 0;
    double totalVolume = 0;

    // Calculate total weight and volume from all deliveries
    for (final delivery in deliveries) {
      if (delivery.invoices != null && delivery.invoices!.isNotEmpty) {
        // Sum all invoices in the delivery
        for (final invoice in delivery.invoices!) {
          totalWeight += invoice.weight ?? 0;
          totalVolume += invoice.volume ?? 0;
        }
      } else if (delivery.invoice != null) {
        // Fallback to single invoice
        totalWeight += delivery.invoice!.weight ?? 0;
        totalVolume += delivery.invoice!.volume ?? 0;
      }
    }

    // Calculate percentages (handle division by zero)
    final weightCapacity = vehicle.weightCapacity ?? 0;
    final volumeCapacity = vehicle.volumeCapacity ?? 0;

    final weightPercentage =
        weightCapacity > 0 ? (totalWeight / weightCapacity) * 100 : 0;

    final volumePercentage =
        volumeCapacity > 0 ? (totalVolume / volumeCapacity) * 100 : 0;

    // Check if vehicle is overloaded
    final isWeightOverloaded = weightPercentage > 100;
    final isVolumeOverloaded = volumePercentage > 100;
    final isOverloaded = isWeightOverloaded || isVolumeOverloaded;

    return {
      'totalWeight': totalWeight,
      'totalVolume': totalVolume,
      'weightPercentage': weightPercentage,
      'volumePercentage': volumePercentage,
      'isWeightOverloaded': isWeightOverloaded,
      'isVolumeOverloaded': isVolumeOverloaded,
      'isOverloaded': isOverloaded,
    };
  }
}
