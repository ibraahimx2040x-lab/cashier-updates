/// The five daily prayers, in order.
enum Prayer { fajr, dhuhr, asr, maghrib, isha }

/// Standard astronomical calculation methods (angles per authority).
enum PrayerMethod { ummAlQura, muslimWorldLeague, egyptian, karachi, dubai, kuwait, qatar, northAmerica }

/// Where and how prayer times are calculated (the profile's
/// `prayer_settings`). Times are only shown once a place is set; nothing
/// is assumed from the device.
class PrayerSettings {
  const PrayerSettings({
    this.enabled = false,
    this.place = '',
    this.latitude,
    this.longitude,
    this.method = PrayerMethod.ummAlQura,
    this.hanafiAsr = false,
    this.notify = true,
    this.remindBefore = 0,
    this.blockMinutes = 20,
    this.logEnabled = true,
    this.setupDismissed = false,
  });

  final bool enabled;

  /// City name shown to the user, or empty when using the device location.
  final String place;
  final double? latitude;
  final double? longitude;
  final PrayerMethod method;

  /// Later Asr (shadow twice the object's length) instead of the majority view.
  final bool hanafiAsr;

  /// Device notification at each prayer time.
  final bool notify;

  /// Extra reminder this many minutes before; 0 = none.
  final int remindBefore;

  /// Time kept free around each prayer when planning the day.
  final int blockMinutes;

  /// Show "prayed" toggles. Never inferred from the time passing.
  final bool logEnabled;

  /// The user closed the "set up prayer times" card on the home screen.
  final bool setupDismissed;

  bool get hasLocation => latitude != null && longitude != null;
  bool get active => enabled && hasLocation;

  PrayerSettings copyWith({
    bool? enabled,
    String? place,
    double? Function()? latitude,
    double? Function()? longitude,
    PrayerMethod? method,
    bool? hanafiAsr,
    bool? notify,
    int? remindBefore,
    int? blockMinutes,
    bool? logEnabled,
    bool? setupDismissed,
  }) =>
      PrayerSettings(
        enabled: enabled ?? this.enabled,
        place: place ?? this.place,
        latitude: latitude != null ? latitude() : this.latitude,
        longitude: longitude != null ? longitude() : this.longitude,
        method: method ?? this.method,
        hanafiAsr: hanafiAsr ?? this.hanafiAsr,
        notify: notify ?? this.notify,
        remindBefore: remindBefore ?? this.remindBefore,
        blockMinutes: blockMinutes ?? this.blockMinutes,
        logEnabled: logEnabled ?? this.logEnabled,
        setupDismissed: setupDismissed ?? this.setupDismissed,
      );

  Map<String, Object?> toJson() => {
        'enabled': enabled,
        'place': place,
        'latitude': latitude,
        'longitude': longitude,
        'method': method.name,
        'hanafiAsr': hanafiAsr,
        'notify': notify,
        'remindBefore': remindBefore,
        'blockMinutes': blockMinutes,
        'logEnabled': logEnabled,
        'setupDismissed': setupDismissed,
      };

  factory PrayerSettings.fromJson(Map<String, Object?> j) {
    const d = PrayerSettings();
    final m = j['method'] as String?;
    return PrayerSettings(
      enabled: (j['enabled'] as bool?) ?? d.enabled,
      place: (j['place'] as String?) ?? d.place,
      latitude: (j['latitude'] as num?)?.toDouble(),
      longitude: (j['longitude'] as num?)?.toDouble(),
      method: PrayerMethod.values.where((x) => x.name == m).firstOrNull ?? d.method,
      hanafiAsr: (j['hanafiAsr'] as bool?) ?? d.hanafiAsr,
      notify: (j['notify'] as bool?) ?? d.notify,
      remindBefore: (j['remindBefore'] as int?) ?? d.remindBefore,
      blockMinutes: (j['blockMinutes'] as int?) ?? d.blockMinutes,
      logEnabled: (j['logEnabled'] as bool?) ?? d.logEnabled,
      setupDismissed: (j['setupDismissed'] as bool?) ?? d.setupDismissed,
    );
  }
}

/// The user recorded [prayer] on [day] (YYYY-MM-DD).
class PrayerLog {
  const PrayerLog({required this.id, required this.day, required this.prayer});
  final String id;
  final String day;
  final Prayer prayer;

  Map<String, Object?> toJson() => {'id': id, 'day': day, 'prayer': prayer.name};

  factory PrayerLog.fromJson(Map<String, Object?> j) =>
      PrayerLog(id: j['id'] as String, day: j['day'] as String, prayer: Prayer.values.byName(j['prayer'] as String));
}

/// A city to pick when the user prefers not to share their location.
class PrayerCity {
  const PrayerCity(this.ar, this.en, this.latitude, this.longitude, this.method);
  final String ar;
  final String en;
  final double latitude;
  final double longitude;

  /// The method commonly used in that country.
  final PrayerMethod method;
}

const prayerCities = <PrayerCity>[
  PrayerCity('مكة المكرمة', 'Makkah', 21.4225, 39.8262, PrayerMethod.ummAlQura),
  PrayerCity('المدينة المنورة', 'Madinah', 24.4672, 39.6111, PrayerMethod.ummAlQura),
  PrayerCity('الرياض', 'Riyadh', 24.7136, 46.6753, PrayerMethod.ummAlQura),
  PrayerCity('جدة', 'Jeddah', 21.5433, 39.1728, PrayerMethod.ummAlQura),
  PrayerCity('الدمام', 'Dammam', 26.4207, 50.0888, PrayerMethod.ummAlQura),
  PrayerCity('الطائف', 'Taif', 21.2703, 40.4158, PrayerMethod.ummAlQura),
  PrayerCity('تبوك', 'Tabuk', 28.3835, 36.5662, PrayerMethod.ummAlQura),
  PrayerCity('أبها', 'Abha', 18.2164, 42.5053, PrayerMethod.ummAlQura),
  PrayerCity('بريدة', 'Buraydah', 26.3592, 43.9818, PrayerMethod.ummAlQura),
  PrayerCity('حائل', 'Hail', 27.5114, 41.7208, PrayerMethod.ummAlQura),
  PrayerCity('جازان', 'Jazan', 16.8892, 42.5511, PrayerMethod.ummAlQura),
  PrayerCity('نجران', 'Najran', 17.4917, 44.1322, PrayerMethod.ummAlQura),
  PrayerCity('دبي', 'Dubai', 25.2048, 55.2708, PrayerMethod.dubai),
  PrayerCity('أبوظبي', 'Abu Dhabi', 24.4539, 54.3773, PrayerMethod.dubai),
  PrayerCity('الكويت', 'Kuwait City', 29.3759, 47.9774, PrayerMethod.kuwait),
  PrayerCity('الدوحة', 'Doha', 25.2854, 51.5310, PrayerMethod.qatar),
  PrayerCity('المنامة', 'Manama', 26.2285, 50.5860, PrayerMethod.dubai),
  PrayerCity('مسقط', 'Muscat', 23.5880, 58.3829, PrayerMethod.dubai),
  PrayerCity('عمّان', 'Amman', 31.9539, 35.9106, PrayerMethod.muslimWorldLeague),
  PrayerCity('القاهرة', 'Cairo', 30.0444, 31.2357, PrayerMethod.egyptian),
  PrayerCity('الإسكندرية', 'Alexandria', 31.2001, 29.9187, PrayerMethod.egyptian),
  PrayerCity('بغداد', 'Baghdad', 33.3152, 44.3661, PrayerMethod.muslimWorldLeague),
  PrayerCity('دمشق', 'Damascus', 33.5138, 36.2765, PrayerMethod.muslimWorldLeague),
  PrayerCity('بيروت', 'Beirut', 33.8938, 35.5018, PrayerMethod.muslimWorldLeague),
  PrayerCity('القدس', 'Jerusalem', 31.7683, 35.2137, PrayerMethod.muslimWorldLeague),
  PrayerCity('صنعاء', 'Sanaa', 15.3694, 44.1910, PrayerMethod.muslimWorldLeague),
  PrayerCity('الخرطوم', 'Khartoum', 15.5007, 32.5599, PrayerMethod.egyptian),
  PrayerCity('طرابلس', 'Tripoli', 32.8872, 13.1913, PrayerMethod.muslimWorldLeague),
  PrayerCity('تونس', 'Tunis', 36.8065, 10.1815, PrayerMethod.muslimWorldLeague),
  PrayerCity('الجزائر', 'Algiers', 36.7538, 3.0588, PrayerMethod.muslimWorldLeague),
  PrayerCity('الرباط', 'Rabat', 34.0209, -6.8416, PrayerMethod.muslimWorldLeague),
  PrayerCity('إسطنبول', 'Istanbul', 41.0082, 28.9784, PrayerMethod.muslimWorldLeague),
  PrayerCity('كراتشي', 'Karachi', 24.8607, 67.0011, PrayerMethod.karachi),
  PrayerCity('جاكرتا', 'Jakarta', -6.2088, 106.8456, PrayerMethod.muslimWorldLeague),
  PrayerCity('كوالالمبور', 'Kuala Lumpur', 3.1390, 101.6869, PrayerMethod.muslimWorldLeague),
  PrayerCity('لندن', 'London', 51.5074, -0.1278, PrayerMethod.muslimWorldLeague),
  PrayerCity('نيويورك', 'New York', 40.7128, -74.0060, PrayerMethod.northAmerica),
];
