import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../collection/presentation/collection_screen.dart';
import '../../map/presentation/mappa_screen.dart';
import '../../profilo/presentation/profilo_screen.dart';
import '../application/home_tab_provider.dart';
import 'home_screen.dart';

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
