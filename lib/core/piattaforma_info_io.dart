import 'dart:io';

/// Nativo: es. "Android 14 (API 34)" da `operatingSystemVersion`, con fallback
/// al nome OS. Nessun plugin (usa solo dart:io).
String piattaformaCorrente() {
  final versione = Platform.operatingSystemVersion.trim();
  if (versione.isNotEmpty) return versione;
  return Platform.operatingSystem;
}
