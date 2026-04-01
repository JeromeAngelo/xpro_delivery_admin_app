import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/trip_ticket/trip/domain/entity/trip_entity.dart';
import 'vehicle_details_dialog.dart';
import 'dart:ui' as ui;

import '../../../../core/services/location_tracking_service.dart';

class MapViewWidget extends StatefulWidget {
  final List<TripEntity> trips;
  final VoidCallback? onRefresh;
  final VoidCallback? onSelectVehicle;
  final double height;
  final double width;

  /// Optional notifier: parent sets .value to a TripEntity to make the map center on it.
  final ValueNotifier<TripEntity?>? selectedTripNotifier;

  const MapViewWidget({
    super.key,
    required this.trips,
    this.height = 420,
    this.onRefresh,
    this.width = double.infinity,
    this.onSelectVehicle,
    this.selectedTripNotifier,
  });

  @override
  State<MapViewWidget> createState() => _MapViewWidgetState();
}

class _MapViewWidgetState extends State<MapViewWidget> {
  final MapController _mapController = MapController();
  bool _isSatellite = false;
  double _zoom = 6.9;
  bool _isMapReady = false;
  StreamSubscription<Position>? _locationSub;
  LatLng? _currentLocation;

  void _startTracking() async {
    final service = LocationTrackingService();
    await service.start();

    _locationSub = service.locationStream.listen((position) {
      final latLng = LatLng(position.latitude, position.longitude);

      // filter small movements
      if (_currentLocation != null) {
        final distance = Distance().as(
          LengthUnit.Meter,
          _currentLocation!,
          latLng,
        );

        if (distance < 3) return;
      }

      setState(() {
        _currentLocation = latLng;
      });

      // smooth camera follow (optional)
      if (_isMapReady) {
        final currentCenter = _mapController.camera.center;

        final distance = Distance().as(LengthUnit.Meter, currentCenter, latLng);

        if (distance > 10) {
          _mapController.move(latLng, _zoom);
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() => _isMapReady = true);
    });

    widget.selectedTripNotifier?.addListener(_handleSelectedTrip);

    _startTracking(); // ✅ THIS LINE WAS MISSING
  }

  @override
  void didUpdateWidget(covariant MapViewWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedTripNotifier != widget.selectedTripNotifier) {
      oldWidget.selectedTripNotifier?.removeListener(_handleSelectedTrip);
      widget.selectedTripNotifier?.addListener(_handleSelectedTrip);
    }
  }

  @override
  void dispose() {
    widget.selectedTripNotifier?.removeListener(_handleSelectedTrip);
    _locationSub?.cancel();
    super.dispose();
  }

  void _handleSelectedTrip() {
    final trip = widget.selectedTripNotifier?.value;
    if (trip == null) return;
    final lat = trip.latitude;
    final lng = trip.longitude;
    if (lat == null || lng == null) return;

    const double targetZoom = 30.0; // adjust as needed
    final target = LatLng(lat, lng);

    // Try to move map (catch if controller not ready)
    try {
      _mapController.move(target, targetZoom);
      setState(() => _zoom = targetZoom);
    } catch (_) {
      // ignore if move fails (map not ready)
    }
  }

  LatLng _defaultCenter() {
    final withCoords =
        widget.trips
            .where((t) => t.latitude != null && t.longitude != null)
            .toList();
    if (withCoords.isNotEmpty) {
      final t = withCoords.first;
      return LatLng(t.latitude!, t.longitude!);
    }
    // sensible default
    return const LatLng(14.5995, 120.9842);
  }

  List<Marker> _buildMarkers() {
    final markers = <Marker>[];

    // 📦 STATIC VEHICLES
    for (final trip in widget.trips) {
      final lat = trip.latitude;
      final lng = trip.longitude;
      if (lat == null || lng == null) continue;

      final vehicleName =
          (trip.vehicle != null)
              ? ((trip.vehicle as dynamic).name?.toString() ??
                  trip.tripNumberId ??
                  '')
              : (trip.tripNumberId ?? '');

      markers.add(
        Marker(
          point: LatLng(lat, lng),
          width: 120,
          height: 70,
          child: GestureDetector(
            onTap: () => _showMarkerDetails(trip),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                    boxShadow: kElevationToShadow[2],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.local_shipping,
                        size: 18,
                        color: Theme.of(context).colorScheme.surface,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          vehicleName,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.surface,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                CustomPaint(
                  painter: _TrianglePainter(color: Colors.white),
                  child: const SizedBox(width: 12, height: 6),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return markers;
  }

  void _showMarkerDetails(TripEntity trip) {
    showVehicleDetailsDialog(context, trip);
  }


  void _openFullScreen() {
    final center = _defaultCenter();
    final markers = _buildMarkers();
    showDialog(
      context: context,
      builder:
          (ctx) => Dialog(
            insetPadding: const EdgeInsets.all(16),
            child: SizedBox(
              width: MediaQuery.of(ctx).size.width * 0.9,
              height: MediaQuery.of(ctx).size.height * 0.9,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Map',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            _isSatellite ? Icons.map : Icons.satellite,
                          ),
                          onPressed: () {
                            setState(() => _isSatellite = !_isSatellite);
                          },
                        ),
                        IconButton(icon: Icon(Icons.refresh), onPressed: () {}),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.of(ctx).pop(),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          initialCenter: center,
                          initialZoom: _zoom,
                          minZoom: 2,
                          maxZoom: 18,
                        ),
                        children: [
                          TileLayer(
                            // Use the same display type as TripMapWidget (compatible with your flutter_map version).
                            // Google tile endpoints used here because TripMapWidget expects them.
                            urlTemplate:
                                _isSatellite
                                    ? 'https://mt1.google.com/vt/lyrs=y&x={x}&y={y}&z={z}' // satellite + labels
                                    : 'https://mt1.google.com/vt/lyrs=m&x={x}&y={y}&z={z}',

                            userAgentPackageName: 'com.example.desktop_app',
                            tileProvider: NetworkTileProvider(),
                            maxNativeZoom: 19,
                            keepBuffer: 2,
                          ),
                          MarkerLayer(markers: markers),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: _mapBody(),
        ),
      ),
    );
  }

  Widget _mapBody() {
    final center = _defaultCenter();
    final markers = _buildMarkers();

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: center,
            initialZoom: _zoom,
            minZoom: 2,
            maxZoom: 35,
            onTap: (_, __) {},
          ),
          children: [
            TileLayer(
              // Use the same display type as TripMapWidget (compatible with your flutter_map version).
              // Google tile endpoints used here because TripMapWidget expects them.
              urlTemplate:
                  _isSatellite
                      ? 'https://mt1.google.com/vt/lyrs=y&x={x}&y={y}&z={z}' // satellite + labels
                      : 'https://mt1.google.com/vt/lyrs=m&x={x}&y={y}&z={z}',

              userAgentPackageName: 'com.example.desktop_app',
              tileProvider: NetworkTileProvider(),
              maxNativeZoom: 19,
              keepBuffer: 2,
            ),
            if (markers.isNotEmpty) MarkerLayer(markers: markers),
          ],
        ),

        // Controls
        Positioned(
          right: 12,
          top: 12,
          child: Column(
            children: [
              _controlButton(
                icon: Icons.add,
                onTap: () {
                  _zoom = (_zoom + 1.0).clamp(2.0, 18.0);
                  final currentCenter = _mapController.camera.center;
                  _mapController.move(currentCenter, _zoom);
                  setState(() {});
                },
              ),
              const SizedBox(height: 8),

              _controlButton(
                icon: Icons.remove,
                onTap: () {
                  _zoom = (_zoom - 1.0).clamp(2.0, 18.0);
                  final currentCenter = _mapController.camera.center;
                  _mapController.move(currentCenter, _zoom);
                  setState(() {});
                },
              ),
              const SizedBox(height: 8),
              _controlButton(
                icon: _isSatellite ? Icons.map : Icons.satellite,
                onTap: () => setState(() => _isSatellite = !_isSatellite),
              ),
              const SizedBox(height: 8),
              _controlButton(icon: Icons.fullscreen, onTap: _openFullScreen),
              const SizedBox(height: 8),
              _controlButton(
                icon: Icons.refresh,
                onTap: () {
                  if (widget.onRefresh != null) {
                    widget.onRefresh!();
                  }
                },
              ),
            ],
          ),
        ),

        // Default / center button
        Positioned(
          left: 12,
          top: 12,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white70,
              foregroundColor: Colors.black87,
            ),
            onPressed: () {
              _mapController.move(center, 6.0);
              setState(() => _zoom = 6.0);
            },
            icon: const Icon(Icons.center_focus_strong),
            label: const Text('Default'),
          ),
        ),

        // Attribution overlay (separate widget because TileLayer may not support attributionBuilder)
        Positioned(
          left: 8,
          bottom: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white70,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              _getAttributionText(),
              style: const TextStyle(fontSize: 10, color: Colors.black87),
            ),
          ),
        ),
      ],
    );
  }

  Widget _controlButton({required IconData icon, required VoidCallback onTap}) {
    return Material(
      color: Colors.white70,
      shape: const CircleBorder(),
      elevation: 2,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(icon, size: 20, color: Colors.black87),
        ),
      ),
    );
  }

  String _getAttributionText() {
    const mapTilerKey = String.fromEnvironment(
      'MAPTILER_KEY',
      defaultValue: '',
    );
    if (mapTilerKey.isNotEmpty) {
      return 'Map data © OpenStreetMap contributors, CC-BY-SA, Imagery © MapTiler';
    }
    return 'Map data © OpenStreetMap contributors';
  }
}

/// Small painter for marker pointer triangle
class _TrianglePainter extends CustomPainter {
  final Color color;
  _TrianglePainter({this.color = Colors.white});

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = color;
    final path = ui.Path();
    path.moveTo(0, 0);
    path.lineTo(size.width / 2, size.height);
    path.lineTo(size.width, 0);
    path.close();
    canvas.drawShadow(path, Colors.black38, 2, false);
    canvas.drawPath(path, p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
