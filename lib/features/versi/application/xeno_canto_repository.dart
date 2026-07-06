import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/locale/locale_controller.dart';

/// Endpoint del proxy (Cloudflare Worker) che aggiunge la API key xeno-canto.
/// Same-origin sul web; assoluto su Android. NON è un segreto (è solo l'URL).
const String kXenoCantoProxy = 'https://monkeybirdie.com/api/xc';

/// Una registrazione del verso scelta per una specie (da xeno-canto, CC).
/// Porta con sé l'attribuzione obbligatoria: autore + numero XC + pagina.
class VersoSpecie {
  const VersoSpecie({
    required this.audioUrl,
    required this.autore,
    required this.xcId,
    required this.pagina,
    this.licenza,
  });

  final String audioUrl;
  final String autore;
  final String xcId;
  final String pagina;
  final String? licenza;

  Map<String, dynamic> toJson() => {
        'audioUrl': audioUrl,
        'autore': autore,
        'xcId': xcId,
        'pagina': pagina,
        'licenza': licenza,
      };

  factory VersoSpecie.fromJson(Map<String, dynamic> j) => VersoSpecie(
        audioUrl: j['audioUrl'] as String,
        autore: (j['autore'] ?? '') as String,
        xcId: (j['xcId'] ?? '') as String,
        pagina: (j['pagina'] ?? '') as String,
        licenza: j['licenza'] as String?,
      );
}

/// Accesso a xeno-canto (via proxy) per il verso di una specie. Best-effort come
/// [GbifRepository]: `null` su errore/timeout/assenza, niente eccezioni alla UI.
/// Cache-first in SharedPreferences per nome scientifico, con **sentinel** per
/// "nessuna registrazione" (così non si ri-interroga inutilmente).
class XenoCantoRepository {
  XenoCantoRepository(this._prefs);
  final SharedPreferences _prefs;

  static const _sentinelNessuna = '__none__';

  Future<VersoSpecie?> perNomeScientifico(String nomeScientifico) async {
    final nome = nomeScientifico.trim();
    if (nome.isEmpty) return null;
    final chiave = 'verso_${nome.toLowerCase()}';

    final cache = _prefs.getString(chiave);
    if (cache != null) {
      if (cache == _sentinelNessuna) return null;
      try {
        return VersoSpecie.fromJson(jsonDecode(cache) as Map<String, dynamic>);
      } catch (_) {
        // cache corrotta → si riprova sotto
      }
    }

    // La v3 accetta SOLO query a tag: niente testo libero. Il nome scientifico
    // va spezzato in gen:<genere> sp:<specie> (+ ssp: se presente).
    final tag = _tagNome(nome);
    if (tag == null) {
      _prefs.setString(chiave, _sentinelNessuna);
      return null;
    }

    try {
      // Prima le migliori (canto, qualità A); poi fallback allentato.
      final scelto = await _cerca('$tag grp:birds type:song q:A') ??
          await _cerca('$tag grp:birds');
      if (scelto == null) {
        _prefs.setString(chiave, _sentinelNessuna);
        return null;
      }
      _prefs.setString(chiave, jsonEncode(scelto.toJson()));
      return scelto;
    } catch (_) {
      // Errore/offline: NON cacho (riproverà la prossima volta).
      return null;
    }
  }

  Future<VersoSpecie?> _cerca(String query) async {
    final uri = Uri.parse(
      '$kXenoCantoProxy?query=${Uri.encodeQueryComponent(query)}',
    );
    final resp = await http
        .get(uri, headers: {'User-Agent': _userAgent})
        .timeout(const Duration(seconds: 10));
    if (resp.statusCode != 200) return null;

    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    final recs = (data['recordings'] as List?) ?? const [];
    if (recs.isEmpty) return null;

    Map<String, dynamic>? migliore;
    var miglioreScore = -1;
    for (final r in recs) {
      if (r is! Map) continue;
      final file = r['file'];
      if (file is! String || file.isEmpty) continue;

      final q = (r['q'] ?? '').toString();
      final type = (r['type'] ?? '').toString().toLowerCase();
      final also = r['also'];
      final durata = _secondi(r['length']?.toString());

      var score = switch (q) {
        'A' => 100,
        'B' => 80,
        'C' => 60,
        'D' => 40,
        _ => 20,
      };
      if (type.contains('song')) score += 30;
      final soloLei = also is! List ||
          also.every((e) => e == null || e.toString().trim().isEmpty);
      if (soloLei) score += 20; // niente specie in sottofondo
      if (durata != null && durata >= 5 && durata <= 90) score += 15;

      if (score > miglioreScore) {
        miglioreScore = score;
        migliore = Map<String, dynamic>.from(r);
      }
    }
    if (migliore == null) return null;

    return VersoSpecie(
      audioUrl: _https(migliore['file'].toString()),
      autore: (migliore['rec'] ?? '').toString(),
      xcId: (migliore['id'] ?? '').toString(),
      pagina: _https((migliore['url'] ?? '').toString()),
      licenza: migliore['lic']?.toString(),
    );
  }

  /// Nome scientifico → tag v3: `gen:<genere> sp:<specie>` (+ `ssp:` se c'è).
  /// `null` se non c'è almeno genere+specie.
  static String? _tagNome(String nome) {
    final parti = nome.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parti.length < 2) return null;
    final tags = 'gen:${parti[0]} sp:${parti[1]}';
    return parti.length >= 3 ? '$tags ssp:${parti[2]}' : tags;
  }

  /// xeno-canto a volte usa URL protocol-relative (`//...`): forziamo https.
  static String _https(String url) {
    if (url.startsWith('//')) return 'https:$url';
    return url;
  }

  /// `length` può essere "m:ss" o secondi: normalizza in secondi.
  static int? _secondi(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    if (raw.contains(':')) {
      final parti = raw.split(':');
      final m = int.tryParse(parti[0]) ?? 0;
      final s = int.tryParse(parti[1]) ?? 0;
      return m * 60 + s;
    }
    final n = num.tryParse(raw);
    return n?.round();
  }

  static const String _userAgent =
      'MonkeyBirdie/1.0 (birdwatching; non-commercial)';
}

final xenoCantoRepositoryProvider = Provider<XenoCantoRepository>(
  (ref) => XenoCantoRepository(ref.read(sharedPreferencesProvider)),
);

/// Verso della specie (cache-first, best-effort). `null` = nessun player.
final versoSpecieProvider =
    FutureProvider.family<VersoSpecie?, String>((ref, nomeScientifico) {
  return ref.read(xenoCantoRepositoryProvider).perNomeScientifico(nomeScientifico);
});
