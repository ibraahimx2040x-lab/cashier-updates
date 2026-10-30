import 'package:flutter/material.dart';

import '../../data/models/prayer.dart';
import '../../domain/prayer_times.dart';

/// Where the day is, by the prayers: the identity's signature. The panel at
/// the top of each screen takes the colour of the sky right now.
enum SkyTime { fajr, morning, dhuhr, asr, maghrib, isha }

/// The current period from today's prayer times, or from the clock when no
/// place is set (fajr 4–6, morning to 12, dhuhr to 15, asr to 18, maghrib to
/// 19:30, isha after).
SkyTime skyTimeAt(DateTime now, PrayerSettings prayer) {
  final p = prayerDay(prayer, now);
  if (p == null) {
    final m = now.hour * 60 + now.minute;
    if (m < 4 * 60) return SkyTime.isha;
    if (m < 6 * 60) return SkyTime.fajr;
    if (m < 12 * 60) return SkyTime.morning;
    if (m < 15 * 60) return SkyTime.dhuhr;
    if (m < 18 * 60) return SkyTime.asr;
    if (m < 19 * 60 + 30) return SkyTime.maghrib;
    return SkyTime.isha;
  }
  if (now.isBefore(p[Prayer.fajr])) return SkyTime.isha;
  if (now.isBefore(p.sunrise)) return SkyTime.fajr;
  if (now.isBefore(p[Prayer.dhuhr])) return SkyTime.morning;
  if (now.isBefore(p[Prayer.asr])) return SkyTime.dhuhr;
  if (now.isBefore(p[Prayer.maghrib])) return SkyTime.asr;
  if (now.isBefore(p[Prayer.isha])) return SkyTime.maghrib;
  return SkyTime.isha;
}

/// One sky: a vertical gradient dark enough for white text (≥4.5:1 at the
/// lighter end) and where the sun or moon sits.
@immutable
class Sky {
  const Sky(this.top, this.bottom, {required this.glow, required this.body, required this.sunX, required this.sunY, this.night = false});
  final Color top;
  final Color bottom;

  /// The halo around the sun or moon.
  final Color glow;

  /// The sun or moon itself.
  final Color body;

  /// Position as a fraction of the panel, measured from the start edge
  /// (the side the day starts on: right in Arabic, left in English).
  final double sunX;
  final double sunY;

  /// A crescent and stars instead of a sun.
  final bool night;

  LinearGradient get gradient => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [top, bottom],
      );
}

abstract final class Skies {
  static const _light = {
    SkyTime.fajr: Sky(Color(0xFF2E2763), Color(0xFF7A4F86), glow: Color(0xFFF4A6B8), body: Color(0xFFFFD6DE), sunX: 0.10, sunY: 0.95),
    SkyTime.morning: Sky(Color(0xFF1C4F8C), Color(0xFF2F6DAE), glow: Color(0xFFFFE3A3), body: Color(0xFFFFF2CF), sunX: 0.22, sunY: 0.30),
    SkyTime.dhuhr: Sky(Color(0xFF155E96), Color(0xFF1F70A9), glow: Color(0xFFFFF4D1), body: Color(0xFFFFFBEA), sunX: 0.50, sunY: 0.05),
    SkyTime.asr: Sky(Color(0xFF7A3F12), Color(0xFF9A5418), glow: Color(0xFFFFC870), body: Color(0xFFFFE2A8), sunX: 0.78, sunY: 0.32),
    SkyTime.maghrib: Sky(Color(0xFF6A2A3E), Color(0xFF9B3F2E), glow: Color(0xFFFF9466), body: Color(0xFFFFC09A), sunX: 0.92, sunY: 0.92),
    SkyTime.isha: Sky(Color(0xFF0D1230), Color(0xFF1F2766), glow: Color(0xFF9AA6FF), body: Color(0xFFE9ECFF), sunX: 0.82, sunY: 0.20, night: true),
  };

  /// Night mode keeps the hue but drops the light, so the panel never
  /// glares in a dark room.
  static final _dark = {
    for (final e in _light.entries)
      e.key: Sky(
        Color.lerp(e.value.top, const Color(0xFF05060F), 0.35)!,
        Color.lerp(e.value.bottom, const Color(0xFF05060F), 0.35)!,
        glow: e.value.glow,
        body: e.value.body,
        sunX: e.value.sunX,
        sunY: e.value.sunY,
        night: e.value.night,
      ),
  };

  static Sky of(SkyTime p, {required bool dark}) => (dark ? _dark : _light)[p]!;
}
