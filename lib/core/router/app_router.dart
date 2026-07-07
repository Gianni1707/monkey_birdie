import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/supabase/supabase_providers.dart';
import '../../features/auth/application/recupero_password_stato.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/nuova_password_screen.dart';
import '../../features/auth/presentation/recupera_password_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/amici/presentation/amici_screen.dart';
import '../../features/collection/presentation/specie_detail_screen.dart';
import '../../features/dintorni/presentation/dintorni_screen.dart';
import '../../features/home/presentation/home_shell.dart';
import '../../features/landing/presentation/landing_screen.dart';
import '../../features/landing/presentation/privacy_screen.dart';
import '../../features/profilo/presentation/profilo_pubblico_screen.dart';
import '../../features/raccolte/presentation/raccolta_dettaglio_screen.dart';

/// Adatta uno Stream a Listenable per il refresh del redirect di go_router.
class _AuthRefreshNotifier extends ChangeNotifier {
  _AuthRefreshNotifier(Stream<dynamic> stream) {
    _sub = stream.listen((_) => notifyListeners());
  }
  late final StreamSubscription<dynamic> _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

final goRouterProvider = Provider<GoRouter>((ref) {
  final client = ref.watch(supabaseClientProvider);
  final refresh = _AuthRefreshNotifier(client.auth.onAuthStateChange);
  ref.onDispose(refresh.dispose);
  // Il redirect deve ri-valutare sia al cambio auth sia quando parte/finisce il
  // recupero password (flag globale impostato in main.dart).
  final refreshCombinato = Listenable.merge([refresh, recuperoPasswordInCorso]);

  final router = GoRouter(
    initialLocation: '/',
    refreshListenable: refreshCombinato,
    redirect: (context, state) {
      final loc = state.matchedLocation;

      // Recupero password: resta sulla schermata dedicata finché la nuova
      // password non è impostata (o il flusso annullato).
      if (recuperoPasswordInCorso.value) {
        return loc == '/nuova-password' ? null : '/nuova-password';
      }

      final loggato = client.auth.currentSession != null;
      const pubbliche = ['/login', '/register', '/recupera-password'];
      final suAuth = pubbliche.contains(loc);

      if (loggato) {
        // Loggato: landing/pagine di accesso non servono → home.
        if (suAuth || loc == '/landing') return '/';
        return null;
      }
      // Non loggato:
      if (kIsWeb) {
        // Web: landing di ingresso. Consentiti landing, accesso, privacy;
        // ogni altra rotta → landing.
        if (suAuth || loc == '/landing' || loc == '/privacy') return null;
        return '/landing';
      }
      // App nativa (Android): niente landing marketing → login.
      return suAuth ? null : '/login';
    },
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(
        path: '/recupera-password',
        builder: (_, __) => const RecuperaPasswordScreen(),
      ),
      GoRoute(
        path: '/nuova-password',
        builder: (_, __) => const NuovaPasswordScreen(),
      ),
      GoRoute(path: '/', builder: (_, __) => const HomeShell()),
      GoRoute(
        path: '/specie/:id',
        builder: (_, state) =>
            SpecieDetailScreen(specieId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/raccolta/:id',
        builder: (_, state) =>
            RaccoltaDettaglioScreen(raccoltaId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/amici',
        builder: (_, __) => const AmiciScreen(),
      ),
      GoRoute(
        path: '/profilo/:id',
        builder: (_, state) =>
            ProfiloPubblicoScreen(utenteId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/dintorni',
        builder: (_, __) => const DintorniScreen(),
      ),
      GoRoute(path: '/landing', builder: (_, __) => const LandingScreen()),
      GoRoute(path: '/privacy', builder: (_, __) => const PrivacyScreen()),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});
