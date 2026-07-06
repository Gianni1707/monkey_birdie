import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../application/auth_controller.dart';
import 'auth_widgets.dart';

/// Passo 1 del recupero password: l'utente inserisce l'email e riceve il link
/// (che riporta alla PWA). Nessuna conferma se l'email esiste o meno, per non
/// rivelare quali indirizzi sono registrati.
class RecuperaPasswordScreen extends ConsumerStatefulWidget {
  const RecuperaPasswordScreen({super.key});

  @override
  ConsumerState<RecuperaPasswordScreen> createState() =>
      _RecuperaPasswordScreenState();
}

class _RecuperaPasswordScreenState
    extends ConsumerState<RecuperaPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  bool _inviata = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _invia() async {
    if (!_formKey.currentState!.validate()) return;
    final ok =
        await ref.read(authControllerProvider.notifier).inviaRecupero(
              _email.text.trim(),
            );
    if (ok && mounted) setState(() => _inviata = true);
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
      appBar: AppBar(title: Text(l10n.recoverPasswordTitle)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          child: _inviata
              ? _Confermato(email: _email.text.trim())
              : Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        l10n.recoverPasswordSubtitle,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 28),
                      CampoAuth(
                        controller: _email,
                        label: l10n.email,
                        hint: l10n.emailHint,
                        icona: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        autofillHints: const [AutofillHints.email],
                        validator: (v) => (v == null || !v.contains('@'))
                            ? l10n.emailInvalid
                            : null,
                      ),
                      const SizedBox(height: 24),
                      BottonePrimarioAuth(
                        testo: l10n.sendRecoveryLink,
                        isLoading: isLoading,
                        onPressed: _invia,
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

/// Schermata di conferma dopo l'invio del link.
class _Confermato extends StatelessWidget {
  const _Confermato({required this.email});
  final String email;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 24),
        Icon(
          Icons.mark_email_read_outlined,
          size: 72,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(height: 20),
        Text(
          l10n.recoveryEmailSent,
          textAlign: TextAlign.center,
          style: theme.textTheme.titleMedium,
        ),
        if (email.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            email,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
        const SizedBox(height: 32),
        OutlinedButton(
          onPressed: () => context.go('/login'),
          child: Text(l10n.backToLogin),
        ),
      ],
    );
  }
}
