import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../application/auth_controller.dart';
import '../application/recupero_password_stato.dart';
import 'auth_widgets.dart';

/// Passo 2 del recupero password: raggiunta quando la PWA riceve l'evento
/// `passwordRecovery` (link email aperto). L'utente imposta la nuova password;
/// la sessione di recupero è già attiva, quindi al termine entra in app.
class NuovaPasswordScreen extends ConsumerStatefulWidget {
  const NuovaPasswordScreen({super.key});

  @override
  ConsumerState<NuovaPasswordScreen> createState() =>
      _NuovaPasswordScreenState();
}

class _NuovaPasswordScreenState extends ConsumerState<NuovaPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _password = TextEditingController();
  final _conferma = TextEditingController();

  @override
  void dispose() {
    _password.dispose();
    _conferma.dispose();
    super.dispose();
  }

  Future<void> _salva() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await ref
        .read(authControllerProvider.notifier)
        .aggiornaPassword(_password.text);
    if (!ok || !mounted) return;

    final l10n = AppLocalizations.of(context);
    // Fine flusso di recupero: sblocca il router e vai in home (già connesso).
    recuperoPasswordInCorso.value = false;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(l10n.passwordUpdated)));
    context.go('/');
  }

  Future<void> _annulla() async {
    // Abbandona il recupero: chiudi la sessione temporanea e torna al login.
    recuperoPasswordInCorso.value = false;
    await ref.read(authControllerProvider.notifier).esci();
    if (mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authControllerProvider, (_, next) {
      if (next.hasError && !next.isLoading) {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(SnackBar(content: Text('${next.error}')));
      }
    });

    final isLoading = ref.watch(authControllerProvider).isLoading;
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.newPasswordTitle)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.newPasswordSubtitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 28),
                CampoAuth(
                  controller: _password,
                  label: l10n.newPassword,
                  icona: Icons.lock_outline,
                  password: true,
                  autofillHints: const [AutofillHints.newPassword],
                  validator: (v) =>
                      (v == null || v.length < 6) ? l10n.passwordMin : null,
                ),
                const SizedBox(height: 18),
                CampoAuth(
                  controller: _conferma,
                  label: l10n.confirmPassword,
                  icona: Icons.lock_outline,
                  password: true,
                  validator: (v) =>
                      (v != _password.text) ? l10n.passwordsDoNotMatch : null,
                ),
                const SizedBox(height: 24),
                BottonePrimarioAuth(
                  testo: l10n.updatePassword,
                  isLoading: isLoading,
                  onPressed: _salva,
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: isLoading ? null : _annulla,
                  child: Text(l10n.backToLogin),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
