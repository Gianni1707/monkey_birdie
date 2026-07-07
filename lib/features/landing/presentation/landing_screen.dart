import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/link_esterni.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';

// Email di contatto della landing (non segreta). Gli altri link in link_esterni.
const _kEmailContatti = 'beneficogianni@gmail.com';

const double _kMaxWidth = 1120;
const double _kDesktopBreak = 900;

/// Landing marketing di MonkeyBirdie, mostrata SOLO sul web ai non loggati
/// (il router gestisce l'ingresso). Riusa tema, font e screenshot reali dell'app.
class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: LayoutBuilder(
        builder: (context, c) {
          final desktop = c.maxWidth >= _kDesktopBreak;
          return SingleChildScrollView(
            child: Column(
              children: [
                _Header(desktop: desktop),
                _Hero(desktop: desktop),
                _ComeFunziona(desktop: desktop),
                _Caratteristiche(desktop: desktop),
                _Anteprima(desktop: desktop),
                _Disponibile(desktop: desktop),
                const _Chiusura(),
                const _Footer(),
              ],
            ),
          );
        },
      ),
    );
  }
}

Future<void> _apri(String url) async {
  final uri = Uri.tryParse(url);
  if (uri != null) await launchUrl(uri, mode: LaunchMode.externalApplication);
}

/// Contenitore centrato a larghezza massima (mobile-first, desktop centrato).
class _Contenuto extends StatelessWidget {
  const _Contenuto({required this.child, this.padV = 56});
  final Widget child;
  final double padV;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _kMaxWidth),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: padV),
          child: child,
        ),
      ),
    );
  }
}

/// Cornice-telefono attorno a uno screenshot reale (proporzioni dell'APK).
class _Telefono extends StatelessWidget {
  const _Telefono({required this.asset, this.width = 250});
  final String asset;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: AppColors.neutral,
        borderRadius: BorderRadius.circular(width * 0.14),
        boxShadow: const [
          BoxShadow(color: AppColors.shadow, blurRadius: 30, offset: Offset(0, 14)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(width * 0.11),
        child: Image.asset(asset, fit: BoxFit.cover),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.desktop});
  final bool desktop;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    return Container(
      color: AppColors.background,
      child: _Contenuto(
        padV: 16,
        child: Row(
          children: [
            Image.asset('assets/branding/logo_uccello.png', height: 34),
            const SizedBox(width: 10),
            Text(
              'MonkeyBirdie',
              style: t.titleLarge?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            OutlinedButton(
              onPressed: () => context.go('/login'),
              child: Text(l10n.login),
            ),
          ],
        ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.desktop});
  final bool desktop;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;

    final testo = Column(
      crossAxisAlignment:
          desktop ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Text(
          l10n.landingEyebrow.toUpperCase(),
          style: t.labelLarge?.copyWith(
            color: AppColors.tertiary,
            letterSpacing: 1.2,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          l10n.landingHeroTitle,
          textAlign: desktop ? TextAlign.start : TextAlign.center,
          style: t.displaySmall?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          l10n.landingHeroSubtitle,
          textAlign: desktop ? TextAlign.start : TextAlign.center,
          style: t.titleMedium?.copyWith(color: AppColors.neutralMuted),
        ),
        const SizedBox(height: 26),
        FilledButton(
          onPressed: () => context.go('/register'),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.landingStartNow),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward, size: 20),
            ],
          ),
        ),
      ],
    );

    final telefono = _Telefono(asset: 'assets/landing/home.png', width: desktop ? 270 : 230);

    return _Contenuto(
      padV: desktop ? 48 : 32,
      child: desktop
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 24),
                    child: testo,
                  ),
                ),
                const SizedBox(width: 48),
                telefono,
              ],
            )
          : Column(
              children: [testo, const SizedBox(height: 36), telefono],
            ),
    );
  }
}

class _ComeFunziona extends StatelessWidget {
  const _ComeFunziona({required this.desktop});
  final bool desktop;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final passi = [
      (Icons.hearing, l10n.landingStep1),
      (Icons.auto_awesome, l10n.landingStep2),
      (Icons.bookmark_added_outlined, l10n.landingStep3),
    ];
    final items = [
      for (var i = 0; i < passi.length; i++)
        _Passo(numero: i + 1, icona: passi[i].$1, testo: passi[i].$2),
    ];
    return _Contenuto(
      child: Column(
        children: [
          Text(
            l10n.landingHowTitle,
            style: t.headlineMedium?.copyWith(color: AppColors.primary),
          ),
          const SizedBox(height: 40),
          if (desktop)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [for (final it in items) Expanded(child: it)],
            )
          else
            Column(
              children: [
                for (final it in items)
                  Padding(padding: const EdgeInsets.only(bottom: 28), child: it),
              ],
            ),
        ],
      ),
    );
  }
}

class _Passo extends StatelessWidget {
  const _Passo({required this.numero, required this.icona, required this.testo});
  final int numero;
  final IconData icona;
  final String testo;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: const BoxDecoration(
            color: AppColors.surfaceHigh,
            shape: BoxShape.circle,
          ),
          child: Icon(icona, color: AppColors.primary, size: 28),
        ),
        const SizedBox(height: 14),
        Text(
          '${l10n.landingStepWord} $numero'.toUpperCase(),
          style: t.labelMedium?.copyWith(
            color: AppColors.tertiary,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          testo,
          textAlign: TextAlign.center,
          style: t.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _Caratteristiche extends StatelessWidget {
  const _Caratteristiche({required this.desktop});
  final bool desktop;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final cards = [
      _FeatureCard(
        icona: Icons.graphic_eq,
        titolo: l10n.landingFeat1Title,
        corpo: l10n.landingFeat1Body,
      ),
      _FeatureCard(
        icona: Icons.map_outlined,
        titolo: l10n.landingFeat2Title,
        corpo: l10n.landingFeat2Body,
      ),
      _FeatureCard(
        icona: Icons.menu_book_outlined,
        titolo: l10n.landingFeat3Title,
        corpo: l10n.landingFeat3Body,
      ),
      _FeatureCard(
        icona: Icons.groups_outlined,
        titolo: l10n.landingFeat4Title,
        corpo: l10n.landingFeat4Body,
      ),
    ];
    return Container(
      width: double.infinity,
      color: AppColors.surfaceLow,
      child: _Contenuto(
        child: Column(
          children: [
            Text(
              l10n.landingFeaturesTitle,
              textAlign: TextAlign.center,
              style: t.headlineMedium?.copyWith(color: AppColors.primary),
            ),
            const SizedBox(height: 36),
            LayoutBuilder(
              builder: (context, c) {
                final colonne = c.maxWidth >= 900
                    ? 4
                    : c.maxWidth >= 560
                        ? 2
                        : 1;
                const gap = 20.0;
                final w = (c.maxWidth - gap * (colonne - 1)) / colonne;
                return Wrap(
                  spacing: gap,
                  runSpacing: gap,
                  children: [
                    for (final card in cards)
                      SizedBox(width: w, child: card),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.icona,
    required this.titolo,
    required this.corpo,
  });
  final IconData icona;
  final String titolo;
  final String corpo;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icona, color: AppColors.primary, size: 24),
          ),
          const SizedBox(height: 16),
          Text(
            titolo,
            style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(corpo, style: t.bodyMedium?.copyWith(color: AppColors.neutralMuted)),
        ],
      ),
    );
  }
}

class _Anteprima extends StatelessWidget {
  const _Anteprima({required this.desktop});
  final bool desktop;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final telefoni = [
      _Telefono(asset: 'assets/landing/collezione.png', width: desktop ? 230 : 200),
      _Telefono(asset: 'assets/landing/scheda.png', width: desktop ? 230 : 200),
      _Telefono(asset: 'assets/landing/mappa.png', width: desktop ? 230 : 200),
    ];
    return _Contenuto(
      child: Column(
        children: [
          Text(
            l10n.landingPreviewTitle,
            textAlign: TextAlign.center,
            style: t.headlineMedium?.copyWith(color: AppColors.primary),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.landingPreviewSubtitle,
            textAlign: TextAlign.center,
            style: t.titleMedium?.copyWith(color: AppColors.neutralMuted),
          ),
          const SizedBox(height: 36),
          if (desktop)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (final tf in telefoni)
                  Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: tf),
              ],
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final tf in telefoni)
                    Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: tf),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _Disponibile extends StatelessWidget {
  const _Disponibile({required this.desktop});
  final bool desktop;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final iphone = _StoreCard(
      icona: Icons.phone_iphone,
      titolo: l10n.landingIphoneTitle,
      tag: l10n.landingIphoneTag,
      corpo: l10n.landingIphoneBody,
      bottone: l10n.landingIphoneButton,
      onTap: () => context.go('/login'),
    );
    final android = _StoreCard(
      icona: Icons.android,
      titolo: l10n.landingAndroidTitle,
      tag: l10n.landingAndroidTag,
      corpo: l10n.landingAndroidBody,
      bottone: l10n.landingAndroidButton,
      nota: l10n.landingAndroidNote,
      onTap: () => _apri(kUrlReleasesApk),
    );
    return Container(
      width: double.infinity,
      color: AppColors.surfaceLow,
      child: _Contenuto(
        child: Column(
          children: [
            Text(
              l10n.landingAvailEyebrow.toUpperCase(),
              style: t.labelLarge?.copyWith(
                color: AppColors.tertiary,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.landingAvailTitle,
              textAlign: TextAlign.center,
              style: t.headlineMedium?.copyWith(color: AppColors.primary),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.landingAvailSubtitle,
              textAlign: TextAlign.center,
              style: t.titleMedium?.copyWith(color: AppColors.neutralMuted),
            ),
            const SizedBox(height: 32),
            if (desktop)
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: iphone),
                    const SizedBox(width: 20),
                    Expanded(child: android),
                  ],
                ),
              )
            else
              Column(
                children: [iphone, const SizedBox(height: 20), android],
              ),
          ],
        ),
      ),
    );
  }
}

class _StoreCard extends StatelessWidget {
  const _StoreCard({
    required this.icona,
    required this.titolo,
    required this.tag,
    required this.corpo,
    required this.bottone,
    required this.onTap,
    this.nota,
  });
  final IconData icona;
  final String titolo;
  final String tag;
  final String corpo;
  final String bottone;
  final String? nota;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(icona, color: AppColors.onPrimary, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(titolo, style: t.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                    Text(
                      tag.toUpperCase(),
                      style: t.labelSmall?.copyWith(
                        color: AppColors.tertiary,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(corpo, style: t.bodyMedium?.copyWith(color: AppColors.neutralMuted, height: 1.4)),
          const SizedBox(height: 18),
          FilledButton(
            onPressed: onTap,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(bottone),
                const SizedBox(width: 8),
                Icon(nota == null ? Icons.arrow_forward : Icons.download, size: 18),
              ],
            ),
          ),
          if (nota != null) ...[
            const SizedBox(height: 12),
            Text(
              nota!,
              style: t.bodySmall?.copyWith(color: AppColors.neutralMuted),
            ),
          ],
        ],
      ),
    );
  }
}

class _Chiusura extends StatelessWidget {
  const _Chiusura();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      color: AppColors.primary,
      child: _Contenuto(
        padV: 64,
        child: Column(
          children: [
            Text(
              l10n.landingClosing,
              textAlign: TextAlign.center,
              style: t.headlineMedium?.copyWith(
                color: AppColors.onPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 28),
            FilledButton(
              onPressed: () => context.go('/register'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.onPrimary,
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
              ),
              child: Text(l10n.landingEnter),
            ),
          ],
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    Widget link(String testo, VoidCallback onTap) => TextButton(
          onPressed: onTap,
          child: Text(
            testo,
            style: t.bodyMedium?.copyWith(color: AppColors.neutralMuted),
          ),
        );
    return Container(
      width: double.infinity,
      color: AppColors.background,
      child: _Contenuto(
        padV: 24,
        child: Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          runSpacing: 8,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/branding/logo_uccello.png', height: 26),
                const SizedBox(width: 8),
                Text(
                  'MonkeyBirdie',
                  style: t.titleMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                link(l10n.landingGithub, () => _apri(kUrlGithubProfilo)),
                link(l10n.aboutDonate, () => _apri(kUrlDonazioni)),
                link(l10n.landingContacts, () => _apri('mailto:$_kEmailContatti')),
                link(l10n.privacyTitle, () => context.go('/privacy')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
