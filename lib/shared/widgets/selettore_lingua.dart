import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/locale/locale_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../l10n/app_localizations.dart';

/// Selettore lingua UNICO dell'app: toggle **rettangolare a 3 opzioni**
/// (Automatico · Italiano · Inglese), collegato al cambio lingua globale
/// (`localeControllerProvider`). Usato sia nelle schermate di accesso sia nelle
/// Impostazioni, così l'aspetto è sempre lo stesso.
/// - [espanso] = true: i segmenti riempiono la larghezza (Impostazioni).
///   false: dimensione al contenuto (angolo delle schermate di accesso).
class SelettoreLingua extends ConsumerWidget {
  const SelettoreLingua({super.key, this.espanso = false});

  final bool espanso;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final code = ref.watch(localeControllerProvider)?.languageCode;

    final opzioni = <(String?, String)>[
      (null, l10n.languageAutoShort),
      ('it', l10n.languageItalian),
      ('en', l10n.languageEnglish),
    ];

    final segmenti = [
      for (final (valore, etichetta) in opzioni)
        _Segmento(
          etichetta: etichetta,
          selezionato: code == valore,
          onTap: () => ref.read(localeControllerProvider.notifier).imposta(
                valore == null ? null : Locale(valore),
              ),
        ),
    ];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outline),
      ),
      child: Row(
        mainAxisSize: espanso ? MainAxisSize.max : MainAxisSize.min,
        children: [
          for (final s in segmenti)
            if (espanso) Expanded(child: s) else s,
        ],
      ),
    );
  }
}

class _Segmento extends StatelessWidget {
  const _Segmento({
    required this.etichetta,
    required this.selezionato,
    required this.onTap,
  });
  final String etichetta;
  final bool selezionato;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selezionato ? AppColors.surfaceWhite : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
          border: selezionato
              ? Border.all(color: AppColors.outline)
              : Border.all(color: Colors.transparent),
        ),
        // FittedBox: una sola riga, si rimpicciolisce se lo spazio è poco
        // (evita che "Italiano"/"Inglese" vadano a capo nei terzi stretti).
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            etichetta,
            maxLines: 1,
            softWrap: false,
            style: TextStyle(
              color: selezionato ? AppColors.neutral : AppColors.neutralMuted,
              fontWeight: selezionato ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
