import 'package:freezed_annotation/freezed_annotation.dart';

part 'specie.freezed.dart';
part 'specie.g.dart';

/// Tabella `specie` (catalogo di riferimento, sola lettura per l'utente).
@freezed
class Specie with _$Specie {
  const factory Specie({
    required String id,
    required String nomeComune,
    required String nomeScientifico,
    // Nome comune ITALIANO (migrazione 0009). Null se non tradotto -> la UI
    // ripiega su [nomeComune] (inglese). Vedi `shared/nome_specie.dart`.
    String? nomeComuneIt,
    String? descrizione,
    @Default(0) int livelloPericolo,
    @Default('comune') String rarita,
    String? habitatDescrizione,
    String? birdnetLabel,
    String? imageLabel,
    // Ordine tassonomico in LATINO grezzo da GBIF (migrazione 0012), es.
    // "Passeriformes". Null se non risolto. Italianizzato a display via
    // `shared/ordine_tassonomico.dart` (badge sulla scheda specie).
    String? ordine,
    // Attribuzione descrizione (migrazione 0010): fonte + link Wikipedia.
    String? descrizioneFonte,
    String? descrizioneUrl,
    // Morfologia da BIRDBASE (migrazione 0011). Null dove il tratto manca -> UI
    // "n/d". La LUNGHEZZA corporea non è nel dataset (sempre n/d finora).
    int? pesoMinG,
    int? pesoMaxG,
    int? uovaMin,
    int? uovaMax,
    String? nido,
  }) = _Specie;

  factory Specie.fromJson(Map<String, dynamic> json) => _$SpecieFromJson(json);
}
