import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../data/auth.dart';
import '../../data/data_controller.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/common.dart';

/// Shows the privacy policy or terms. The text describes what local mode
/// actually does, so it matches real behaviour.
void showLegal(BuildContext context, {required bool privacy}) {
  final l = AppLocalizations.of(context);
  showDialog<void>(
    context: context,
    builder: (c) => AlertDialog(
      title: Text(privacy ? l.privacyPolicy : l.terms),
      content: SingleChildScrollView(child: Text(privacy ? l.privacyText : l.termsText)),
      actions: [TextButton(onPressed: () => Navigator.pop(c), child: Text(l.ok))],
    ),
  );
}

/// Screen 24 — privacy, security and data management.
class PrivacyScreen extends ConsumerWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    Widget header(String s) => Padding(
          padding: const EdgeInsets.fromLTRB(Space.gutter, Space.xl, Space.gutter, Space.s),
          child: Text(s, style: t.titleSmall?.copyWith(color: Theme.of(context).colorScheme.secondary)),
        );
    return Scaffold(
      appBar: AppBar(title: Text(l.privacyTitle)),
      body: ResponsiveContainer(
        maxWidth: 760,
        child: ListView(padding: const EdgeInsets.only(bottom: Space.xxl), children: [
          header(l.documents),
          ListTile(leading: IconBadge(Icons.policy_outlined), title: Text(l.privacyPolicy), onTap: () => showLegal(context, privacy: true)),
          ListTile(leading: IconBadge(Icons.gavel_outlined), title: Text(l.terms), onTap: () => showLegal(context, privacy: false)),
          header(l.whatWeStore),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Space.gutter),
            child: Text(ref.watch(authProvider.notifier).remote ? l.whatWeStoreBodyRemote : l.whatWeStoreBody),
          ),
          header(l.aiData),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Space.gutter),
            child: Text(l.aiDataBody),
          ),
          ListTile(
            leading: IconBadge(Icons.auto_awesome_outlined),
            title: Text(l.manageAssistantAccess),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(Routes.assistantSettings),
          ),
          header(l.yourData),
          ListTile(
            leading: IconBadge(Icons.download_outlined),
            title: Text(l.exportData),
            subtitle: Text(l.exportDataSub),
            onTap: () async {
              final json = ref.read(dataProvider.notifier).exportJson();
              await Clipboard.setData(ClipboardData(text: json));
              if (context.mounted) showSnack(context, l.exportCopied(json.length));
            },
          ),
          ListTile(
            leading: IconBadge(Icons.delete_outline),
            title: Text(l.deleteDataRequest),
            subtitle: Text(l.deleteDataRequestSub),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(Routes.profile),
          ),
          header(l.sessions),
          ListTile(leading: IconBadge(Icons.devices_outlined), title: Text(l.thisDevice), subtitle: Text(ref.watch(authProvider.notifier).remote ? l.sessionsRemote : l.sessionsLocal)),
        ]),
      ),
    );
  }
}
