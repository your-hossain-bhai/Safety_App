import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DangerZone {
  final String id;
  final double lat;
  final double lon;
  final double radiusMeters;
  final int level;

  DangerZone({
    required this.id,
    required this.lat,
    required this.lon,
    required this.radiusMeters,
    required this.level,
  });
}

class DangerZoneService {
  final List<DangerZone> _zones = [
    DangerZone(
        id: 'z1', lat: 23.8103, lon: 90.4125, radiusMeters: 250, level: 4),
    DangerZone(
        id: 'z2', lat: 23.7950, lon: 90.4043, radiusMeters: 180, level: 2),
  ];

  List<DangerZone> getZones() => _zones;

  Set<Circle> circlesForMap(List<DangerZone> zones) {
    final Set<Circle> result = {};
    for (final z in zones) {
      final base = z.level >= 3 ? Colors.red : Colors.amber;
      result.add(
        Circle(
          circleId: CircleId(z.id),
          center: LatLng(z.lat, z.lon),
          radius: z.radiusMeters,
          strokeWidth: 1,
          strokeColor: base,
         
          fillColor: base.withValues(alpha: 0.25),
        ),
      );
    }
    return result;
  }
}
