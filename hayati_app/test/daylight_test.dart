import 'dart:math' as math;

import 'package:flutter/painting.dart' show Color;
import 'package:flutter_test/flutter_test.dart';
import 'package:hayati/core/theme/daylight.dart';
import 'package:hayati/data/models/prayer.dart';
import 'package:hayati/domain/prayer_times.dart';

/// WCAG contrast of white text on [c].
double whiteContrast(Color c) {
  double lin(double v) => v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
  final y = 0.2126 * lin(c.r) + 0.7152 * lin(c.g) + 0.0722 * lin(c.b);
  return 1.05 / (y + 0.05);
}

void main() {
  test('the sky follows the prayers when a place is set, the clock otherwise', () {
    const riyadh = PrayerSettings(enabled: true, place: 'Riyadh', latitude: 24.7136, longitude: 46.6753);
    final day = DateTime(2026, 3, 10);
    final p = prayerDay(riyadh, day)!;
    SkyTime at(DateTime t, int min) => skyTimeAt(t.add(Duration(minutes: min)), riyadh);
    expect([at(p[Prayer.fajr], -1), at(p[Prayer.fajr], 1), at(p.sunrise, 1), at(p[Prayer.dhuhr], 1), at(p[Prayer.asr], 1), at(p[Prayer.maghrib], 1), at(p[Prayer.isha], 1)],
        [SkyTime.isha, SkyTime.fajr, SkyTime.morning, SkyTime.dhuhr, SkyTime.asr, SkyTime.maghrib, SkyTime.isha]);
    const none = PrayerSettings();
    expect(skyTimeAt(day.add(const Duration(hours: 16)), none), SkyTime.asr);
    expect(skyTimeAt(day.add(const Duration(hours: 2)), none), SkyTime.isha);
  });

  test('white text stays readable on every sky, light and dark', () {
    for (final t in SkyTime.values) {
      for (final dark in [false, true]) {
        final s = Skies.of(t, dark: dark);
        expect(whiteContrast(s.bottom), greaterThanOrEqualTo(4.5), reason: '$t dark=$dark bottom');
        expect(whiteContrast(s.top), greaterThanOrEqualTo(4.5), reason: '$t dark=$dark top');
      }
    }
  });
}
