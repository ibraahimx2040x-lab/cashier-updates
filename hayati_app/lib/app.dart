import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'data/data_controller.dart';
import 'data/store/local_store.dart';
import 'l10n/app_localizations.dart';

/// Language is a device-level preference so the welcome and sign-in
/// screens are already in the user's language. Changing it never touches
/// user data.
class LocaleController extends Notifier<Locale> {
  @override
  Locale build() {
    final saved = ref.read(localStoreProvider).readString(DevicePrefs.localeKey);
    if (saved == 'ar' || saved == 'en') return Locale(saved!);
    final device = ui.PlatformDispatcher.instance.locale.languageCode;
    return Locale(device == 'en' ? 'en' : 'ar');
  }

  void set(Locale l) {
    state = l;
    ref.read(localStoreProvider).writeString(DevicePrefs.localeKey, l.languageCode);
  }
}

final localeProvider = NotifierProvider<LocaleController, Locale>(LocaleController.new);

class HayatiApp extends ConsumerWidget {
  const HayatiApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final mode = ref.watch(settingsProvider.select((s) => s.themeMode));
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      onGenerateTitle: (c) => AppLocalizations.of(c).appName,
      debugShowCheckedModeBanner: false,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: AppTheme.light(locale),
      darkTheme: AppTheme.dark(locale),
      themeMode: switch (mode) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      },
      routerConfig: router,
    );
  }
}
