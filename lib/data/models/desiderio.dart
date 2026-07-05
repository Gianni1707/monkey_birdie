import 'package:freezed_annotation/freezed_annotation.dart';

import 'specie.dart';

part 'desiderio.freezed.dart';
part 'desiderio.g.dart';

/// Una riga di `lista_desideri` (UT07) con la specie completa via embedding
/// PostgREST (`specie:specie_id(*)`) + la nota opzionale dell'utente.
@freezed
class Desiderio with _$Desiderio {
  const factory Desiderio({
    required Specie specie,
    String? note,
    required DateTime aggiuntoIl,
  }) = _Desiderio;

  factory Desiderio.fromJson(Map<String, dynamic> json) =>
      _$DesiderioFromJson(json);
}
