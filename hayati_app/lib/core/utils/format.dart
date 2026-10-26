import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import 'dates.dart';

/// Locale-aware formatting. Digits are Latin in both languages so numbers,
/// times and percentages look consistent everywhere (section 9).
class Fmt {
  Fmt(this.locale, {this.use24h = false});

  factory Fmt.of(BuildContext context, {bool use24h = false}) =>
      Fmt(Localizations.localeOf(context).languageCode, use24h: use24h);

  final String locale;
  final bool use24h;

  String time(DateTime t) => DateFormat(use24h ? 'HH:mm' : 'h:mm a', locale).format(t);
  String minutesOfDay(int m) => time(atMinutes(DateTime(2000), m));
  String date(DateTime d) => DateFormat.yMMMd(locale).format(d);
  String dateShort(DateTime d) => DateFormat.MMMd(locale).format(d);
  String weekdayDate(DateTime d) => DateFormat.MMMEd(locale).format(d);
  String fullDate(DateTime d) => DateFormat.yMMMMEEEEd(locale).format(d);
  String monthYear(DateTime d) => DateFormat.yMMMM(locale).format(d);
  String weekdayShort(DateTime d) => DateFormat.E(locale).format(d);
  String day(String key) => date(parseDayKey(key));
  String dateTime(DateTime d) => '${dateShort(d)} · ${time(d)}';

  String money(int minor, String currency) {
    final f = NumberFormat.currency(locale: locale, name: currency, symbol: '$currency ', decimalDigits: 2);
    return f.format(minor / 100);
  }

  String number(num v) => NumberFormat.decimalPattern(locale).format(v);

  /// "1h 30m" style duration with localized units.
  String duration(int minutes, {required String h, required String m}) {
    if (minutes < 60) return '$minutes $m';
    final hh = minutes ~/ 60, mm = minutes % 60;
    return mm == 0 ? '$hh $h' : '$hh $h $mm $m';
  }
}

void configureDigits() {
  DateFormat.useNativeDigitsByDefaultFor('ar', false);
}
