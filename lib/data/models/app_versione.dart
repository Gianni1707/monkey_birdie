import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_versione.freezed.dart';
part 'app_versione.g.dart';

/// Riga singola della tabella `app_versione`: l'ultima versione APK Android
/// disponibile (cartello per il controllo aggiornamenti del sideload).
@freezed
class AppVersione with _$AppVersione {
  const factory AppVersione({
    required String versione,
    required int build,
    required String urlApk,
    String? note,
    @Default(false) bool obbligatorio,
  }) = _AppVersione;

  factory AppVersione.fromJson(Map<String, dynamic> json) =>
      _$AppVersioneFromJson(json);
}
