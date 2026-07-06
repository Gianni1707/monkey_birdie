import 'package:freezed_annotation/freezed_annotation.dart';

part 'nota_stagionale.freezed.dart';
part 'nota_stagionale.g.dart';

/// Tabella `calendario_stagionale`: una nota per mese (1-12) su cosa fanno gli
/// uccelli nel periodo. La Home mostra quella del mese corrente.
@freezed
class NotaStagionale with _$NotaStagionale {
  const factory NotaStagionale({
    required int mese,
    required String titolo,
    required String testo,
  }) = _NotaStagionale;

  factory NotaStagionale.fromJson(Map<String, dynamic> json) =>
      _$NotaStagionaleFromJson(json);
}
