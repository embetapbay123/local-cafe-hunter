import 'dart:math' as math;

double calculateDistanceMeters({
  required double startLatitude,
  required double startLongitude,
  required double endLatitude,
  required double endLongitude,
}) {
  const earthRadiusMeters = 6371000.0;
  final deltaLatitude = _degreesToRadians(endLatitude - startLatitude);
  final deltaLongitude = _degreesToRadians(endLongitude - startLongitude);
  final startLatitudeRadians = _degreesToRadians(startLatitude);
  final endLatitudeRadians = _degreesToRadians(endLatitude);

  final haversine = math.pow(math.sin(deltaLatitude / 2), 2) +
      math.cos(startLatitudeRadians) *
          math.cos(endLatitudeRadians) *
          math.pow(math.sin(deltaLongitude / 2), 2);
  final angularDistance =
      2 * math.atan2(math.sqrt(haversine), math.sqrt(1 - haversine));

  return earthRadiusMeters * angularDistance;
}

double _degreesToRadians(double degrees) => degrees * math.pi / 180;
