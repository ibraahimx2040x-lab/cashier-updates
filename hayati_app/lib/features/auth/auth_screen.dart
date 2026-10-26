import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../data/auth.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/common.dart';
import '../settings/privacy_screen.dart';

/// Screen 3 — sign up / sign in in one screen with two modes.
class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key, this.signUp = false});
  final bool signUp;

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  late bool _signUp = widget.signUp;
  bool _show = false;
  bool _agree = false;
  bool _loading = false;
  String? _error;

  /// The message above is information, not an error.
  bool _info = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  String _message(AppLocalizations l, AuthErrorCode c) => switch (c) {
        AuthErrorCode.invalidEmail => l.errEmail,
        AuthErrorCode.weakPassword => l.errPasswordWeak,
        AuthErrorCode.emailExists => l.errEmailExists,
        AuthErrorCode.invalidCredentials => l.errCredentials,
        AuthErrorCode.network => l.errNetwork,
        AuthErrorCode.confirmEmail => l.confirmEmailSent,
        AuthErrorCode.emailNotConfirmed => l.errEmailNotConfirmed,
        AuthErrorCode.rateLimited => l.errRateLimited,
      };

  Future<void> _submit() async {
    final l = AppLocalizations.of(context);
    setState(() {
      _error = null;
      _info = false;
    });
    if (!_form.currentState!.validate()) return;
    if (_signUp && !_agree) {
      setState(() => _error = l.errAgree);
      return;
    }
    setState(() => _loading = true);
    try {
      final auth = ref.read(authProvider.notifier);
      if (_signUp) {
        await auth.signUp(_email.text, _password.text);
      } else {
        await auth.signIn(_email.text, _password.text);
      }
      TextInput.finishAutofillContext();
      // Router redirect navigates once the session is confirmed.
    } on AuthException catch (e) {
      setState(() {
        _error = _message(l, e.code);
        // Account created; the next step is the link in the email.
        if (e.code == AuthErrorCode.confirmEmail) {
          _info = true;
          _signUp = false;
        }
      });
    } catch (_) {
      setState(() => _error = l.errNetwork);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _forgot() async {
    final l = AppLocalizations.of(context);
    final auth = ref.read(authProvider.notifier);
    if (!auth.remote) {
      await showDialog<void>(
        context: context,
        builder: (c) => AlertDialog(
          title: Text(l.forgotTitle),
          content: Text(l.forgotLocalMode),
          actions: [TextButton(onPressed: () => Navigator.pop(c), child: Text(l.ok))],
        ),
      );
      return;
    }
    final email = TextEditingController(text: _email.text.trim());
    final send = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(l.forgotTitle),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(l.forgotRemoteBody),
          const SizedBox(height: Space.m),
          TextField(controller: email, keyboardType: TextInputType.emailAddress, decoration: InputDecoration(labelText: l.email)),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: Text(l.cancel)),
          FilledButton(onPressed: () => Navigator.pop(c, true), child: Text(l.sendResetLink)),
        ],
      ),
    );
    final address = email.text;
    email.dispose();
    if (send != true || !mounted) return;
    try {
      await auth.sendPasswordReset(address);
      // Same message whether or not the address has an account.
      if (mounted) showSnack(context, l.resetLinkSent);
    } on AuthException catch (e) {
      if (mounted) showSnack(context, _message(l, e.code));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: ResponsiveContainer(
          maxWidth: 480,
          child: Form(
            key: _form,
            child: AutofillGroup(
              child: ListView(padding: const EdgeInsets.all(Space.xl), children: [
                Text(_signUp ? l.signUpTitle : l.signInTitle, style: t.headlineSmall),
                const SizedBox(height: Space.s),
                Text(_signUp ? l.signUpSubtitle : l.signInSubtitle,
                    style: t.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                const SizedBox(height: Space.xl),
                AppTextField(
                  label: l.email,
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  textInputAction: TextInputAction.next,
                  validator: (v) => isValidEmail(v ?? '') ? null : l.errEmail,
                ),
                const SizedBox(height: Space.l),
                AppTextField(
                  label: l.password,
                  controller: _password,
                  obscure: !_show,
                  autofillHints: [_signUp ? AutofillHints.newPassword : AutofillHints.password],
                  textInputAction: _signUp ? TextInputAction.next : TextInputAction.done,
                  onSubmitted: _signUp ? null : (_) => _submit(),
                  hint: _signUp ? l.passwordRule : null,
                  suffix: IconButton(
                    tooltip: _show ? l.hidePassword : l.showPassword,
                    icon: Icon(_show ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                    onPressed: () => setState(() => _show = !_show),
                  ),
                  validator: (v) {
                    if ((v ?? '').isEmpty) return l.errRequired;
                    if (_signUp && !isStrongPassword(v!)) return l.errPasswordWeak;
                    return null;
                  },
                ),
                if (_signUp) ...[
                  const SizedBox(height: Space.l),
                  AppTextField(
                    label: l.confirmPassword,
                    controller: _confirm,
                    obscure: !_show,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _submit(),
                    validator: (v) => v == _password.text ? null : l.errPasswordMatch,
                  ),
                  const SizedBox(height: Space.m),
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    value: _agree,
                    onChanged: (v) => setState(() => _agree = v ?? false),
                    title: Wrap(crossAxisAlignment: WrapCrossAlignment.center, children: [
                      Text(l.agreePrefix),
                      InkWell(onTap: () => showLegal(context, privacy: false), child: Text(l.terms, style: TextStyle(color: Theme.of(context).colorScheme.secondary, decoration: TextDecoration.underline))),
                      Text(' ${l.and} '),
                      InkWell(onTap: () => showLegal(context, privacy: true), child: Text(l.privacyPolicy, style: TextStyle(color: Theme.of(context).colorScheme.secondary, decoration: TextDecoration.underline))),
                    ]),
                  ),
                ] else
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: TextButton(onPressed: _forgot, child: Text(l.forgotPassword)),
                  ),
                if (_error != null) ...[
                  const SizedBox(height: Space.s),
                  Semantics(
                    liveRegion: true,
                    child: Container(
                      padding: const EdgeInsets.all(Space.m),
                      decoration: BoxDecoration(
                        color: (_info ? Theme.of(context).colorScheme.secondary : Theme.of(context).colorScheme.error)
                            .withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(Radii.button),
                      ),
                      child: Row(children: [
                        Icon(_info ? Icons.mark_email_read_outlined : Icons.error_outline,
                            color: _info ? Theme.of(context).colorScheme.secondary : Theme.of(context).colorScheme.error),
                        const SizedBox(width: Space.s),
                        Expanded(child: Text(_error!)),
                      ]),
                    ),
                  ),
                ],
                const SizedBox(height: Space.xl),
                PrimaryButton(label: _signUp ? l.createAccount : l.signIn, loading: _loading, onPressed: _submit),
                const SizedBox(height: Space.m),
                TextButton(
                  onPressed: _loading
                      ? null
                      : () => setState(() {
                            _signUp = !_signUp;
                            _error = null;
                          }),
                  child: Text(_signUp ? l.switchToSignIn : l.switchToSignUp),
                ),
                const SizedBox(height: Space.l),
                Text(ref.read(authProvider.notifier).remote ? l.cloudModeNotice : l.localModeNotice, style: t.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant), textAlign: TextAlign.center),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
