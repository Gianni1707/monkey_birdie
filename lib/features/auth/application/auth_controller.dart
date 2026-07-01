import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/auth_repository.dart';

/// Orchestratore delle azioni di autenticazione. Lo stato AsyncValue<void>
/// rappresenta l'esito dell'ultima operazione (loading/error/data).
class AuthController extends AutoDisposeAsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<bool> accedi({required String email, required String password}) {
    return _esegui(() => ref
        .read(authRepositoryProvider)
        .accedi(email: email, password: password),);
  }

  Future<bool> registrati({
    required String email,
    required String password,
    required String username,
  }) {
    return _esegui(() => ref.read(authRepositoryProvider).registrati(
          email: email,
          password: password,
          username: username,
        ),);
  }

  Future<void> esci() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(authRepositoryProvider).esci());
  }

  Future<bool> _esegui(Future<void> Function() azione) async {
    state = const AsyncLoading();
    final res = await AsyncValue.guard(azione);
    state = res;
    return !res.hasError;
  }
}

final authControllerProvider =
    AutoDisposeAsyncNotifierProvider<AuthController, void>(AuthController.new);
