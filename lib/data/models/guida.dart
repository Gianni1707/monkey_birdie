import 'package:freezed_annotation/freezed_annotation.dart';

part 'guida.freezed.dart';
part 'guida.g.dart';

/// Tabella `guide` (contenuto editoriale: consigli di birdwatching, sola lettura).
@freezed
class Guida with _$Guida {
  const factory Guida({
    required String id,
    required String categoria,
    required String titolo,
    required String corpo,
    @Default(0) int ordine,
  }) = _Guida;

  factory Guida.fromJson(Map<String, dynamic> json) => _$GuidaFromJson(json);
}
