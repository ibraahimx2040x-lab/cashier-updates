import 'package:flutter/material.dart';

import '../../data/models/health.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/common.dart';

/// Asks for the user's sex. With [required] there is no way to dismiss it
/// (accounts made before sign-up asked); otherwise it can be cancelled.
Future<Sex?> askSex(BuildContext context, {Sex? current, bool required = false}) => showDialog<Sex>(
      context: context,
      barrierDismissible: !required,
      builder: (c) {
        final l = AppLocalizations.of(c);
        Widget option(Sex s, IconData icon, String label) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: AppCard(
                color: current == s ? Theme.of(c).colorScheme.primaryContainer : null,
                onTap: () => Navigator.pop(c, s),
                child: Row(children: [
                  IconBadge(icon),
                  const SizedBox(width: 12),
                  Expanded(child: Text(label, style: Theme.of(c).textTheme.titleSmall)),
                  if (current == s) const Icon(Icons.check_circle),
                ]),
              ),
            );
        return PopScope(
          canPop: !required,
          child: AlertDialog(
            title: Text(l.sexAskTitle),
            content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Text(l.sexWhy),
              const SizedBox(height: 16),
              option(Sex.male, Icons.male, l.sexMale),
              option(Sex.female, Icons.female, l.sexFemale),
            ]),
            actions: [if (!required) TextButton(onPressed: () => Navigator.pop(c), child: Text(l.cancel))],
          ),
        );
      },
    );
