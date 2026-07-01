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
    required double lat,
    required double lng,
    double? confidenza,
    @Default(false) bool condiviso,
    required DateTime avvistatoIl,
    required String specieNomeComune,
    required String specieNomeScientifico,
    @Default('comune') String specieRarita,
    @Default(0) int specieLivelloPericolo,
    String? specieDescrizione,
  }) = _AvvistamentoDettaglio;

  factory AvvistamentoDettaglio.fromJson(Map<String, dynamic> json) =>
      _$AvvistamentoDettaglioFromJson(json);
}
