import 'package:freezed_annotation/freezed_annotation.dart';

part 'raccolta.freezed.dart';
part 'raccolta.g.dart';

/// Una raccolta personale: sotto-gruppo di avvistamenti creato dall'utente.
/// Tabella `raccolte` (id, utente_id, nome, descrizione, creata_il).
@freezed
class Raccolta with _$Raccolta {
  const factory Raccolta({
    required String id,
    required String utenteId,
    required String nome,
    String? descrizione,
    required DateTime creataIl,
  }) = _Raccolta;

  factory Raccolta.fromJson(Map<String, dynamic> json) =>
      _$RaccoltaFromJson(json);
}
