import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/format.dart';
import '../../data/auth.dart';
import '../../data/data_controller.dart';
import '../../data/models/health.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/common.dart';
import 'sex_dialog.dart';
import '../../widgets/home_logo.dart';

/// Screen 21 — profile and account. Sensitive operations re-verify the
/// password; deletion explains consequences first.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _editName(BuildContext context, WidgetRef ref) async {
    final l = AppLocalizations.of(context);
    final s = ref.read(settingsProvider);
    final c = TextEditingController(text: s.displayName);
    var show = s.showNameInGreeting;
    final r = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, set) => AlertDialog(
            title: Text(l.displayName),
            content: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(controller: c, autofocus: true, maxLength: 40),
              SwitchListTile(contentPadding: EdgeInsets.zero, title: Text(l.showNameGreeting), value: show, onChanged: (v) => set(() => show = v)),
            ]),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l.cancel)),
              FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l.save)),
            ],
          )),
    );
    if (r == true) {
      ref.read(dataProvider.notifier).updateSettings((x) => x.copyWith(displayName: c.text.trim(), showNameInGreeting: show));
    }
    c.dispose();
  }

  Future<void> _changePassword(BuildContext context, WidgetRef ref) async {
    final l = AppLocalizations.of(context);
    final cur = TextEditingController(), next = TextEditingController();
    final key = GlobalKey<FormState>();
    String? error;
    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, set) => AlertDialog(
            title: Text(l.changePassword),
            content: Form(
              key: key,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                TextFormField(controller: cur, obscureText: true, decoration: InputDecoration(labelText: l.currentPassword)),
                const SizedBox(height: Space.m),
                TextFormField(
                  controller: next,
                  obscureText: true,
                  decoration: InputDecoration(labelText: l.newPassword, helperText: l.passwordRule, helperMaxLines: 2),
                  validator: (v) => isStrongPassword(v ?? '') ? null : l.errPasswordWeak,
                ),
                if (error != null) Padding(
                  padding: const EdgeInsets.only(top: Space.s),
                  child: Text(error!, style: TextStyle(color: Theme.of(ctx).colorScheme.error)),
                ),
              ]),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l.cancel)),
              FilledButton(
                onPressed: () async {
                  if (!key.currentState!.validate()) return;
                  try {
                    await ref.read(authProvider.notifier).changePassword(cur.text, next.text);
                    if (ctx.mounted) Navigator.pop(ctx);
                    if (context.mounted) showSnack(context, l.passwordChanged);
                  } on AuthException {
                    set(() => error = l.errCurrentPassword);
                  }
                },
                child: Text(l.save),
              ),
            ],
          )),
    );
    cur.dispose();
    next.dispose();
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final l = AppLocalizations.of(context);
    final pw = TextEditingController();
    final confirm = TextEditingController();
    final word = l.deleteConfirmWord;
    String? error;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, set) => AlertDialog(
            title: Text(l.deleteAccount),
            content: SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(ref.read(authProvider.notifier).remote ? l.deleteAccountConsequencesRemote : l.deleteAccountConsequences),
                const SizedBox(height: Space.m),
                TextField(controller: pw, obscureText: true, decoration: InputDecoration(labelText: l.password)),
                const SizedBox(height: Space.m),
                TextField(controller: confirm, decoration: InputDecoration(labelText: l.typeToConfirm(word))),
                if (error != null) Padding(
                  padding: const EdgeInsets.only(top: Space.s),
                  child: Text(error!, style: TextStyle(color: Theme.of(ctx).colorScheme.error)),
                ),
              ]),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l.cancel)),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: Theme.of(ctx).colorScheme.error),
                onPressed: () async {
                  if (confirm.text.trim() != word) return set(() => error = l.typeToConfirm(word));
                  final ok = await ref.read(authProvider.notifier).verifyPassword(pw.text);
                  if (!ok) return set(() => error = l.errCurrentPassword);
                  if (ctx.mounted) Navigator.pop(ctx, true);
                },
                child: Text(l.deleteForever),
              ),
            ],
          )),
    );
    pw.dispose();
    confirm.dispose();
    if (ok != true) return;
    final remote = ref.read(authProvider.notifier).remote;
    try {
      // Remote: the request is recorded first; the device copy is cleared
      // only once the server has it.
      await ref.read(authProvider.notifier).deleteAccount(clearLocal: ref.read(dataProvider.notifier).wipe);
      if (remote && context.mounted) showSnack(context, l.deletionRequested);
    } on AuthException {
      if (context.mounted) showSnack(context, l.errNetwork);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final user = ref.watch(authProvider).user;
    final s = ref.watch(settingsProvider);
    final fmt = Fmt.of(context);
    if (user == null) return const Scaffold();
    return Scaffold(
      appBar: AppBar(title: Text(l.profileTitle), actions: const [HomeLogoButton()]),
      body: ResponsiveContainer(
        maxWidth: 680,
        child: ListView(padding: const EdgeInsets.symmetric(vertical: Space.l), children: [
          ListTile(
            leading: IconBadge(Icons.badge_outlined),
            title: Text(l.displayName),
            subtitle: Text(s.displayName.isEmpty ? l.notSet : s.displayName),
            trailing: const Icon(Icons.edit_outlined),
            onTap: () => _editName(context, ref),
          ),
          ListTile(
            leading: IconBadge(s.sex == Sex.female ? Icons.female : Icons.male),
            title: Text(l.sexLabel),
            subtitle: Text(switch (s.sex) { Sex.male => l.sexMale, Sex.female => l.sexFemale, null => l.notSet }),
            trailing: const Icon(Icons.edit_outlined),
            onTap: () async {
              final sex = await askSex(context, current: s.sex);
              if (sex != null) ref.read(dataProvider.notifier).setSex(sex);
            },
          ),
          ListTile(leading: IconBadge(Icons.email_outlined), title: Text(l.email), subtitle: Text(user.email)),
          ListTile(leading: IconBadge(Icons.key_outlined), title: Text(l.signInMethod), subtitle: Text(l.emailPassword)),
          ListTile(
            leading: IconBadge(Icons.verified_outlined),
            title: Text(l.emailVerification),
            subtitle: Text(!ref.read(authProvider.notifier).remote
                ? l.verificationLocal
                : (user.emailConfirmed ? l.emailVerified : l.emailNotVerified)),
          ),
          ListTile(leading: IconBadge(Icons.event_available_outlined), title: Text(l.memberSince), subtitle: Text(fmt.date(user.createdAt))),
          const Divider(),
          ListTile(leading: IconBadge(Icons.password), title: Text(l.changePassword), onTap: () => _changePassword(context, ref)),
          ListTile(
            leading: IconBadge(Icons.logout),
            title: Text(l.signOut),
            onTap: () async {
              if (await confirmDialog(context, title: l.signOut, message: l.signOutBody, confirmLabel: l.signOut, danger: false)) {
                await ref.read(authProvider.notifier).signOut();
              }
            },
          ),
          const Divider(),
          ListTile(
            leading: Icon(Icons.delete_forever_outlined, color: Theme.of(context).colorScheme.error),
            title: Text(l.deleteAccount, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            subtitle: Text(l.deleteAccountSub),
            onTap: () => _delete(context, ref),
          ),
          const SizedBox(height: Space.l),
        ]),
      ),
    );
  }
}
