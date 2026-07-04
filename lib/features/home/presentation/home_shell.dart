import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/locale/locale_controller.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/application/auth_controller.dart';
import '../../collection/presentation/collection_screen.dart';
import '../../map/presentation/mappa_screen.dart';
import '../../profilo/presentation/profilo_screen.dart';
import '../../recognition/presentation/recognition_screen.dart';

/// Contenitore principale post-login: tab Riconosci / Mappa / Collezione / Profilo.
class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  int _index = 0;

  static const _pagine = [
    RecognitionScreen(),
    MappaScreen(),
    CollectionScreen(),
    ProfiloScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final titoli = [
      l10n.tabRecognize,
      l10n.tabMap,
      l10n.tabCollection,
      l10n.tabProfile,
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(titoli[_index]),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.translate),
            tooltip: l10n.language,
            onSelected: (v) {
              final locale = switch (v) {
                'it' => const Locale('it'),
                'en' => const Locale('en'),
                _ => null, // automatica
              };
              ref.read(localeControllerProvider.notifier).imposta(locale);
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'auto', child: Text(l10n.languageSystem)),
              PopupMenuItem(value: 'it', child: Text(l10n.languageItalian)),
              PopupMenuItem(value: 'en', child: Text(l10n.languageEnglish)),
            ],
          ),
          IconButton(
            tooltip: l10n.logout,
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authControllerProvider.notifier).esci(),
          ),
        ],
      ),
      body: IndexedStack(index: _index, children: _pagine),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.mic),
            label: l10n.tabRecognize,
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
