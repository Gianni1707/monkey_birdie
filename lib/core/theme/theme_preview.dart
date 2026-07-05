import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Galleria del design system (SOLO anteprima del tema, non è una schermata
/// dell'app). Mostra token colore, scala tipografica e componenti base resi.
class ThemePreviewScreen extends StatefulWidget {
  const ThemePreviewScreen({super.key});

  @override
  State<ThemePreviewScreen> createState() => _ThemePreviewScreenState();
}

class _ThemePreviewScreenState extends State<ThemePreviewScreen> {
  final _selezione = {'Comuni', 'Vicino a me'};
  int _nav = 0;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Design system')),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _nav,
        onDestinationSelected: (i) => setState(() => _nav = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.graphic_eq_outlined),
            selectedIcon: Icon(Icons.graphic_eq),
            label: 'Riconosci',
          ),
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map),
            label: 'Mappa',
          ),
          NavigationDestination(
            icon: Icon(Icons.collections_bookmark_outlined),
            selectedIcon: Icon(Icons.collections_bookmark),
            label: 'Collezione',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profilo',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          _titolo(t, 'Colori'),
          const SizedBox(height: 12),
          const _Swatches(),
          const SizedBox(height: 28),
          _titolo(t, 'Tipografia'),
          const SizedBox(height: 8),
          Text('Display · Source Serif 4', style: t.displaySmall),
          Text('Titolo scheda · serif', style: t.headlineSmall),
          Text('Sezione · titleMedium serif', style: t.titleMedium),
          const SizedBox(height: 6),
          Text(
            'Corpo · Inter. Riconosci gli uccelli dal canto, collezionali e '
            'condividili. Stile guida da campo, molto spazio bianco.',
            style: t.bodyLarge,
          ),
          Text('Etichetta · label Inter', style: t.labelLarge),
          const SizedBox(height: 28),
          _titolo(t, 'Scheda "guida da campo"'),
          const SizedBox(height: 8),
          const _SchedaEsempio(),
          const SizedBox(height: 28),
          _titolo(t, 'Chip filtro'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final f in const ['Comuni', 'Rare', 'Vicino a me', 'Rapaci'])
                FilterChip(
                  label: Text(f),
                  selected: _selezione.contains(f),
                  onSelected: (v) => setState(
                    () => v ? _selezione.add(f) : _selezione.remove(f),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 28),
          _titolo(t, 'Pulsanti'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              FilledButton(onPressed: () {}, child: const Text('Primario')),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: AppColors.onSecondary,
                ),
                onPressed: () {},
                child: const Text('Secondario'),
              ),
              OutlinedButton(onPressed: () {}, child: const Text('Outlined')),
              TextButton(onPressed: () {}, child: const Text('Testo')),
            ],
          ),
          const SizedBox(height: 28),
          _titolo(t, 'Ricerca'),
          const SizedBox(height: 8),
          TextField(
            decoration: InputDecoration(
              hintText: 'Cerca una specie o un luogo…',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide: const BorderSide(color: AppColors.outline),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide: const BorderSide(color: AppColors.outline),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _titolo(TextTheme t, String s) => Text(s, style: t.titleMedium);
}

/// Riquadri dei token colore principali.
class _Swatches extends StatelessWidget {
  const _Swatches();

  @override
  Widget build(BuildContext context) {
    const items = <(String, Color, Color)>[
      ('Primary\n#234F3E', AppColors.primary, AppColors.onPrimary),
      ('Secondary\n#A14743', AppColors.secondary, AppColors.onSecondary),
      ('Tertiary\n#9C7A3C', AppColors.tertiary, AppColors.onTertiary),
      ('Background\n#F8F6EF', AppColors.background, AppColors.neutral),
      ('Card\n#FFFFFF', AppColors.surfaceWhite, AppColors.neutral),
      ('Surface\n#F3F0E7', AppColors.surface, AppColors.neutral),
      ('Testo\n#2A2A24', AppColors.neutral, AppColors.background),
      ('Error\n#B3261E', AppColors.error, AppColors.onError),
    ];
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final (label, bg, fg) in items)
          Container(
            width: 104,
            height: 72,
            padding: const EdgeInsets.all(10),
            alignment: Alignment.bottomLeft,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.outline),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: fg,
                fontFamily: 'Inter',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                height: 1.25,
              ),
            ),
          ),
      ],
    );
  }
}

/// Esempio di scheda specie in stile guida da campo (dati fittizi).
class _SchedaEsempio extends StatelessWidget {
  const _SchedaEsempio();

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 120,
            color: AppColors.primaryContainer,
            alignment: Alignment.center,
            child: Icon(
              Icons.photo_camera_back_outlined,
              size: 40,
              color: scheme.onPrimaryContainer,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Cinciallegra', style: t.headlineSmall),
                Text(
                  'Parus major',
                  style: t.bodyMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: AppColors.neutralMuted,
                  ),
                ),
                const SizedBox(height: 10),
                const Wrap(
                  spacing: 8,
                  children: [
                    Chip(label: Text('Comune')),
                    Chip(label: Text('Difficoltà (stima): comune')),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'Piccolo passeriforme diffuso in parchi e giardini. '
                  'Canto vario e squillante; frequenta le mangiatoie.',
                  style: t.bodyLarge,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
