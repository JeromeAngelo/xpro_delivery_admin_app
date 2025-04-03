import 'dart:async';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/trip/domain/entity/trip_entity.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/trip/presentation/bloc/trip_bloc.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/trip/presentation/bloc/trip_event.dart';
import 'package:desktop_app/core/common/app/features/Trip_Ticket/trip/presentation/bloc/trip_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class TripMapWidget extends StatefulWidget {
  final String tripId;
  final double height;

  const TripMapWidget({super.key, required this.tripId, this.height = 300.0});

  @override
  State<TripMapWidget> createState() => _TripMapWidgetState();
}

class _TripMapWidgetState extends State<TripMapWidget>
    with SingleTickerProviderStateMixin {
  final MapController mapController = MapController();
  bool isMapReady = false;
  late AnimationController _controller;
  late Animation<double> _heightAnimation;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _heightAnimation = Tween<double>(
      begin: widget.height,
      end: widget.height,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        isMapReady = true;
      });

      // Start auto-refresh timer
      _startRefreshTimer();
    });
  }

  void _startRefreshTimer() {
    // Cancel any existing timer
    _refreshTimer?.cancel();

    // Create a new timer that refreshes the trip data every minute
    _refreshTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (mounted) {
        context.read<TripBloc>().add(GetTripTicketByIdEvent(widget.tripId));
        debugPrint('🔄 Auto-refreshing trip map data');
      }
    });
  }

  @override
  void didUpdateWidget(TripMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.height != widget.height) {
      _heightAnimation = Tween<double>(
        begin: oldWidget.height,
        end: widget.height,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
      _controller.forward(from: 0);
    }

    if (oldWidget.tripId != widget.tripId) {
      // If trip ID changed, refresh the data
      context.read<TripBloc>().add(GetTripTicketByIdEvent(widget.tripId));
      _startRefreshTimer();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TripBloc, TripState>(
      builder: (context, state) {
        if (state is TripLoading) {
          return _buildLoadingCard();
        }

        if (state is TripError) {
          return _buildErrorCard(state.message);
        }

        if (state is TripTicketLoaded) {
          final trip = state.trip;
          return _buildMapCard(trip);
        }

        // Default placeholder if no trip data is available yet
        return _buildPlaceholderCard();
      },
    );
  }

  Widget _buildMapCard(TripEntity trip) {
    // Extract coordinates from trip entity
    final lat = trip.latitude ?? 0.0;
    final lng = trip.longitude ?? 0.0;

    // Check if we have valid coordinates
    final hasValidCoordinates = lat != 0.0 && lng != 0.0;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Delivery Route Map',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      tooltip: 'Refresh Map',
                      onPressed: () {
                        context.read<TripBloc>().add(
                          GetTripTicketByIdEvent(widget.tripId),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.fullscreen),
                      tooltip: 'Expand Map',
                      onPressed:
                          hasValidCoordinates
                              ? () =>
                                  _showFullScreenMap(context, LatLng(lat, lng))
                              : null,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),

            if (!hasValidCoordinates)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'No location data available for this trip yet.',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),

            if (hasValidCoordinates)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Location: ${lat.toStringAsFixed(6)}, ${lng.toStringAsFixed(6)}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    'Last Updated: ${trip.updated?.toString() ?? 'N/A'}',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                ],
              ),

            AnimatedBuilder(
              animation: _heightAnimation,
              builder: (context, child) {
                return Container(
                  height: _heightAnimation.value,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child:
                        hasValidCoordinates && isMapReady
                            ? _buildMap(LatLng(lat, lng))
                            : _buildMapPlaceholder(),
                  ),
                );
              },
            ),

            if (hasValidCoordinates && isMapReady)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.zoom_in),
                      tooltip: 'Zoom In',
                      onPressed: () {
                        final currentZoom = mapController.camera.zoom;
                        mapController.move(
                          mapController.camera.center,
                          currentZoom + 1,
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.zoom_out),
                      tooltip: 'Zoom Out',
                      onPressed: () {
                        final currentZoom = mapController.camera.zoom;
                        mapController.move(
                          mapController.camera.center,
                          currentZoom - 1,
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.my_location),
                      tooltip: 'Center Map',
                      onPressed: () {
                        mapController.move(LatLng(lat, lng), 16);
                      },
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMap(LatLng location) {
    try {
      return FlutterMap(
        mapController: mapController,
        options: MapOptions(
          initialCenter: location,
          initialZoom: 16,
          minZoom: 5,
          maxZoom: 18,
          // Enable drag with mouse
          interactionOptions: const InteractionOptions(
            flags: InteractiveFlag.all,
            // The following settings make dragging with mouse primary behavior
            pinchMoveWinGestures: 10,
          ),
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://mt1.google.com/vt/lyrs=m&x={x}&y={y}&z={z}',
            userAgentPackageName: 'com.example.desktop_app',
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: location,
                width: 40,
                height: 40,
                child: Icon(
                  Icons.local_shipping,
                  color: Theme.of(context).primaryColorDark,
                  size: 40,
                ),
              ),
            ],
          ),
          // Add a custom mouse cursor layer
          RichAttributionWidget(
            attributions: [
              TextSourceAttribution('Drag to move map', onTap: () {}),
            ],
            alignment: AttributionAlignment.bottomRight,
          ),
        ],
      );
    } catch (e) {
      debugPrint('Error building map: $e');
      return SizedBox(
        height: widget.height,
        child: Center(
          child: Text(
            'Error loading map: ${e.toString().substring(0, 100)}...',
          ),
        ),
      );
    }
  }

  Widget _buildMapPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.map, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Map will be displayed when location data is available',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Delivery Route Map',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: widget.height,
              child: const Center(child: CircularProgressIndicator()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard(String errorMessage) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Delivery Route Map',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: widget.height,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading map data',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      errorMessage,
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Delivery Route Map',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Refresh Map',
                  onPressed: () {
                    context.read<TripBloc>().add(
                      GetTripTicketByIdEvent(widget.tripId),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              height: widget.height,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.map, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'Loading trip location data...',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        context.read<TripBloc>().add(
                          GetTripTicketByIdEvent(widget.tripId),
                        );
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Load Data'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFullScreenMap(BuildContext context, LatLng location) {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            insetPadding: const EdgeInsets.all(16),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.height * 0.8,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Trip Location Map',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: FlutterMap(
                        options: MapOptions(
                          initialCenter: location,
                          initialZoom: 16,
                          minZoom: 5,
                          maxZoom: 18,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://mt1.google.com/vt/lyrs=m&x={x}&y={y}&z={z}',
                            userAgentPackageName: 'com.example.desktop_app',
                          ),
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: location,
                                width: 40,
                                height: 40,
                                child: Icon(
                                  Icons.local_shipping,
                                  color: Theme.of(context).primaryColor,
                                  size: 40,
                                ),
                              ),
                            ],
                          ),
                          RichAttributionWidget(
                            attributions: [
                              TextSourceAttribution(
                                'Map data © Google Maps',
                                onTap: () {},
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Coordinates: ${location.latitude.toStringAsFixed(6)}, ${location.longitude.toStringAsFixed(6)}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }
}

// Extension to add latitude and longitude properties to TripEntity
extension TripEntityLocationExtension on TripEntity {
  double? get latitude {
    try {
      return double.tryParse(totalTripDistance?.split(',')[0] ?? '');
    } catch (e) {
      return null;
    }
  }

  double? get longitude {
    try {
      return double.tryParse(totalTripDistance?.split(',')[1] ?? '');
    } catch (e) {
      return null;
    }
  }
}
