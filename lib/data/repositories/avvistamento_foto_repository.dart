import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as img;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/error/failure.dart';
import '../supabase/supabase_providers.dart';

/// Upload/lettura delle FOTO degli avvistamenti su Supabase Storage.
///
/// Bucket PRIVATO `avvistamenti` (migrazione 0006), path `{uid}/{uuid}.jpg`:
/// - upload: comprime la foto (lato lungo <=800px, JPEG q70 -> poche decine di
///   KB) e la carica; ritorna il PATH dell'oggetto, da salvare in `foto_url`.
/// - lettura: `urlFirmato` genera un signed URL temporaneo (soggetto alla RLS
///   del bucket, quindi rispetta la visibilita' propri/condivisi-da-amici).
/// L'audio NON si salva: qui ci sono solo le foto.
class AvvistamentoFotoRepository {
  AvvistamentoFotoRepository(this._client);
  final SupabaseClient _client;

  static const _bucket = 'avvistamenti';
  static const _latoMax = 800;
  static const _qualita = 70;

  /// Comprime e carica la foto. Ritorna il path nel bucket (per `foto_url`).
  Future<String> carica(Uint8List originale) async {
    try {
      final uid = _client.auth.currentUser?.id;
      if (uid == null) throw const AuthFailure('Sessione non valida.');

      final jpeg = _comprimi(originale);
      final path = '$uid/${_nomeFile()}.jpg';
      await _client.storage.from(_bucket).uploadBinary(
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

  /// Elimina il file foto dal bucket (path = `foto_url`). Best-effort: la
  /// policy "avvist foto: elimina le proprie" consente solo i propri; un errore
  /// non deve bloccare l'eliminazione dell'avvistamento (al piu' un file orfano).
  Future<void> eliminaFile(String path) async {
    try {
      await _client.storage.from(_bucket).remove([path]);
    } catch (_) {
      // best-effort: ignora (file gia' assente / rete).
    }
  }

  /// Signed URL temporaneo (24h) per leggere una foto privata. Best-effort:
  /// null in caso di errore -> la UI fa fallback sulla thumbnail della specie.
  /// 24h evita che l'URL in cache scada durante una sessione lunga (immagini
  /// rotte).
  Future<String?> urlFirmato(String path) async {
    try {
      return await _client.storage.from(_bucket).createSignedUrl(path, 86400);
    } catch (_) {
      return null;
    }
  }

  /// Resize (lato lungo <= [_latoMax]) + JPEG. Se il decode fallisce, rimanda
  /// i byte originali (il bucket accetta solo image/jpeg, quindi al limite
  /// fallira' l'upload: gestito come best-effort a monte).
  Uint8List _comprimi(Uint8List bytes) {
    final decoded = img.decodeImage(bytes);
    if (decoded == null) return bytes;
    final img.Image ridotta =
        (decoded.width > _latoMax || decoded.height > _latoMax)
            ? img.copyResize(
                decoded,
                width: decoded.width >= decoded.height ? _latoMax : null,
                height: decoded.height > decoded.width ? _latoMax : null,
                interpolation: img.Interpolation.average,
              )
            : decoded;
    return img.encodeJpg(ridotta, quality: _qualita);
  }

  /// Nome file univoco senza dipendenze extra (timestamp + suffisso casuale).
  String _nomeFile() {
    final ms = DateTime.now().microsecondsSinceEpoch;
    final r = Random();
    final suffisso =
        List.generate(8, (_) => r.nextInt(16).toRadixString(16)).join();
    return '${ms}_$suffisso';
  }
}

final avvistamentoFotoRepositoryProvider =
    Provider<AvvistamentoFotoRepository>((ref) {
  return AvvistamentoFotoRepository(ref.watch(supabaseClientProvider));
});

/// URL firmato per un path foto (cache di sessione via Riverpod .family).
final fotoAvvistamentoUrlProvider =
    FutureProvider.family<String?, String>((ref, path) {
  return ref.watch(avvistamentoFotoRepositoryProvider).urlFirmato(path);
});
