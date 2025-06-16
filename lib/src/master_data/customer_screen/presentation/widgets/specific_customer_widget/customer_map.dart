import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/Trip_Ticket/customer_data/domain/entity/customer_data_entity.dart';

class CustomerMapScreen extends StatefulWidget {
  final CustomerDataEntity selectedCustomer;
  final double height;

  const CustomerMapScreen({
    super.key,
    required this.selectedCustomer,
    this.height = 300.0,
  });

  @override
  State<CustomerMapScreen> createState() => _CustomerMapScreenState();
}

class _CustomerMapScreenState extends State<CustomerMapScreen>
    with SingleTickerProviderStateMixin {
  final MapController mapController = MapController();
  bool isMapReady = false;
  late AnimationController _controller;
  late Animation<double> _heightAnimation;

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
    });
  }

  @override
  void didUpdateWidget(CustomerMapScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.height != widget.height) {
      _heightAnimation = Tween<double>(
        begin: oldWidget.height,
        end: widget.height,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
      _controller.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  'Customer Location',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.fullscreen),
                  tooltip: 'Expand Map',
                  onPressed: () {
                    _showFullScreenMap(context);
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Use direct customer data
            Builder(
              builder: (context) {
                if (!isMapReady) {
                  return SizedBox(height: widget.height);
                }

                // Extract coordinates directly from the customer entity
                // Use the latitude and longitude as double values
                final lat = widget.selectedCustomer.latitude ?? 15.058583416335447;
                final lng = widget.selectedCustomer.longitude ?? 120.77471934782055;
                final location = LatLng(lat, lng);
                final locationText = '${lat.toStringAsFixed(6)}, ${lng.toStringAsFixed(6)}';

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Coordinates: $locationText',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
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
                            child: _buildMap(location),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    Row(
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
                            mapController.move(location, 16);
                          },
                        ),
                      ],
                    ),
                  ],
                );
              },
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
          // Add onPointerHover to show cursor change
          onPointerHover: (event, point) {
            // This doesn't directly change the cursor, but helps with feedback
          },
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
                  Icons.location_on,
                  color: Theme.of(context).primaryColor,
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

  void _showFullScreenMap(BuildContext context) {
    final lat = widget.selectedCustomer.latitude ?? 15.058583416335447;
    final lng = widget.selectedCustomer.longitude ?? 120.77471934782055;
    final location = LatLng(lat, lng);

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Customer Location Map',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: location,
                    initialZoom: 16,
                    minZoom: 3,
                    maxZoom: 18,
                    // Enable drag with mouse in fullscreen mode too
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.all,
                      pinchMoveWinGestures: 2,
                      scrollWheelVelocity: 0,
                    ),
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
                            Icons.location_on,
                            color: Theme.of(context).primaryColor,
                            size: 40,
                          ),
                        ),
                      ],
                    ),
                    // Add a custom mouse cursor layer for fullscreen map too
                    RichAttributionWidget(
                      attributions: [
                        TextSourceAttribution('Drag to move map', onTap: () {}),
                      ],
                      alignment: AttributionAlignment.bottomRight,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
