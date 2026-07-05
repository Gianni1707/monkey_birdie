import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/supabase/supabase_providers.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/selettore_lingua.dart';
import '../application/auth_controller.dart';
import 'auth_widgets.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _username.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _registrati() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await ref.read(authControllerProvider.notifier).registrati(
          email: _email.text.trim(),
          password: _password.text,
          username: _username.text.trim(),
        );
    if (!ok || !mounted) return;

    // Se la conferma email è attiva non c'è sessione: torna al login con avviso.
    final session = ref.read(supabaseClientProvider).auth.currentSession;
    if (session == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).registrationEmailConfirm),
        ),
      );
      context.go('/login');
    }
    // Altrimenti il redirect del router porta alla home.
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
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Align(
                alignment: Alignment.centerRight,
                child: SelettoreLingua(),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Spazio riservato per un logo futuro (nessuna immagine ora).
                      const SizedBox(height: 40),
                      Text(
                        'Monkey Bird',
                        style: theme.textTheme.displaySmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        l10n.registerSubtitle,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontStyle: FontStyle.italic,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 28),
                      _Scheda(
                        children: [
                          CampoAuth(
                            controller: _username,
                            label: l10n.username,
                            icona: Icons.person_outline,
                            validator: (v) => (v == null || v.trim().length < 3)
                                ? l10n.usernameMin
                                : null,
                          ),
                          const SizedBox(height: 18),
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
                          const SizedBox(height: 18),
                          CampoAuth(
                            controller: _password,
                            label: l10n.password,
                            hint: l10n.passwordMin,
                            icona: Icons.lock_outline,
                            password: true,
                            autofillHints: const [AutofillHints.newPassword],
                            validator: (v) => (v == null || v.length < 6)
                                ? l10n.passwordMin
                                : null,
                          ),
                          const SizedBox(height: 24),
                          BottonePrimarioAuth(
                            testo: l10n.createAccount,
                            isLoading: isLoading,
                            onPressed: _registrati,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _FooterLink(
                        domanda: l10n.haveAccountQuestion,
                        azione: l10n.login,
                        onTap: isLoading ? null : () => context.pop(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Card contenitore del form (angoli morbidi, sfondo del tema).
class _Scheda extends StatelessWidget {
  const _Scheda({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}

/// "Domanda? Azione" con la parola-azione evidenziata (link).
class _FooterLink extends StatelessWidget {
  const _FooterLink({
    required this.domanda,
    required this.azione,
    required this.onTap,
  });
  final String domanda;
  final String azione;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          domanda,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        TextButton(
          onPressed: onTap,
          child: Text(
            azione,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
