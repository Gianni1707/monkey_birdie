import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/selettore_lingua.dart';
import '../application/auth_controller.dart';
import 'auth_widgets.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _accedi() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(authControllerProvider.notifier).accedi(
          email: _email.text.trim(),
          password: _password.text,
        );
    // In caso di successo, il redirect del router porta automaticamente alla home.
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
                      const SizedBox(height: 8),
                      Image.asset(
                        'assets/branding/logo_uccello.png',
                        height: 108,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'MonkeyBirdie',
                        style: theme.textTheme.displaySmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        l10n.loginSubtitle,
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
                            icona: Icons.lock_outline,
                            password: true,
                            autofillHints: const [AutofillHints.password],
                            validator: (v) => (v == null || v.length < 6)
                                ? l10n.passwordMin
                                : null,
                          ),
                          const SizedBox(height: 24),
                          BottonePrimarioAuth(
                            testo: l10n.login,
                            isLoading: isLoading,
                            onPressed: _accedi,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _FooterLink(
                        domanda: l10n.noAccountQuestion,
                        azione: l10n.register,
                        onTap: isLoading
                            ? null
                            : () => context.push('/register'),
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
