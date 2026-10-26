import 'package:adhan/adhan.dart' as adhan;

import '../core/utils/dates.dart';
import '../data/models/prayer.dart';

/// One day's prayer times in device-local time, calculated astronomically
/// from the user's place and method. These are calculations, not an
/// announcement from a mosque: the UI always says which method was used.
class PrayerDay {
  const PrayerDay(this.day, this.times, this.sunrise);
  final DateTime day;
  final Map<Prayer, DateTime> times;
  final DateTime sunrise;

  DateTime operator [](Prayer p) => times[p]!;
}

/// Prayer times for [day], or null when prayer times are off or no place
/// has been set.
PrayerDay? prayerDay(PrayerSettings s, DateTime day) {
  if (!s.active) return null;
  final params = _method(s.method).getParameters()
    ..madhab = s.hanafiAsr ? adhan.Madhab.hanafi : adhan.Madhab.shafi;
  final d = dateOnly(day);
  final pt = adhan.PrayerTimes(
    adhan.Coordinates(s.latitude!, s.longitude!),
    adhan.DateComponents(d.year, d.month, d.day),
    params,
  );
  return PrayerDay(d, {
    Prayer.fajr: pt.fajr.toLocal(),
    Prayer.dhuhr: pt.dhuhr.toLocal(),
    Prayer.asr: pt.asr.toLocal(),
    Prayer.maghrib: pt.maghrib.toLocal(),
    Prayer.isha: pt.isha.toLocal(),
  }, pt.sunrise.toLocal());
}

/// The next prayer after [now] (today's, else tomorrow's Fajr).
(Prayer, DateTime)? nextPrayer(PrayerSettings s, DateTime now) {
  final today = prayerDay(s, now);
  if (today == null) return null;
  for (final p in Prayer.values) {
    if (today[p].isAfter(now)) return (p, today[p]);
  }
  final tomorrow = prayerDay(s, now.add(const Duration(days: 1)))!;
  return (Prayer.fajr, tomorrow[Prayer.fajr]);
}

/// The prayer whose time has come and whose next prayer hasn't yet
/// (Isha runs until tomorrow's Fajr). Null before today's Fajr.
Prayer? currentPrayer(PrayerSettings s, DateTime now) {
  final today = prayerDay(s, now);
  if (today == null) return null;
  Prayer? current;
  for (final p in Prayer.values) {
    if (!today[p].isAfter(now)) current = p;
  }
  return current;
}

adhan.CalculationMethod _method(PrayerMethod m) => switch (m) {
      PrayerMethod.ummAlQura => adhan.CalculationMethod.umm_al_qura,
      PrayerMethod.muslimWorldLeague => adhan.CalculationMethod.muslim_world_league,
      PrayerMethod.egyptian => adhan.CalculationMethod.egyptian,
      PrayerMethod.karachi => adhan.CalculationMethod.karachi,
      PrayerMethod.dubai => adhan.CalculationMethod.dubai,
      PrayerMethod.kuwait => adhan.CalculationMethod.kuwait,
      PrayerMethod.qatar => adhan.CalculationMethod.qatar,
      PrayerMethod.northAmerica => adhan.CalculationMethod.north_america,
    };
