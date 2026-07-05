import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../collection/presentation/collection_screen.dart';
import '../../map/presentation/mappa_screen.dart';
import '../../profilo/presentation/profilo_screen.dart';
import 'home_screen.dart';

/// Contenitore principale post-login: tab Home / Mappa / Collezione / Profilo.
/// Il riconoscimento non è più una tab: si avvia dai comandi Audio/Foto in Home
/// (flusso di cattura esistente, pushato su una schermata dedicata).
class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final titoli = [
      l10n.tabHome,
      l10n.tabMap,
      l10n.tabCollection,
      l10n.tabProfile,
    ];
    final pagine = [
      HomeScreen(onVediCollezione: () => setState(() => _index = 2)),
      const MappaScreen(),
      const CollectionScreen(),
      const ProfiloScreen(),
    ];

    return Scaffold(
      // Lingua e logout ora vivono nel foglio Impostazioni del Profilo:
      // l'AppBar resta pulita (solo il titolo della tab).
      appBar: AppBar(title: Text(titoli[_index])),
      body: IndexedStack(index: _index, children: pagine),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
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
