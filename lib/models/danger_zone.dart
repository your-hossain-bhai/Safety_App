class DangerZone {
  final String id;
  final double lat;
  final double lon;
  final double radiusMeters; // e.g., 200
  final int level; // 1..3

  const DangerZone({
    required this.id,
    required this.lat,
    required this.lon,
    required this.radiusMeters,
    required this.level,
  });
}
