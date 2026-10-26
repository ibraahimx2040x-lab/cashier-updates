import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

enum LocationFailure { serviceOff, denied, error }

class LocationResult {
  const LocationResult.ok(double this.latitude, double this.longitude) : failure = null;
  const LocationResult.failed(LocationFailure this.failure)
      : latitude = null,
        longitude = null;
  final double? latitude;
  final double? longitude;
  final LocationFailure? failure;
}

/// The device's approximate position, only when the user asks for it.
/// Low accuracy is enough for prayer times and shares less.
abstract interface class LocationService {
  Future<LocationResult> current();
}

class GeolocatorLocation implements LocationService {
  @override
  Future<LocationResult> current() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return const LocationResult.failed(LocationFailure.serviceOff);
      var p = await Geolocator.checkPermission();
      if (p == LocationPermission.denied) p = await Geolocator.requestPermission();
      if (p == LocationPermission.denied || p == LocationPermission.deniedForever) {
        return const LocationResult.failed(LocationFailure.denied);
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.low, timeLimit: Duration(seconds: 20)),
      );
      return LocationResult.ok(pos.latitude, pos.longitude);
    } catch (_) {
      return const LocationResult.failed(LocationFailure.error);
    }
  }
}

/// Overridden in tests.
final locationServiceProvider = Provider<LocationService>((ref) => GeolocatorLocation());
