import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/trip_ticket/delivery_vehicle_data/data/model/delivery_vehicle_model.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/trip_ticket/delivery_data/data/model/delivery_data_model.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/trip_ticket/delivery_data/presentation/bloc/delivery_data_bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/trip_ticket/delivery_vehicle_data/presentation/bloc/delivery_vehicle_bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/vehicle/vehicle_profile/presentation/bloc/vehicle_profile_bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/vehicle/vehicle_profile/presentation/bloc/vehicle_profile_event.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/vehicle/vehicle_tags/domain/entity/vehicle_tag_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/vehicle/vehicle_tags/presentation/bloc/vehicle_tag_bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/vehicle/vehicle_tags/presentation/bloc/vehicle_tag_event.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/vehicle/vehicle_tags/presentation/bloc/vehicle_tag_state.dart';
import 'package:xpro_delivery_admin_app/core/enums/vehicle_status.dart';
import 'package:xpro_delivery_admin_app/core/enums/vehicle_tags_enums.dart';
import 'vehicle_capacity_info.dart';

class VehicleSelectionDialog extends StatefulWidget {
  final List<DeliveryVehicleModel> availableVehicles;
  final List<DeliveryVehicleModel> selectedVehicles;
  final List<DeliveryDataModel> selectedDeliveries;
  final Function(List<DeliveryVehicleModel>) onVehiclesChanged;
  final Function(DeliveryVehicleModel?) onVehicleSelectedForCapacityCheck;

  const VehicleSelectionDialog({
    super.key,
    required this.availableVehicles,
    required this.selectedVehicles,
    this.selectedDeliveries = const [],
    required this.onVehiclesChanged,
    required this.onVehicleSelectedForCapacityCheck,
  });

  @override
  State<VehicleSelectionDialog> createState() => _VehicleSelectionDialogState();
}

class _VehicleSelectionDialogState extends State<VehicleSelectionDialog> {
  String _searchQuery = '';
  String? _selectedTagLabel;
  DeliveryVehicleModel? _selectedVehicle;

  @override
  void initState() {
    super.initState();
    // Load all vehicle tags so the filter dropdown can show every tag,
    // not only tags already attached to the listed vehicles.
    context.read<VehicleTagBloc>().add(const GetVehicleTagsEvent());

    // Initialize with first available vehicle if any
    if (widget.availableVehicles.isNotEmpty) {
      _selectedVehicle = widget.availableVehicles.first;
      // Fire the vehicle-profile lookup for the initially-selected vehicle
      _fetchVehicleProfile(_selectedVehicle);
    }
  }

  /// Dispatch the new `GetVehicleProfileByDeliveryVehicleIdEvent` so that the
  /// VehicleCapacityInfo widget can render the corresponding profile fields
  /// (designated municipality, designated province, status chip).
  void _fetchVehicleProfile(DeliveryVehicleModel? vehicle) {
    if (vehicle == null || vehicle.id == null || vehicle.id!.isEmpty) {
      return;
    }
    // Use the addPostFrameCallback to make sure we dispatch only after the
    // dialog's widget tree is mounted.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      try {
        context.read<VehicleProfileBloc>().add(
          GetVehicleProfileByDeliveryVehicleIdEvent(vehicle.id!),
        );
      } catch (_) {
        // Bloc not available in this subtree – ignore.
      }
    });
  }

  /// Total weight and volume of the currently selected deliveries.
  Map<String, double> get _deliveryTotals {
    double totalWeight = 0;
    double totalVolume = 0;

    for (final delivery in widget.selectedDeliveries) {
      final invoices = delivery.invoices;
      if (invoices != null && invoices.isNotEmpty) {
        for (final invoice in invoices) {
          totalWeight += invoice.weight ?? 0;
          totalVolume += invoice.volume ?? 0;
        }
      } else if (delivery.invoice != null) {
        totalWeight += delivery.invoice!.weight ?? 0;
        totalVolume += delivery.invoice!.volume ?? 0;
      }
    }

    return {'weight': totalWeight, 'volume': totalVolume};
  }

  /// Score a vehicle by how well it fits the selected deliveries.
  /// Lower score = better fit. Vehicles that cannot carry the load are
  /// pushed to the end.
  double _fitScore(
    DeliveryVehicleModel vehicle,
    double totalWeight,
    double totalVolume,
  ) {
    final weightCapacity = vehicle.weightCapacity ?? 0;
    final volumeCapacity = vehicle.volumeCapacity ?? 0;

    // If no deliveries selected, prefer larger capacity vehicles first.
    if (totalWeight == 0 && totalVolume == 0) {
      return -(weightCapacity + volumeCapacity);
    }

    final weightRatio =
        weightCapacity > 0 ? totalWeight / weightCapacity : double.infinity;
    final volumeRatio =
        volumeCapacity > 0 ? totalVolume / volumeCapacity : double.infinity;

    // Vehicle cannot handle either dimension -> large penalty.
    if (weightRatio > 1 || volumeRatio > 1) {
      return 1000 + weightRatio + volumeRatio;
    }

    // Prefer the tightest fit that still has some headroom.
    // A ratio near 0.85 is ideal (efficient but not overloaded).
    final weightScore = (weightRatio - 0.85).abs();
    final volumeScore = (volumeRatio - 0.85).abs();

    return weightScore + volumeScore;
  }

  List<DeliveryVehicleModel> get filteredVehicles {
    final query = _searchQuery.toLowerCase().trim();

    // Apply search filter
    var results =
        query.isEmpty
            ? widget.availableVehicles
            : widget.availableVehicles.where((vehicle) {
              final plateNo = vehicle.plateNo?.toLowerCase() ?? '';
              final make = vehicle.make?.toLowerCase() ?? '';
              final name = vehicle.name?.toLowerCase() ?? '';
              return plateNo.contains(query) ||
                  make.contains(query) ||
                  name.contains(query);
            }).toList();

    // Apply tag label filter if selected
    if (_selectedTagLabel != null && _selectedTagLabel!.isNotEmpty) {
      final tagFiltered =
          results.where((vehicle) {
            return vehicle.vehicleTags?.any(
                  (tag) => tag.label == _selectedTagLabel,
                ) ??
                false;
          }).toList();

      // If no vehicles match the tag filter, fall back to showing all
      // vehicles (ignoring the tag filter) so the user isn't left empty.
      if (tagFiltered.isNotEmpty) {
        results = tagFiltered;
      }
    }

    // Sort by best fit for the selected deliveries
    final totals = _deliveryTotals;
    results.sort((a, b) {
      final scoreA = _fitScore(a, totals['weight']!, totals['volume']!);
      final scoreB = _fitScore(b, totals['weight']!, totals['volume']!);
      return scoreA.compareTo(scoreB);
    });

    return results;
  }

  /// Returns all tag labels from the VehicleTagBloc state, falling back to
  /// labels found on the available vehicles if the BLoC hasn't loaded yet.
  List<String> _getAllTagLabels(VehicleTagState tagState) {
    final labels = <String>{};
    if (tagState is VehicleTagsLoaded) {
      for (final tag in tagState.vehicleTags) {
        if (tag.label != null && tag.label!.isNotEmpty) {
          labels.add(tag.label!);
        }
      }
    }
    // Fallback: labels from currently available vehicles
    for (final vehicle in widget.availableVehicles) {
      for (final tag in vehicle.vehicleTags ?? []) {
        if (tag.label != null && tag.label!.isNotEmpty) {
          labels.add(tag.label!);
        }
      }
    }
    return labels.toList()..sort();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 1200,
        height: 700,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Select Vehicle',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Search bar + filter
            Row(
              children: [
                SizedBox(
                  width: 400,
                  child: TextField(
                    style: const TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      hintText: 'Search vehicles...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                BlocBuilder<VehicleTagBloc, VehicleTagState>(
                  builder: (context, tagState) {
                    return _buildTagFilterDropdown(tagState);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Main content - Left: Vehicle List, Right: Capacity Info
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left side - Vehicle List
                  Expanded(
                    flex: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(8),
                                topRight: Radius.circular(8),
                              ),
                            ),
                            child: Text(
                              'Available Vehicles',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ),
                          Expanded(
                            child:
                                filteredVehicles.isEmpty
                                    ? Center(
                                      child: Text(
                                        'No vehicles found',
                                        style: TextStyle(
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.error,
                                        ),
                                      ),
                                    )
                                    : ListView.builder(
                                      itemCount: filteredVehicles.length,
                                      itemBuilder: (context, index) {
                                        final vehicle = filteredVehicles[index];
                                        final isSelected =
                                            _selectedVehicle?.id == vehicle.id;

                                        return Container(
                                          margin: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          child: Card(
                                            color:
                                                isSelected
                                                    ? Colors.blue.shade50
                                                    : Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              side: BorderSide(
                                                color:
                                                    isSelected
                                                        ? Colors.blue
                                                        : Colors.grey.shade300,
                                                width: isSelected ? 2 : 1,
                                              ),
                                            ),
                                            child: InkWell(
                                              onTap: () {
                                                setState(() {
                                                  _selectedVehicle = vehicle;
                                                });
                                                _fetchVehicleProfile(vehicle);
                                              },
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child: Padding(
                                                padding: const EdgeInsets.all(
                                                  12,
                                                ),
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    // Leading avatar
                                                    CircleAvatar(
                                                      backgroundColor: Colors
                                                          .blue
                                                          .withOpacity(0.1),
                                                      child: const Icon(
                                                        Icons.local_shipping,
                                                        color: Colors.blue,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 12),

                                                    // Main content
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          // Header row: name + tag badges
                                                          Row(
                                                            children: [
                                                              Expanded(
                                                                child: Text(
                                                                  vehicle.plateNo ??
                                                                      '${vehicle.make} ${vehicle.name}',
                                                                  style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        15,
                                                                    color:
                                                                        isSelected
                                                                            ? Colors.blue.shade700
                                                                            : Colors.black,
                                                                  ),
                                                                ),
                                                              ),
                                                              if (vehicle.vehicleTags !=
                                                                      null &&
                                                                  vehicle
                                                                      .vehicleTags!
                                                                      .isNotEmpty)
                                                                _buildTagBadges(
                                                                  vehicle
                                                                      .vehicleTags!,
                                                                ),
                                                            ],
                                                          ),
                                                          const SizedBox(
                                                            height: 6,
                                                          ),

                                                          // Specs row
                                                          Wrap(
                                                            spacing: 12,
                                                            runSpacing: 4,
                                                            children: [
                                                              _buildSpecChip(
                                                                icon:
                                                                    Icons
                                                                        .business,
                                                                label:
                                                                    'Make: ${vehicle.make ?? 'Unknown'}',
                                                              ),
                                                              _buildSpecChip(
                                                                icon:
                                                                    Icons
                                                                        .directions_car,
                                                                label:
                                                                    'Model: ${vehicle.name ?? 'Unknown'}',
                                                              ),
                                                              if (vehicle
                                                                      .weightCapacity !=
                                                                  null)
                                                                _buildSpecChip(
                                                                  icon:
                                                                      Icons
                                                                          .scale,
                                                                  label:
                                                                      'Weight: ${vehicle.weightCapacity} kg',
                                                                ),
                                                              if (vehicle
                                                                      .volumeCapacity !=
                                                                  null)
                                                                _buildSpecChip(
                                                                  icon:
                                                                      Icons
                                                                          .category,
                                                                  label:
                                                                      'Volume: ${vehicle.volumeCapacity} m³',
                                                                ),
                                                            ],
                                                          ),
                                                          const SizedBox(
                                                            height: 8,
                                                          ),

                                                          // Status chips
                                                          Row(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets.only(
                                                                      top: 4,
                                                                    ),
                                                                child: Text(
                                                                  'Status:',
                                                                  style: TextStyle(
                                                                    fontSize:
                                                                        12,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color:
                                                                        Colors
                                                                            .grey
                                                                            .shade700,
                                                                  ),
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                width: 6,
                                                              ),
                                                              Expanded(
                                                                child: Wrap(
                                                                  spacing: 6,
                                                                  runSpacing: 6,
                                                                  children: [
                                                                    if (vehicle
                                                                            .isAssignedTrip ==
                                                                        false)
                                                                      _buildStatusChip(
                                                                        label:
                                                                            'No trip assigned yet',
                                                                        color:
                                                                            Colors.orange,
                                                                        icon:
                                                                            Icons.assignment_late_outlined,
                                                                      ),
                                                                    if (vehicle
                                                                            .status !=
                                                                        null)
                                                                      _buildStatusChip(
                                                                        label: _statusLabel(
                                                                          vehicle
                                                                              .status!,
                                                                        ),
                                                                        color: _statusColor(
                                                                          vehicle
                                                                              .status!,
                                                                        ),
                                                                        icon: _statusIcon(
                                                                          vehicle
                                                                              .status!,
                                                                        ),
                                                                      ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Right side - Vehicle Capacity Info
                  Expanded(
                    flex: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child:
                                  _selectedVehicle != null
                                      ? MultiBlocProvider(
                                        providers: [
                                          BlocProvider.value(
                                            value: BlocProvider.of<
                                              DeliveryVehicleBloc
                                            >(context),
                                          ),
                                          BlocProvider.value(
                                            value: BlocProvider.of<
                                              DeliveryDataBloc
                                            >(context),
                                          ),
                                          BlocProvider.value(
                                            value: BlocProvider.of<
                                              VehicleProfileBloc
                                            >(context),
                                          ),
                                        ],
                                        child: VehicleCapacityInfo(
                                          vehicle: _selectedVehicle,
                                        ),
                                      )
                                      : const Center(
                                        child: Text(
                                          'Select a vehicle to view capacity information',
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                      ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed:
                      _selectedVehicle != null
                          ? () {
                            // Add the selected vehicle to the list
                            final updatedList = List<DeliveryVehicleModel>.from(
                              widget.selectedVehicles,
                            );
                            if (!updatedList.contains(_selectedVehicle)) {
                              updatedList.add(_selectedVehicle!);
                            }
                            widget.onVehiclesChanged(updatedList);
                            widget.onVehicleSelectedForCapacityCheck(
                              _selectedVehicle,
                            );
                            Navigator.of(context).pop();
                          }
                          : null,
                  child: const Text('Select Vehicle'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the tag-label filter dropdown using all tags from the BLoC.
  Widget _buildTagFilterDropdown(VehicleTagState tagState) {
    final labels = _getAllTagLabels(tagState);
    if (labels.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedTagLabel,
          hint: const Text(
            'Filter by tag',
            style: TextStyle(color: Colors.grey),
          ),
          icon: Icon(Icons.filter_list, color: Colors.grey.shade600),
          items: [
            const DropdownMenuItem<String>(
              value: null,
              child: Text('All tags'),
            ),
            ...labels.map((label) {
              return DropdownMenuItem<String>(value: label, child: Text(label));
            }),
          ],
          onChanged: (value) {
            setState(() {
              _selectedTagLabel = value;
            });
          },
        ),
      ),
    );
  }

  /// Builds compact count badges for each tag type present on the vehicle.
  /// Example: "2 (sticker icon) 1 (restriction icon)".
  Widget _buildTagBadges(List<VehicleTagEntity> tags) {
    // Count tags by type
    final counts = <VehicleTagType, int>{};
    for (final tag in tags) {
      for (final type in tag.types ?? []) {
        counts[type] = (counts[type] ?? 0) + 1;
      }
    }

    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children:
          counts.entries.map((entry) {
            final meta = _metaForTagType(entry.key);
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: (meta['color'] as Color).withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: (meta['color'] as Color).withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${entry.value}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: meta['color'] as Color,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(
                    meta['icon'] as IconData,
                    size: 12,
                    color: meta['color'] as Color,
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }

  Map<String, Object> _metaForTagType(VehicleTagType type) {
    switch (type) {
      case VehicleTagType.sticker:
        return {
          'label': 'Sticker',
          'color': Colors.indigo,
          'icon': Icons.sticky_note_2,
        };
      case VehicleTagType.restriction:
        return {
          'label': 'Restriction',
          'color': Colors.redAccent,
          'icon': Icons.block,
        };
      case VehicleTagType.permit:
        return {
          'label': 'Permit',
          'color': Colors.green,
          'icon': Icons.verified_user,
        };
      case VehicleTagType.other:
        return {
          'label': 'Other',
          'color': Colors.grey,
          'icon': Icons.label_outline,
        };
    }
  }

  Widget _buildStatusChip({
    required String label,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecChip({required IconData icon, required String label}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: Colors.grey.shade600),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
        ),
      ],
    );
  }

  String _statusLabel(VehicleStatus status) {
    switch (status) {
      case VehicleStatus.goodCondition:
        return 'Good Condition';
      case VehicleStatus.underMaintenance:
        return 'Under Maintenance';
      case VehicleStatus.inspectionRequired:
        return 'Inspection Required';
      case VehicleStatus.outOfService:
        return 'Out of Service';
      case VehicleStatus.retired:
        return 'Retired';
    }
  }

  Color _statusColor(VehicleStatus status) {
    switch (status) {
      case VehicleStatus.goodCondition:
        return Colors.green;
      case VehicleStatus.underMaintenance:
        return Colors.orange;
      case VehicleStatus.inspectionRequired:
        return Colors.amber.shade700;
      case VehicleStatus.outOfService:
        return Colors.red;
      case VehicleStatus.retired:
        return Colors.grey;
    }
  }

  IconData _statusIcon(VehicleStatus status) {
    switch (status) {
      case VehicleStatus.goodCondition:
        return Icons.verified;
      case VehicleStatus.underMaintenance:
        return Icons.build;
      case VehicleStatus.inspectionRequired:
        return Icons.fact_check_outlined;
      case VehicleStatus.outOfService:
        return Icons.block;
      case VehicleStatus.retired:
        return Icons.archive_outlined;
    }
  }
}
