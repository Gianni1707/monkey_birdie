import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as img;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/error/failure.dart';
import '../models/profilo.dart';
import '../supabase/supabase_providers.dart';

/// Profilo dell'utente loggato (UT09). RLS: lettura pubblica, update solo il
/// proprio. `username` non si modifica (unique, impostato alla registrazione).
class ProfiloRepository {
  ProfiloRepository(this._client);
  final SupabaseClient _client;

  Future<Profilo> mioProfilo() async {
    try {
      final uid = _client.auth.currentUser?.id;
      if (uid == null) throw const AuthFailure('Sessione non valida.');
      final row = await _client.from('profili').select().eq('id', uid).single();
      return Profilo.fromJson(row);
    } catch (e) {
      throw mapError(e);
    }
  }

  /// Profilo pubblico di un altro utente (profili a lettura pubblica).
  Future<Profilo> profiloDi(String id) async {
    try {
      final row = await _client.from('profili').select().eq('id', id).single();
      return Profilo.fromJson(row);
    } catch (e) {
      throw mapError(e);
    }
  }

  /// Mappa id -> username per un insieme di utenti (profili a lettura pubblica),
  /// per l'attribuzione "@username" degli avvistamenti condivisi sulla mappa.
  Future<Map<String, String>> usernamePerIds(List<String> ids) async {
    if (ids.isEmpty) return const {};
    try {
      final rows =
          await _client.from('profili').select('id, username').inFilter('id', ids);
      return {
        for (final r in rows) r['id'] as String: r['username'] as String,
      };
    } catch (e) {
      throw mapError(e);
    }
  }

  /// Mappa id -> [Profilo] completo per un insieme di utenti (lettura pubblica),
  /// per mostrare l'AVATAR degli amici sui marcatori condivisi in mappa.
  Future<Map<String, Profilo>> profiliPerIds(List<String> ids) async {
    if (ids.isEmpty) return const {};
    try {
      final rows = await _client.from('profili').select().inFilter('id', ids);
      return {
        for (final r in rows)
          r['id'] as String: Profilo.fromJson(r),
      };
    } catch (e) {
      throw mapError(e);
    }
  }

  /// Aggiorna il nome account (username), la bio e i dati_personali (jsonb).
  Future<void> aggiorna({
    required String username,
    required String? bio,
    required Map<String, dynamic> datiPersonali,
  }) async {
    try {
      final uid = _client.auth.currentUser?.id;
      if (uid == null) throw const AuthFailure('Sessione non valida.');
      await _client.from('profili').update({
        'username': username,
        'bio': bio,
        'dati_personali': datiPersonali,
      }).eq('id', uid);
    } catch (e) {
      throw mapError(e);
    }
  }

  /// True se lo username e' libero (o e' gia' il mio). `profili` e' in lettura
  /// pubblica (RLS), quindi il controllo e' possibile lato client.
  Future<bool> usernameDisponibile(String username) async {
    try {
      final uid = _client.auth.currentUser?.id;
      final row = await _client
          .from('profili')
          .select('id')
          .eq('username', username)
          .maybeSingle();
      return row == null || row['id'] == uid;
    } catch (e) {
      throw mapError(e);
    }
  }

  /// Aggiorna SOLO i dati_personali (jsonb), senza toccare username/bio. Il
  /// chiamante passa la mappa completa gia' fusa (merge lato controller).
  Future<void> aggiornaDati(Map<String, dynamic> datiPersonali) async {
    try {
      final uid = _client.auth.currentUser?.id;
      if (uid == null) throw const AuthFailure('Sessione non valida.');
      await _client
          .from('profili')
          .update({'dati_personali': datiPersonali}).eq('id', uid);
    } catch (e) {
      throw mapError(e);
    }
  }

  // ---- AVATAR (bucket pubblico `avatar`, migrazione 0007) -------------------
  static const _bucketAvatar = 'avatar';

  /// Comprime (lato lungo <= 512, JPEG q85) e carica l'avatar in {uid}/{uuid}.jpg
  /// (nome univoco -> niente cache stantia sul public URL). Ritorna il path.
  Future<String> caricaAvatar(Uint8List originale) async {
    try {
      final uid = _client.auth.currentUser?.id;
      if (uid == null) throw const AuthFailure('Sessione non valida.');
      final jpeg = _comprimi(originale);
      final path = '$uid/${_nomeFile()}.jpg';
      await _client.storage.from(_bucketAvatar).uploadBinary(
            path,
            jpeg,
            fileOptions:
                const FileOptions(contentType: 'image/jpeg', upsert: false),
          );
      return path;
    } catch (e) {
      throw mapError(e);
    }
  }

  /// URL pubblico dell'avatar (bucket pubblico -> nessuna firma).
  String urlAvatar(String path) {
    return _client.storage.from(_bucketAvatar).getPublicUrl(path);
  }

  /// Elimina un vecchio avatar (best-effort, non blocca).
  Future<void> eliminaAvatar(String path) async {
    try {
      await _client.storage.from(_bucketAvatar).remove([path]);
    } catch (_) {
      // best-effort
    }
  }

  Uint8List _comprimi(Uint8List bytes) {
    final decoded = img.decodeImage(bytes);
    if (decoded == null) return bytes;
    const lato = 512;
    final ridotta = (decoded.width > lato || decoded.height > lato)
        ? img.copyResize(
            decoded,
            width: decoded.width >= decoded.height ? lato : null,
            height: decoded.height > decoded.width ? lato : null,
            interpolation: img.Interpolation.average,
          )
        : decoded;
    return img.encodeJpg(ridotta, quality: 85);
  }

  String _nomeFile() {
    final ms = DateTime.now().microsecondsSinceEpoch;
    final r = Random();
    final suffisso =
        List.generate(6, (_) => r.nextInt(16).toRadixString(16)).join();
    return '${ms}_$suffisso';
  }
}

final profiloRepositoryProvider = Provider<ProfiloRepository>((ref) {
  return ProfiloRepository(ref.watch(supabaseClientProvider));
});
