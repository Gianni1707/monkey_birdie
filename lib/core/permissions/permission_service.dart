import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

/// Richiesta dei permessi runtime.
class PermissionService {
  Future<bool> richiediMicrofono() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  Future<bool> microfonoConcesso() async {
    return Permission.microphone.isGranted;
  }

  /// Fotocamera (per "scatta foto"). Sul web è il browser a chiedere il permesso
  /// al momento dell'apertura del selettore: qui non forziamo nulla.
  Future<bool> richiediFotocamera() async {
    if (kIsWeb) return true;
    final status = await Permission.camera.request();
    return status.isGranted || status.isLimited;
  }

  /// Galleria/foto (per "carica foto"). Sul web è il browser a gestirlo.
  Future<bool> richiediGalleria() async {
    if (kIsWeb) return true;
    final status = await Permission.photos.request();
    return status.isGranted || status.isLimited;
  }
}

final permissionServiceProvider =
    Provider<PermissionService>((ref) => PermissionService());
