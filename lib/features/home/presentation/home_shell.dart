import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/application/auth_controller.dart';
import '../../collection/presentation/collection_screen.dart';
import '../../recognition/presentation/recognition_screen.dart';

/// Contenitore principale post-login: tab Riconosci / Collezione.
class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  int _index = 0;

  static const _titoli = ['Riconosci', 'Collezione'];
  static const _pagine = [RecognitionScreen(), CollectionScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titoli[_index]),
        actions: [
          IconButton(
            tooltip: 'Esci',
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authControllerProvider.notifier).esci(),
          ),
        ],
      ),
      body: IndexedStack(index: _index, children: _pagine),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.mic), label: 'Riconosci'),
          NavigationDestination(
              icon: Icon(Icons.collections_bookmark), label: 'Collezione',),
        ],
      ),
    );
  }
}
