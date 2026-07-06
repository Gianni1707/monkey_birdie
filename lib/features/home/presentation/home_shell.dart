import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../aggiornamenti/application/aggiornamenti_provider.dart';
import '../../aggiornamenti/presentation/aggiornamento_dialog.dart';
import '../../collection/presentation/collection_screen.dart';
import '../../map/presentation/mappa_screen.dart';
import '../../profilo/presentation/profilo_screen.dart';
import '../application/home_tab_provider.dart';
import 'home_screen.dart';

/// Avviso aggiornamento mostrato al massimo UNA volta per sessione (sopravvive
/// ai rebuild della shell). Su web resta sempre false (provider → null).
bool _avvisoAggiornamentoMostrato = false;

/// Contenitore principale post-login: tab Home / Mappa / Collezione / Profilo.
/// La tab attiva vive in `homeTabProvider` così altre schermate possono
/// cambiarla (es. "Mostra sulla mappa" dalla collezione).
class HomeShell extends ConsumerWidget {
  const HomeShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final index = ref.watch(homeTabProvider);
    void vaiA(int i) => ref.read(homeTabProvider.notifier).state = i;

    // Controllo aggiornamenti (solo Android; fail-safe silenzioso). Alla prima
    // risposta con update disponibile, mostra l'avviso non bloccante una volta.
    ref.listen(controlloAggiornamentiProvider, (_, next) {
      final v = next.valueOrNull;
      if (v != null && !_avvisoAggiornamentoMostrato) {
        _avvisoAggiornamentoMostrato = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) mostraAggiornamentoDialog(context, v);
        });
      }
    });

    final titoli = [
      l10n.tabHome,
      l10n.tabMap,
      l10n.tabCollection,
      l10n.tabProfile,
    ];
    final pagine = [
      HomeScreen(onVediCollezione: () => vaiA(2)),
      const MappaScreen(),
      const CollectionScreen(),
      const ProfiloScreen(),
    ];

    return Scaffold(
      // Lingua e logout vivono nella schermata Impostazioni: l'AppBar resta
      // pulita (solo il titolo della tab).
      appBar: AppBar(title: Text(titoli[index])),
      body: IndexedStack(index: index, children: pagine),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: vaiA,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: l10n.tabHome,
          ),
          NavigationDestination(
            icon: const Icon(Icons.map_outlined),
            selectedIcon: const Icon(Icons.map),
            label: l10n.tabMap,
          ),
          NavigationDestination(
            icon: const Icon(Icons.collections_bookmark),
            label: l10n.tabCollection,
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: const Icon(Icons.person),
            label: l10n.tabProfile,
          ),
        ],
      ),
    );
  }
}
