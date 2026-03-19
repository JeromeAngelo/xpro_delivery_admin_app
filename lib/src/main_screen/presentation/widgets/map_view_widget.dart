import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/trip_ticket/trip/domain/entity/trip_entity.dart';
import 'dart:ui' as ui;

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() => _isMapReady = true);
    });
    widget.selectedTripNotifier?.addListener(_handleSelectedTrip);
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
                      const Icon(
                        Icons.local_shipping,
                        size: 18,
                        color: Colors.black87,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          vehicleName,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
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
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final vehicleName =
        (trip.vehicle != null)
            ? ((trip.vehicle as dynamic).name?.toString() ??
                trip.tripNumberId ??
                '')
            : (trip.tripNumberId ?? 'Unknown Vehicle');

    final driverName =
        trip.user != null
            ? ((trip.user as dynamic).name ??
                (trip.user as dynamic).email ??
                '-')
            : '-';

    final name = trip.name ?? '-';
    final latitude = trip.latitude?.toString() ?? '-';
    final longitude = trip.longitude?.toString() ?? '-';

    showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            width: 500,
            padding: const EdgeInsets.all(0),
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 18,
                  ),
                  decoration: BoxDecoration(
                    color: scheme.primary,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.local_shipping_outlined,
                          color: scheme.onPrimary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          vehicleName,
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: scheme.onPrimary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                  child: Column(
                    children: [
                      _buildDetailRow(
                        context,
                        icon: Icons.confirmation_num_outlined,
                        label: 'Trip Route',
                        value: name,
                      ),
                      const SizedBox(height: 14),
                      _buildDetailRow(
                        context,
                        icon: Icons.person_outline,
                        label: 'Driver',
                        value: driverName,
                      ),
                      const SizedBox(height: 14),
                      _buildDetailRow(
                        context,
                        icon: Icons.my_location,
                        label: 'Latitude',
                        value: latitude,
                      ),
                      const SizedBox(height: 14),
                      _buildDetailRow(
                        context,
                        icon: Icons.place_outlined,
                        label: 'Longitude',
                        value: longitude,
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1),

                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          context.go('/vehicle-map');
                        },
                        icon: const Icon(Icons.directions),
                        label: const Text('Go to Vehicle'),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          if (trip.id != null) {
                            context.go('/tripticket/${trip.id}');
                          }
                        },
                        icon: const Icon(Icons.trip_origin),
                        label: const Text('View Tripticket'),
                      ),
                      TextButton.icon(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                        label: const Text('Close'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withOpacity(0.45),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: scheme.outline.withOpacity(0.12)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: scheme.primary.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: scheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurface.withOpacity(0.65),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
