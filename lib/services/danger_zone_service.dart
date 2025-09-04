import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/danger_zone.dart';

class DangerZoneService {
  // ডেমো জোন — পরে API/Firestore থেকে আনতে পারো
  final List<DangerZone> _zones = const [
    DangerZone(
      id: 'z1',
      lat: 23.7808875,
      lon: 90.2792371,
      radiusMeters: 250,
      level: 3,
    ),
    DangerZone(
      id: 'z2',
      lat: 23.7500,
      lon: 90.3900,
      radiusMeters: 200,
      level: 2,
    ),
  ];

  DangerZone? getDangerAt(double lat, double lon) {
    for (final z in _zones) {
      final d = _distanceMeters(lat, lon, z.lat, z.lon);
      if (d <= z.radiusMeters) return z;
    }
    return null;
  }

  Set<Circle> circlesForMap() {
    final set = <Circle>{};
    for (final z in _zones) {
      set.add(
        Circle(
          circleId: CircleId(z.id),
          center: LatLng(z.lat, z.lon),
          radius: z.radiusMeters,
          strokeWidth: 1,
          strokeColor: z.level >= 3 ? Colors.red : Colors.amber,
          fillColor: z.level >= 3
              ? Colors.redAccent.withOpacity(0.25)
              : Colors.amber.withOpacity(0.25),
        ),
      );
    }
    return set;
  }

  double _distanceMeters(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371000.0; // meters
    final dLat = _deg2rad(lat2 - lat1);
    final dLon = _deg2rad(lon2 - lon1);
    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_deg2rad(lat1)) *
            cos(_deg2rad(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  double _deg2rad(double d) => d * (pi / 180.0);
}
