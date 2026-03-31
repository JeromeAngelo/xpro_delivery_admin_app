import 'dart:async';
import 'package:geolocator/geolocator.dart';

class LocationTrackingService {
  static final LocationTrackingService _instance =
      LocationTrackingService._internal();

  factory LocationTrackingService() => _instance;

  LocationTrackingService._internal();

  StreamSubscription<Position>? _positionStream;

  final StreamController<Position> _locationController =
      StreamController<Position>.broadcast();

  Stream<Position> get locationStream => _locationController.stream;

  Position? _lastPosition;

  /// Start tracking
  Future<void> start() async {
    // Ensure permission
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
    }

    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 1, // update every 1 meter
      ),
    ).listen((Position position) {
      if (_isValidMovement(position)) {
        _lastPosition = position;
        _locationController.add(position);
      }
    });
  }

  /// Stop tracking
  void stop() {
    _positionStream?.cancel();
  }

  /// Prevent fake movement (VERY IMPORTANT)
  bool _isValidMovement(Position newPos) {
    if (_lastPosition == null) return true;

    final distance = Geolocator.distanceBetween(
      _lastPosition!.latitude,
      _lastPosition!.longitude,
      newPos.latitude,
      newPos.longitude,
    );

    final speed = newPos.speed; // m/s

    // Ignore GPS noise
    if (distance < 3) return false;

    // Ignore unrealistic jumps
    if (speed > 60) return false;

    return true;
  }

  void dispose() {
    _positionStream?.cancel();
    _locationController.close();
  }
}