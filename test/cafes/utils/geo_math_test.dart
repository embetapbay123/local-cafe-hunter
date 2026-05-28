import 'package:flutter_test/flutter_test.dart';

import 'package:local_cafe_hunter/cafes/utils/geo_math.dart';

void main() {
  test('calculateDistanceMeters returns zero for the same point', () {
    expect(
      calculateDistanceMeters(
        startLatitude: 16.0674,
        startLongitude: 108.2311,
        endLatitude: 16.0674,
        endLongitude: 108.2311,
      ),
      closeTo(0, 0.001),
    );
  });

  test('calculateDistanceMeters returns a larger value for farther points',
      () {
    final near = calculateDistanceMeters(
      startLatitude: 16.0674,
      startLongitude: 108.2311,
      endLatitude: 16.0608,
      endLongitude: 108.2207,
    );
    final far = calculateDistanceMeters(
      startLatitude: 16.0674,
      startLongitude: 108.2311,
      endLatitude: 16.25,
      endLongitude: 108.48,
    );

    expect(near, greaterThan(0));
    expect(far, greaterThan(near));
  });
}
