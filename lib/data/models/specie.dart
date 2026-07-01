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
    String? descrizione,
    @Default(0) int livelloPericolo,
    @Default('comune') String rarita,
    String? habitatDescrizione,
    String? birdnetLabel,
  }) = _Specie;

  factory Specie.fromJson(Map<String, dynamic> json) => _$SpecieFromJson(json);
}
