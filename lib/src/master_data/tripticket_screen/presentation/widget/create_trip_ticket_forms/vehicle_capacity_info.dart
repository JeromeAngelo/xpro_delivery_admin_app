import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/trip_ticket/delivery_data/domain/entity/delivery_data_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/trip_ticket/delivery_data/presentation/bloc/delivery_data_bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/trip_ticket/delivery_data/presentation/bloc/delivery_data_event.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/trip_ticket/delivery_data/presentation/bloc/delivery_data_state.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/trip_ticket/delivery_vehicle_data/domain/enitity/delivery_vehicle_entity.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/trip_ticket/delivery_vehicle_data/presentation/bloc/delivery_vehicle_bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/trip_ticket/delivery_vehicle_data/presentation/bloc/delivery_vehicle_event.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/trip_ticket/delivery_vehicle_data/presentation/bloc/delivery_vehicle_state.dart';
import 'package:xpro_delivery_admin_app/src/master_data/tripticket_screen/presentation/widget/create_trip_ticket_forms/vehicle_tags_card.dart';

class VehicleCapacityInfo extends StatelessWidget {
  final DeliveryVehicleEntity? vehicle;

  const VehicleCapacityInfo({super.key, this.vehicle});

  @override
  Widget build(BuildContext context) {
    // If no vehicle is selected, show instruction message
    if (vehicle == null) {
      return _buildNoVehicleSelectedMessage(context);
    }

    // If vehicle has tags attached, show the tags card; otherwise show a
    // friendly "no tags" message. Capacity card is always shown below.
    final hasTags =
        (vehicle?.vehicleTags != null && vehicle!.vehicleTags!.isNotEmpty);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (hasTags)
          VehicleTagsCard(tags: vehicle!.vehicleTags!)
        else
          _buildNoTagsMessage(context),

        const SizedBox(height: 16),

        // Capacity card is shown regardless of tags/profile presence
        _buildCapacityCard(context),
      ],
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

  // Widget to show when the selected vehicle has no tags yet
  Widget _buildNoTagsMessage(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.label_off_outlined,
              color: Colors.grey.shade600,
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'No Vehicle Tags',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'This vehicle has no tags yet.',
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () {
                      final vehicleId = vehicle?.id;
                      if (vehicleId != null && vehicleId.isNotEmpty) {
                        context.go('/update-vehicle/$vehicleId');
                      }
                    },
                    child: Text(
                      'Click here to set a tag for this vehicle',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                      ),
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
