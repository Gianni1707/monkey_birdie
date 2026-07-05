import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/selettore_lingua.dart';
import '../../auth/application/auth_controller.dart';
import 'account_screen.dart';
import 'informazioni_screen.dart';

/// Hub "Impostazioni": categorie (Account / Informazioni / Lingua) + Esci.
/// Account e Informazioni aprono sotto-schermate. Aperta dalla riga
/// Impostazioni nel Profilo (schermata piena, non più foglio).
class ImpostazioniScreen extends ConsumerWidget {
  const ImpostazioniScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            l10n.settingsSubtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                _RigaCategoria(
                  icona: Icons.person_outline,
                  titolo: l10n.accountTitle,
                  sottotitolo: l10n.accountSubtitle,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const AccountScreen(),
                    ),
                  ),
                ),
                const Divider(height: 1),
                _RigaCategoria(
                  icona: Icons.info_outline,
                  titolo: l10n.aboutTitle,
                  sottotitolo: l10n.aboutSubtitle,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const InformazioniScreen(),
                    ),
                  ),
                ),
                const Divider(height: 1),
                const _SezioneLingua(),
              ],
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => ref.read(authControllerProvider.notifier).esci(),
            icon: const Icon(Icons.logout),
            label: Text(l10n.logout),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(54),
              backgroundColor: theme.colorScheme.error,
              foregroundColor: theme.colorScheme.onError,
            ),
          ),
        ],
      ),
    );
  }
}

/// Riga-categoria con icona tonda, titolo serif, sottotitolo e chevron.
class _RigaCategoria extends StatelessWidget {
  const _RigaCategoria({
    required this.icona,
    required this.titolo,
    required this.sottotitolo,
    required this.onTap,
  });
  final IconData icona;
  final String titolo;
  final String sottotitolo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: CircleAvatar(
        backgroundColor: AppColors.surfaceHighest,
        foregroundColor: AppColors.primary,
        child: Icon(icona),
      ),
      title: Text(titolo, style: theme.textTheme.titleMedium),
      subtitle: Text(sottotitolo),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

/// Riga Lingua: come le altre ma col selettore rettangolare inline a 3 opzioni.
class _SezioneLingua extends StatelessWidget {
  const _SezioneLingua();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: AppColors.surfaceHighest,
                foregroundColor: AppColors.primary,
                child: Icon(Icons.translate),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.language, style: theme.textTheme.titleMedium),
                    Text(
                      l10n.languageSubtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const SelettoreLingua(espanso: true),
        ],
      ),
    );
  }
}
