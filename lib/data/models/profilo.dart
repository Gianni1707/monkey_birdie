import 'package:freezed_annotation/freezed_annotation.dart';

part 'profilo.freezed.dart';
part 'profilo.g.dart';

/// Tabella `profili` (estende auth.users).
@freezed
class Profilo with _$Profilo {
  const factory Profilo({
    required String id,
    required String username,
    String? bio,
    @Default(<String, dynamic>{}) Map<String, dynamic> datiPersonali,
    DateTime? creatoIl,
  }) = _Profilo;

  factory Profilo.fromJson(Map<String, dynamic> json) =>
      _$ProfiloFromJson(json);
}
