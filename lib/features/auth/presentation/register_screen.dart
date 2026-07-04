import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/supabase/supabase_providers.dart';
import '../../../l10n/app_localizations.dart';
import '../application/auth_controller.dart';

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
        SnackBar(content: Text(AppLocalizations.of(context).registrationEmailConfirm)),
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

    return Scaffold(
      appBar: AppBar(title: Text(l10n.register)),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _username,
                    decoration: InputDecoration(
                      labelText: l10n.username,
                      prefixIcon: const Icon(Icons.person_outline),
                    ),
                    validator: (v) =>
                        (v == null || v.trim().length < 3) ? l10n.usernameMin : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    decoration: InputDecoration(
                      labelText: l10n.email,
                      prefixIcon: const Icon(Icons.email_outlined),
                    ),
                    validator: (v) =>
                        (v == null || !v.contains('@')) ? l10n.emailInvalid : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _password,
                    obscureText: true,
                    autofillHints: const [AutofillHints.newPassword],
                    decoration: InputDecoration(
                      labelText: l10n.password,
                      prefixIcon: const Icon(Icons.lock_outline),
                    ),
                    validator: (v) =>
                        (v == null || v.length < 6) ? l10n.passwordMin : null,
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: isLoading ? null : _registrati,
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(l10n.createAccount),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: isLoading ? null : () => context.pop(),
                    child: Text(l10n.haveAccount),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
