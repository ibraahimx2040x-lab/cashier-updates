import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/router/route_paths.dart';
import '../l10n/app_localizations.dart';
import 'brand.dart';
import 'common.dart';

/// Editors that hold typing not yet saved. The logo asks before leaving
/// while any of them does.
abstract final class UnsavedGuard {
  static final _dirty = <Object>{};

  static void mark(Object owner, bool dirty) => dirty ? _dirty.add(owner) : _dirty.remove(owner);
  static bool get any => _dirty.isNotEmpty;
  static void clear() => _dirty.clear();
}

/// The Sanad mark in a screen's app bar: one tap back to "My day" from
/// anywhere, asking first when something typed would be lost.
class HomeLogoButton extends StatelessWidget {
  const HomeLogoButton({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return IconButton(
      tooltip: l.logoHome,
      icon: SanadMark(size: 26, color: scheme.primary),
      onPressed: () async {
        if (UnsavedGuard.any && !await confirmDiscard(context)) return;
        UnsavedGuard.clear();
        if (context.mounted) context.go(Routes.home);
      },
    );
  }
}
