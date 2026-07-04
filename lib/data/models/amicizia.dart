import 'package:freezed_annotation/freezed_annotation.dart';

part 'amicizia.freezed.dart';
part 'amicizia.g.dart';

/// Riga della tabella `amicizie` (richiedente_id, destinatario_id, stato).
/// Stato: `in_attesa` | `accettata` | `rifiutata`. La relazione e' diretta in
/// storage (PK richiedente+destinatario) ma concettualmente simmetrica quando
/// accettata (vedi `sono_amici`).
@freezed
class Amicizia with _$Amicizia {
  const factory Amicizia({
    required String richiedenteId,
    required String destinatarioId,
    @Default('in_attesa') String stato,
    DateTime? creataIl,
  }) = _Amicizia;

  factory Amicizia.fromJson(Map<String, dynamic> json) =>
      _$AmiciziaFromJson(json);
}
