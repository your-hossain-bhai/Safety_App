import 'dart:async';
import 'package:geolocator/geolocator.dart';

class LocationService {
  /// Ask for permissions; true if usable now.
  Future<bool> ensurePermissions() async {
    final serviceOn = await Geolocator.isLocationServiceEnabled();
    if (!serviceOn) return false;

    var p = await Geolocator.checkPermission();
    if (p == LocationPermission.denied) {
      p = await Geolocator.requestPermission();
    }
    if (p == LocationPermission.deniedForever) return false;

    return p == LocationPermission.always || p == LocationPermission.whileInUse;
  }

  /// Try for a fix; on timeout/failure returns last known.
  /// Note: nullable return — callers must handle null.
  Future<Position?> getCurrentPosition() async {
    try {
      final ok = await ensurePermissions();
      if (!ok) return await Geolocator.getLastKnownPosition();

      try {
        // No onTimeout callback – we'll catch the TimeoutException instead
        final pos = await Geolocator.getCurrentPosition(
                desiredAccuracy: LocationAccuracy.best)
            .timeout(const Duration(seconds: 8));
        return pos; // Position (non-null)
      } on TimeoutException {
        // Fallback so the UI doesn't spin forever
        return await Geolocator.getLastKnownPosition(); // Position?
      } catch (_) {
        return await Geolocator.getLastKnownPosition();
      }
    } catch (_) {
      return await Geolocator.getLastKnownPosition();
    }
  }

  /// Continuous updates once permissions are OK.
  Stream<Position> positionStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    );
  }

  Future<bool> isServiceEnabled() => Geolocator.isLocationServiceEnabled();
  Future<void> openLocationSettings() => Geolocator.openLocationSettings();
  Future<void> openAppSettings() => Geolocator.openAppSettings();
}
