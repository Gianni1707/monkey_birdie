import 'package:freezed_annotation/freezed_annotation.dart';

part 'avvistamento.freezed.dart';
part 'avvistamento.g.dart';

/// Riga della view `avvistamenti_dettaglio`: avvistamento + lat/lng piatti
/// + dati essenziali della specie (join). E' il modello di LETTURA.
@freezed
class AvvistamentoDettaglio with _$AvvistamentoDettaglio {
  const factory AvvistamentoDettaglio({
    required String id,
    required String utenteId,
    required String specieId,
    String? fotoUrl,
    String? audioUrl,
    // Nullabili da 0005: `posizione` puo' essere NULL (avvistamento senza punto).
    // In pratica l'app la rende obbligatoria al salvataggio; la mappa mostra
    // solo gli avvistamenti con lat/lng non null.
    double? lat,
    double? lng,
    double? confidenza,
    @Default(false) bool condiviso,
    required DateTime avvistatoIl,
    required String specieNomeComune,
    // Nome comune ITALIANO dalla view (0009). Null finche' non c'e' traduzione
    // o la migrazione non e' applicata -> la UI ripiega sull'inglese.
    String? specieNomeComuneIt,
    required String specieNomeScientifico,
    @Default('comune') String specieRarita,
    @Default(0) int specieLivelloPericolo,
    String? specieDescrizione,
  }) = _AvvistamentoDettaglio;

  factory AvvistamentoDettaglio.fromJson(Map<String, dynamic> json) =>
      _$AvvistamentoDettaglioFromJson(json);
}
